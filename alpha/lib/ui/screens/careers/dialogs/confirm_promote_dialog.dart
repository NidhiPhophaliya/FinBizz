import 'package:alpha/logic/career_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmPromoteDialog(
    BuildContext context, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm Promotion",
    child: const CareerPromotionDialog(),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class CareerPromotionDialog extends StatelessWidget {
  const CareerPromotionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "Are you sure you want to be promoted?",
          style: TextStyles.bold28,
        ),
        const SizedBox(height: 6.0),
        RichText(
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
                text:
                    "+${CareerManager.kCareerProgressionHappinessBonus} Happiness ❤️",
                style: TextStyles.medium22
                    .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    ". You will still receive your promoted salary in the next round.",
                style: TextStyles.medium22.copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
