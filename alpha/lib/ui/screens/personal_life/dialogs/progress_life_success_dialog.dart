import 'package:alpha/logic/data/personal_life.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildSuccessProgressLifeDialog(BuildContext context,
    PersonalLifeStatus status, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Congratulations",
    child: ConfirmProgressLifeDialog(status),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmProgressLifeDialog extends StatelessWidget {
  final PersonalLifeStatus status;

  const ConfirmProgressLifeDialog(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "You are now ${status.title.toLowerCase()}",
          style: TextStyles.bold28,
        ),
        const SizedBox(height: 6.0),
        const SizedBox(
          width: 520.0,
          child: Text(
            "Your happiness score has been increaseed. You can progress to the next stage the next time you land on the personal life tile.",
            textAlign: TextAlign.center,
            style: TextStyles.medium22,
          ),
        ),
      ],
    );
  }
}
