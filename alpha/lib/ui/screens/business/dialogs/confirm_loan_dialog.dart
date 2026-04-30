import 'package:alpha/extensions.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmBusinessLoanDialog(
    BuildContext context, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm Apply Loan",
    child: const ConfirmBusinessLoanDialog(),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmBusinessLoanDialog extends StatelessWidget {
  const ConfirmBusinessLoanDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Insufficient funds to start business. Do you want to apply for a loan?",
          style: TextStyles.bold24,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6.0),
        SizedBox(
          width: 520.0,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyles.medium22
                  .copyWith(fontFamily: "MazzardH", height: 1.6),
              children: [
                TextSpan(
                  text: "You will receive ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
                TextSpan(
                  text: "${LoanManager.kBusinessLoanAmount.prettyCurrency} ",
                  style: TextStyles.medium22
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "in your savings account immediately. Your initial business earnings will be used to repay back the loan. ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
