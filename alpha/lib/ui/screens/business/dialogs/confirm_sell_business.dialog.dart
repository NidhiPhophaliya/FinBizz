import 'package:alpha/extensions.dart';
import 'package:alpha/logic/business_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmSellBusinessDialog(
    BuildContext context, Business business, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm Sell Business",
    child: ConfirmSellBusinessDialog(business),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmSellBusinessDialog extends StatelessWidget {
  final Business business;

  const ConfirmSellBusinessDialog(this.business, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Are you sure you want to sell this business?",
          style: TextStyles.bold26,
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
                  text: "You will receive a payout of  ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
                TextSpan(
                  text: businessManager
                      .calculateBusinessValuation(business)
                      .prettyCurrency,
                  style: TextStyles.medium22.copyWith(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " but you will not get any subsequent revenue.",
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
