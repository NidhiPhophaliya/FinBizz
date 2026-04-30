import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildBuyCarWithoutDebtDialog(BuildContext context,
    {required void Function() onTapConfirm,
    required void Function() onTapCancel}) {
  return AlphaDialogBuilder(
    title: "Pay in Cash?",
    child: const BuyCarWithoutDebtDialog(),
    cancel: DialogButtonData(title: "Apply Loan", onTap: onTapCancel),
    next: DialogButtonData(title: "Pay Cash", onTap: onTapConfirm),
  );
}

class BuyCarWithoutDebtDialog extends StatelessWidget {
  const BuyCarWithoutDebtDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "You have the option to pay in cash.",
          style: TextStyles.bold28,
        ),
        const SizedBox(height: 6.0),
        SizedBox(
          width: 520.0,
          child: Text(
            "It seems that you have enough cash to purchase this car one off without incurring any debt. Would you like to do that?",
            textAlign: TextAlign.center,
            style: TextStyles.medium22.copyWith(height: 1.6),
          ),
        ),
      ],
    );
  }
}
