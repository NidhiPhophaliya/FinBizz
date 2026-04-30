import 'package:alpha/assets.dart';
import 'package:alpha/logic/opportunity_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';

final List<Color> cardColors = [
  const Color(0xFFE57373),
  const Color(0xFF5ED4C8),
  const Color(0xFFFFB74D),
  const Color(0xFFAAB8FD),
];

enum OCardSide { front, back }

class OpportunityCardController {
  final FlipCardController controller = FlipCardController();

  OCardSide _side = OCardSide.back;
  OCardSide get side => _side;

  void openCard() {
    if (_side == OCardSide.front) {
      return;
    }

    controller.toggleCard();
    _side = OCardSide.front;
  }

  void closeCard() {
    if (_side == OCardSide.back) {
      return;
    }

    controller.toggleCard();
    _side = OCardSide.back;
  }
}

class FlippableOpportunityCard extends StatefulWidget {
  final OpportunityCardController controller;
  final Opportunity opportunity;

  const FlippableOpportunityCard(
      {super.key, required this.controller, required this.opportunity});

  @override
  State<FlippableOpportunityCard> createState() =>
      _FlippableOpportunityCardState();
}

class _FlippableOpportunityCardState extends State<FlippableOpportunityCard> {
  late final OpportunityCardController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      side: CardSide.BACK,
      flipOnTouch: false,
      controller: _controller.controller,
      direction: FlipDirection.HORIZONTAL,
      front: OpportunityCardFront(opportunity: widget.opportunity),
      back: OpportunityCardBack(
        cardColor: getOpportunityColor(widget.opportunity),
      ),
    );
  }
}

class OpportunityCardBack extends StatelessWidget {
  final Color cardColor;
  const OpportunityCardBack({super.key, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350.0,
      height: 450.0,
      child: CardBack(
        cardColor: cardColor,
      ),
    );
  }
}

class OpportunityCardFront extends StatelessWidget {
  final Opportunity opportunity;
  const OpportunityCardFront({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350.0,
      height: 450.0,
      child: CardFront(opportunity: opportunity),
    );
  }
}

class _QuestionMarkIcon extends StatelessWidget {
  // Widget for the question mark icon on each card
  final AlphaAsset asset;

  const _QuestionMarkIcon({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0.0, 75.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Image.asset(
          asset.path,
          height: 300.0,
        ),
      ),
    );
  }
}

class CardBack extends StatelessWidget {
  final Color cardColor;

  const CardBack({super.key, required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return AlphaContainer(
        color: cardColor,
        child: Stack(children: [
          Container(
            width: double.infinity,
            height: 500.0,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
            ),
          ),
          const _QuestionMarkIcon(asset: AlphaAsset.opportunityQuestionMark),
        ]));
  }
}

class CardFront extends StatelessWidget {
  final Opportunity opportunity;

  const CardFront({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return AlphaContainer(
        color: getOpportunityColor(opportunity),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 230.0,
              height: 230.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(0, 3.0))
                  ],
                  border: Border.all(color: Colors.black87, width: 4.0)),
              child: Image.asset(
                opportunity.image.path,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30.0),
            Text(opportunity.title, style: TextStyles.bold30),
            const SizedBox(height: 10.0),
            Text(opportunity.description, style: TextStyles.bold18),
          ]),
        ));
  }
}

Color getOpportunityColor(Opportunity opportunity) {
  return cardColors[opportunity.title.hashCode % cardColors.length];
}
