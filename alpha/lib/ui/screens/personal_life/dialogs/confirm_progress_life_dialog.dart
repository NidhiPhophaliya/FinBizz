import 'package:alpha/extensions.dart';
import 'package:alpha/logic/data/personal_life.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildConfirmProgressLifeDialog(
    BuildContext context,
    PersonalLifeStatus current,
    PersonalLifeStatus next,
    void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Confirm Action",
    child: ConfirmProgressLifeDialog(current, next),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class ConfirmProgressLifeDialog extends StatelessWidget {
  final PersonalLifeStatus current;
  final PersonalLifeStatus next;

  const ConfirmProgressLifeDialog(this.current, this.next, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          "Are you sure you want to ${current.action.toLowerCase()}?",
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
                  text: "+${next.happinessBonus} Happiness ❤️ ",
                  style: TextStyles.medium22
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "but will have to pay ",
                  style: TextStyles.medium22
                      .copyWith(fontFamily: "MazzardH", color: Colors.black),
                ),
                TextSpan(
                  text: next.cost.prettyCurrency,
                  style: TextStyles.medium22
                      .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: " to progress to this stage.",
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
