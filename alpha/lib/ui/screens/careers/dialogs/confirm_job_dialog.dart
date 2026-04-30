import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/utils.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildJobConfirmDialog(
        BuildContext context, Job selectedJob, void Function() onTapConfirm) =>
    AlphaDialogBuilder(
        title: "Confirm Job",
        child: JobConfirmDialog(selectedJob),
        cancel: DialogButtonData.cancel(context),
        next: DialogButtonData.confirm(onTap: onTapConfirm));

class JobConfirmDialog extends StatelessWidget {
  final Job selectedJob;

  const JobConfirmDialog(this.selectedJob, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "You have chosen to work as ${singularArticle(selectedJob.title)}.",
          textAlign: TextAlign.center,
          style: TextStyles.bold24,
        ),
        const SizedBox(height: 5.0),
        const Text(
            "Are you sure? You will receive your new salary the next round.",
            textAlign: TextAlign.center,
            style: TextStyles.medium22),
      ],
    );
  }
}
