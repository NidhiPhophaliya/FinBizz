import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';

class BusinessesLandingDialog extends StatelessWidget {
  const BusinessesLandingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "Start your own business to generate revenue "
          "and is affected by the economic cycle, market state, and market competition. "
          "A business loan of \$${LoanManager.kBusinessLoanAmount.toInt()} can be taken if "
          "you cannot afford to start a business.",
          style: TextStyles.medium22.copyWith(height: 1.5),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
