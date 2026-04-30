import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';

class OwnedBusinessesLandingDialog extends StatelessWidget {
  const OwnedBusinessesLandingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "Manage your owned businesses here. Check your business valuation, cashflow "
          "and overall performance in the market. You can also sell your "
          "business for a profit based on its current valuation. ",
          style: TextStyles.medium22,
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
