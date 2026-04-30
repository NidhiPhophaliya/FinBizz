import 'package:alpha/logic/data/business.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/screens/business/widgets/business_selection_card.dart';
import 'package:flutter/material.dart';

class StockSectorCard extends StatelessWidget {
  final BusinessSector sector;

  const StockSectorCard(this.sector, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.0,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
          color: sector.sectorColor,
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          border: Border.all(color: Colors.black, width: 2.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-1.5, -1.0),
            child: Text(
              getSectorEmoji(sector),
              style: TextStyles.bold13,
            ),
          ),
          Text(
            sector.shortName,
            style: TextStyles.bold14.copyWith(height: 1.9),
          )
        ],
      ),
    );
  }
}
