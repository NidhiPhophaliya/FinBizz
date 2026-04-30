import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';

class CareerSelectionLandingDialog extends StatelessWidget {
  const CareerSelectionLandingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 580.0,
      child: Column(
        children: [
          Text(
            "Getting a job is the first step to financial independence. "
            "Earn salary every round and save up for other assets and investments. "
            "Each time you land on this tile, you can choose to progress in your career. "
            "You can change your career afterwards.",
            style: TextStyles.medium22,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CareerProgressionLandingDialog extends StatelessWidget {
  const CareerProgressionLandingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 580.0,
      child: Column(
        children: [
          Text(
            "Education is the key to success in the early game. Pursue a degree or learn an online course to "
            "improve your skill level and unlock more job opportunities and career progression.",
            style: TextStyles.medium22,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50.0),
        ],
      ),
    );
  }
}
