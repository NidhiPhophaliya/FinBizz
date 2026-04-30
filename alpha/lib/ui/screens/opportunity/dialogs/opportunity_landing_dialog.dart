import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';

class OpportunityLandingDialog extends StatelessWidget {
  const OpportunityLandingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 580.0,
      child: Column(
        children: [
          Text(
            "Life presents unexpected opportunities. Draw a card to see what chance or challenge awaits. "
            "It could bring you luck, test your knowledge, or even lighten or tighten your wallet.",
            style: TextStyles.medium22.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
