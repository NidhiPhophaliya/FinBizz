import 'package:alpha/extensions.dart';
import 'package:alpha/logic/data/board_tiles.dart';
import 'package:alpha/logic/data/business.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/screens/business/business_selection_screen.dart';
import 'package:alpha/ui/screens/car/car_screen.dart';
import 'package:alpha/ui/screens/careers/career_screen.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:alpha/ui/screens/education/education_selection_screen.dart';
import 'package:alpha/ui/screens/opportunity/opportunity_screen.dart';
import 'package:alpha/ui/screens/personal_life/personal_life_screen.dart';
import 'package:alpha/ui/screens/real_estate/real_estate_screen.dart';
import 'package:alpha/ui/screens/world_event/world_event_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameTileScreen extends StatelessWidget {
  final BoardTile activeTile = boardManager.getActivePlayerTile();

  GameTileScreen({super.key});

  void _handleWorldEvent(BuildContext context) {
    final worldEvent = worldEventManager.triggerEvent();

    context.showDialog(buildWorldEventDialog(context, worldEvent, () {
      context.navigateTo(DashboardScreen());
    }));
  }

  Widget _getNextScreen(BuildContext context) {
    switch (activeTile) {
      case BoardTile.startTile:
        return DashboardScreen();
      case BoardTile.careerTile:
        return const CareerScreen();
      case BoardTile.educationTile:
        return const EducationSelectionScreen();
      case BoardTile.opportunityTile:
        return const OpportunityScreen();
      case BoardTile.personalLifeTile:
        return PersonalLifeScreen();
      case BoardTile.worldEventTile:
        return const SizedBox();
      case BoardTile.realEstatesTile:
        return const RealEstateScreen();
      case BoardTile.carTile:
        return const CarScreen();
      case BoardTile.businessTechnologyTile:
        return const BusinessSelectionScren(sector: BusinessSector.technology);
      case BoardTile.businessFnBTile:
        return const BusinessSelectionScren(
            sector: BusinessSector.foodAndBeverage);
      case BoardTile.businessEcommerceTile:
        return const BusinessSelectionScren(sector: BusinessSector.eCommerce);
      case BoardTile.businessPharmaTile:
        return const BusinessSelectionScren(
            sector: BusinessSector.pharmaceutical);
      case BoardTile.businessSocialMediaTile:
        return const BusinessSelectionScren(sector: BusinessSector.socialMedia);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
        title: "You've landed on",
        next: Builder(
            builder: (context) => AlphaButton.next(onTap: () {
                  if (activeTile == BoardTile.worldEventTile) {
                    _handleWorldEvent(context);
                  } else {
                    context.navigateTo(_getNextScreen(context));
                  }
                })),
        children: [
          const SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("You rolled a", style: TextStyles.bold30),
              const SizedBox(width: 10.0),
              Text(
                gameManager.getLastDiceRoll().toString(),
                style: const TextStyle(
                  fontSize: 80.0,
                ),
              ),
              const SizedBox(width: 10.0),
              const Text("and landed on", style: TextStyles.bold30)
            ],
          ),
          const SizedBox(height: 10.0),
          SizedBox(
                  width: 300.0,
                  height: 360.0,
                  child: Image.asset(activeTile.image.path))
              .animate()
              .scale(
                  curve: Curves.elasticOut,
                  duration: const Duration(milliseconds: 1150)),
          const SizedBox(height: 55.0),
          SizedBox(
            width: 400.0,
            child: Text(activeTile.description,
                textAlign: TextAlign.center,
                style: TextStyles.medium20.copyWith(height: 1.7)),
          ),
        ]);
  }
}
