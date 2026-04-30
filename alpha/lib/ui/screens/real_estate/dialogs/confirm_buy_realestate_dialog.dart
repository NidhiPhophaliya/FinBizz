import 'package:alpha/extensions.dart';
import 'package:alpha/logic/real_estate_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmBuyRealEstateDialog(BuildContext context,
    RealEstate selectedRealEstate, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm Purchase",
    child: ConfirmBuyRealEstateDialog(selectedRealEstate),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmBuyRealEstateDialog extends StatelessWidget {
  final RealEstate realEstate;

  const ConfirmBuyRealEstateDialog(this.realEstate, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Are you sure you want to buy this property with a loan?",
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
                  text:
                      "+${RealEstateManager.kPurchaseRealEstateHappinessBonus} Happiness ❤️",
                  style: TextStyles.medium22
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " from buying this property. You will have to pay ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
                TextSpan(
                  text: realEstate.repaymentPerRound.prettyCurrency,
                  style: TextStyles.medium22
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " each round for ${realEstate.repaymentPeriod} rounds.",
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
