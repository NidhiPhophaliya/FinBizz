import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/logic/skills_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_skill_bar.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildEducationSuccessDialog(BuildContext context,
        PlayerSkill skill, void Function() onTapConfirm) =>
    AlphaDialogBuilder(
        title: "Congratulations",
        child: EducationSuccessDialog(skill),
        next: DialogButtonData(
            title: "Proceed", width: 380.0, onTap: onTapConfirm));

class EducationSuccessDialog extends StatelessWidget {
  final PlayerSkill skill;

  const EducationSuccessDialog(this.skill, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "You've increased your skill level",
          style: TextStyles.bold28,
        ),
        const SizedBox(height: 5.0),
        Text(
            "Jobs unlocked at this level: ${Job.values.where((j) => j.levelRequirement == skill.level).map((j) => j.title).join(", ")}",
            textAlign: TextAlign.center,
            style: TextStyles.medium19),
        const SizedBox(height: 15.0),
        ListenableBuilder(
          listenable: skill,
          builder: (context, child) => AlphaSkillBarMedium(skill),
        )
      ],
    );
  }
}
