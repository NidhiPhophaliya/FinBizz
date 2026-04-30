import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';

class EducationLandingDialog extends StatelessWidget {
  const EducationLandingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 580.0,
      child: Column(
        children: [
          Text(
            "Education is key in the early game. "
            "Pursue a degree or learn an online course to improve "
            "your skill level and unlock career more progression opportunities. "
            "You will also receive some XP skill points after every round.",
            style: TextStyles.medium22,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
