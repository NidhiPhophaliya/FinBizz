import 'package:alpha/extensions.dart';
import 'package:alpha/logic/financial_market_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmBuyStockDialog(BuildContext context,
    Stock selectedStock, int quantity, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm Purchase",
    child: ConfirmBuyStockDialog(selectedStock, quantity),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmBuyStockDialog extends StatelessWidget {
  final Stock selectedStock;
  final int quantity;

  const ConfirmBuyStockDialog(this.selectedStock, this.quantity, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Are you sure you want to buy this stock?",
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
                  .copyWith(fontFamily: "MazzardH", height: 1.5),
              children: [
                TextSpan(
                  text: "You will receive ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text: "$quantity units ",
                  style: TextStyles.bold22.copyWith(
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: "of ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text: selectedStock.name,
                  style: TextStyles.bold22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text: " stock for a total of ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text: (selectedStock.price * quantity).prettyCurrency,
                  style: TextStyles.bold30.copyWith(color: Colors.red),
                ),
                TextSpan(
                  text: ". ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
