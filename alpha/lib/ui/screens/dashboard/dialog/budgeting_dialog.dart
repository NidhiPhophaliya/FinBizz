import 'package:alpha/extensions.dart';
import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildBudgetingDialog(BuildContext context,
        SavingsAccount playerSavings, void Function() onTapConfirm) =>
    AlphaDialogBuilder(
        title: "Budgeting",
        child: BudgetingDialog(playerSavings: playerSavings),
        next: DialogButtonData(
            title: "Proceed", width: 380.0, onTap: onTapConfirm));

class BudgetingDialog extends StatelessWidget {
  final SavingsAccount playerSavings;

  const BudgetingDialog({super.key, required this.playerSavings});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Align(
          alignment: Alignment.center,
          child: Text(
            "Please allocate budgets for your income",
            style: TextStyles.bold24,
          ),
        ),
        const SizedBox(height: 15.0),
        const Text(
          "Total current unbudgeted income",
          textAlign: TextAlign.center,
          style: TextStyles.medium22,
        ),
        const SizedBox(height: 5.0),
        Text(playerSavings.unbudgeted.prettyCurrency,
            style: const TextStyle(
                color: Colors.green,
                fontSize: 50.0,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
