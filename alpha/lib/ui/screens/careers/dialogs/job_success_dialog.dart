import 'package:alpha/extensions.dart';
import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/utils.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildJobSuccessDialog(
        BuildContext context, Job selectedJob, void Function() onTapConfirm) =>
    AlphaDialogBuilder(
        title: "Congratulations",
        child: JobSuccessDialog(selectedJob),
        next: DialogButtonData(
            title: "Proceed", width: 380.0, onTap: onTapConfirm));

class JobSuccessDialog extends StatelessWidget {
  final Job selectedJob;

  const JobSuccessDialog(this.selectedJob, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: Text(
            "You're now working as ${singularArticle(selectedJob.title)}.",
            style: TextStyles.bold24,
          ),
        ),
        const SizedBox(height: 10.0),
        const Text("Your salary per round is", style: TextStyles.medium22),
        Text(selectedJob.salary.prettyCurrency,
            style: const TextStyle(
                color: Color(0xFF38A83C),
                fontSize: 38.0,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
