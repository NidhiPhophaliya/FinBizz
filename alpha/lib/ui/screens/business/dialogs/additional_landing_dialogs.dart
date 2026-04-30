import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';

class BusinessPioneerDialog extends StatelessWidget {
  const BusinessPioneerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "You are the first to enter this market!",
          style: TextStyles.bold24,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.0),
        Text(
          "By starting a business, you will become a monopoly in this market "
          "and have increased revenue growth. However, "
          "you will have to pay a higher initial cost.",
          style: TextStyles.medium22,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}

class BusinessMonopolyDialog extends StatelessWidget {
  const BusinessMonopolyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "You are the only competitor in this market!",
          style: TextStyles.bold24,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.0),
        Text(
          "Your business will have increased revenue growth due to high market share. "
          "However, you will have to pay a higher initial cost.",
          style: TextStyles.medium22,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}

class BusinessOligopolyDialog extends StatelessWidget {
  const BusinessOligopolyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "Looks like you have other competitors in this sector.",
          style: TextStyles.bold24,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.0),
        Text(
          "Your business will have slightly decreased revenue growth due to "
          "diluted market share. However, your business will have lower initial cost.",
          style: TextStyles.medium22,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}

class BusinessSaturatedDialog extends StatelessWidget {
  const BusinessSaturatedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "This market is saturated with competitors.",
          style: TextStyles.bold24,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 6.0),
        Text(
          "Business revenue growth is stagnant due to high competition. "
          "Your business will not grow unless players sell off their businesses in this sector. "
          "but will have significantly reduced initial costs.",
          style: TextStyles.medium22,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
