import 'package:alpha/extensions.dart';
import 'package:alpha/logic/business_logic.dart';
import 'package:alpha/logic/data/business.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:flutter/material.dart';

class BusinessSelectionCard extends StatelessWidget {
  final Business business;

  const BusinessSelectionCard(this.business, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlphaContainer(
      child: Column(
        children: <Widget>[
          Container(
            height: 35.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0)),
                color: business.sector.sectorColor),
          ),
          const SizedBox(height: 15.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(business.name, style: TextStyles.bold30),
              const SizedBox(height: 10.0),
              Wrap(spacing: 12.0, children: [
                BusinessCardTag(
                    getSectorEmoji(business.sector), business.sector.name),
                if (business.esgRating > 0)
                  BusinessCardTag("♻️", "ESG ${business.esgRating}"),
              ]),
              const SizedBox(height: 18.0),
              Text("Est. Revenue",
                  style: TextStyles.bold20
                      .copyWith(color: const Color(0xFF383838))),
              Text(
                businessManager
                    .calculateBusinessEarnings(business)
                    .prettyCurrency,
                style: TextStyles.bold30,
              ),
              const SizedBox(height: 8.0),
              Text("Initial Cost",
                  style: TextStyles.bold20
                      .copyWith(color: const Color(0xFF383838))),
              Text(
                business.initialCost.prettyCurrency,
                style: TextStyles.bold25,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class BusinessCardTag extends StatelessWidget {
  final String title;
  final String emoji;

  const BusinessCardTag(this.emoji, this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      height: 38.0,
      decoration: BoxDecoration(
          color: const Color(0xffB5D2AD),
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(color: Colors.black, width: 2.5),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black, offset: Offset(1.0, 2.0))
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
              offset: const Offset(-2.5, -3.0),
              child: Text(emoji, style: TextStyles.medium18)),
          Text(
            title,
            style: TextStyles.medium15,
          )
        ],
      ),
    );
  }
}

String getSectorEmoji(BusinessSector sector) {
  switch (sector) {
    case BusinessSector.technology:
      return "📱";
    case BusinessSector.eCommerce:
      return "🛍️";
    case BusinessSector.foodAndBeverage:
      return "🍔";
    case BusinessSector.socialMedia:
      return "📸";
    case BusinessSector.pharmaceutical:
      return "💊";
    case BusinessSector.noBusiness:
      return "❌";
  }
}
