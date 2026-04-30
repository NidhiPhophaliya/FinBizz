import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildPromotionSuccessDialog(
    BuildContext context, Job newJob, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Congratulations",
    child: PromotionSuccessDialog(
      newJob: newJob,
    ),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class PromotionSuccessDialog extends StatelessWidget {
  final Job newJob;

  const PromotionSuccessDialog({super.key, required this.newJob});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "You've been promoted!",
          style: TextStyles.bold28,
        ),
        const SizedBox(height: 6.0),
        SizedBox(
          width: 520.0,
          child: Text(
            "You are now a ${newJob.title}. You will receive your new salary in the next round.",
            textAlign: TextAlign.center,
            style: TextStyles.medium22,
          ),
        ),
      ],
    );
  }
}
