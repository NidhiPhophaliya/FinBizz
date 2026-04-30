import 'package:alpha/extensions.dart';
import 'package:alpha/logic/business_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmRndBusinessDialog(
    BuildContext context, Business business, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm R&D",
    child: ConfirmRndBusinessDialog(business),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmRndBusinessDialog extends StatelessWidget {
  final Business business;

  const ConfirmRndBusinessDialog(this.business, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Are you sure you want to perform R&D?",
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
                  .copyWith(fontFamily: "MazzardH", height: 1.5),
              children: [
                TextSpan(
                  text: "You will invest ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text: businessManager.getRndCost(business).prettyCurrency,
                  style: TextStyles.medium22
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      " in Research and Development (R&D) to increase revenue by ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text: "${(BusinessManager.kRndGrowthFactor * 100).toInt()}%",
                  style: TextStyles.medium22.copyWith(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ". There is a ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text:
                      "${((1 - businessManager.getRndSuccessRate(business)) * 100).toInt()}%",
                  style: TextStyles.medium22
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " chance that the R&D will fail.",
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

AlphaDialogBuilder buildSuccessRndBusinessDialog(
    BuildContext context, Business business, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Congratulations",
    child: SuccessRndBusinessDialog(business),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class SuccessRndBusinessDialog extends StatelessWidget {
  final Business business;

  const SuccessRndBusinessDialog(this.business, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Successfully completed business R&D",
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
                  text: "You have succesfully increased your revenue by ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text: "${(BusinessManager.kRndGrowthFactor * 100).toInt()}%",
                  style: TextStyles.medium22.copyWith(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ". Your current base revenue is ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text: business.currentRevenue.prettyCurrency,
                  style: TextStyles.medium22.copyWith(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ".",
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

AlphaDialogBuilder buildFailureRndBusinessDialog(
    BuildContext context, Business business, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Failure",
    child: FailureRndBusinessDialog(business),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class FailureRndBusinessDialog extends StatelessWidget {
  final Business business;

  const FailureRndBusinessDialog(this.business, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Business R&D has failed",
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
                  text: "You have lost your R&D investment of ",
                  style: TextStyles.medium22.copyWith(color: Colors.black),
                ),
                TextSpan(
                  text: businessManager.getRndCost(business).prettyCurrency,
                  style: TextStyles.medium22
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ". Your business' base revenue is unchanged.",
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
