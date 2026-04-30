import 'package:alpha/logic/real_estate_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmSellRealEstateDialog(BuildContext context,
    RealEstate selectedRealEstate, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm Purchase",
    child: ConfirmSellRealEstateDialog(selectedRealEstate),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmSellRealEstateDialog extends StatelessWidget {
  final RealEstate selectedRealEstate;

  const ConfirmSellRealEstateDialog(this.selectedRealEstate, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Are you sure you want to sell this property?",
          style: TextStyles.bold24,
        ),
        const SizedBox(height: 6.0),
        Text(
          selectedRealEstate.name,
          style: TextStyles.bold22,
        ),
        const SizedBox(height: 8.0),
        const SizedBox(
          width: 520.0,
          child: Text(
            "Your outstanding loan balance will be repaid immediately and the net profit will be credited to your savings.",
            textAlign: TextAlign.center,
            style: TextStyles.medium18,
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
