import 'package:alpha/extensions.dart';
import 'package:alpha/logic/business_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmBuyBusinessDialog(
    BuildContext context, Business business, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm Business",
    child: ConfirmBuyBusinessDialog(business),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmBuyBusinessDialog extends StatelessWidget {
  final Business business;

  const ConfirmBuyBusinessDialog(this.business, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Are you sure you want to start this business?",
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
                  text: "You will receive an estimated revenue of ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
                TextSpan(
                  text: businessManager
                      .calculateBusinessEarnings(business)
                      .prettyCurrency,
                  style: TextStyles.medium22.copyWith(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " every round. You will pay ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
                TextSpan(
                  text: business.initialCost.prettyCurrency,
                  style: TextStyles.medium22
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " now to start the business.",
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
