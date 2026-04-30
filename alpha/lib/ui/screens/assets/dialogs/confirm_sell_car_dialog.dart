import 'package:alpha/extensions.dart';
import 'package:alpha/logic/car_logic.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmSellCarDialog(BuildContext context,
    Player player, Car car, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm Sell Car",
    child: ConfirmSellCarDialog(player, car),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmSellCarDialog extends StatelessWidget {
  final Player player;
  final Car car;

  const ConfirmSellCarDialog(this.player, this.car, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Are you sure you want to sell this car?",
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
                  text: "You will receive a payment of ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
                TextSpan(
                  text: carManager.getCarSalePrice(player, car).prettyCurrency,
                  style: TextStyles.medium22.copyWith(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " but ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
                TextSpan(
                  text: "${car.happinessBonus} happiness ❤️",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.red),
                ),
                TextSpan(
                  text: " and ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
                TextSpan(
                  text: "${car.esgBonus} ESG 🌎",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.red),
                ),
                TextSpan(
                  text: " will be deducted.",
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
