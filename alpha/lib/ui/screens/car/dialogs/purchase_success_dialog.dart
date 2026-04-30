import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildPurchaseCarSuccessDialog(
    BuildContext context, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Congratulations",
    child: const PurchaseCarSuccessDialog(),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class PurchaseCarSuccessDialog extends StatelessWidget {
  const PurchaseCarSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        Text(
          "You've bought a new car.",
          style: TextStyles.bold28,
        ),
        SizedBox(height: 6.0),
        SizedBox(
          width: 520.0,
          child: Text(
            "Your happiness score has been increaseed. You will have to repay the loan each round for this car.",
            textAlign: TextAlign.center,
            style: TextStyles.medium22,
          ),
        ),
      ],
    );
  }
}
