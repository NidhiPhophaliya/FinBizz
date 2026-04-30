import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';

class CarSelectionLandingdialog extends StatelessWidget {
  const CarSelectionLandingdialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 580.0,
      child: Column(
        children: [
          Text(
            "Purchasing a car boosts your happiness score significantly, but "
            "the car's value depreciates over time. You can take a car loan if your cash flow per "
            "round is sufficient to cover the loan repayments.",
            style: TextStyles.medium22,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
