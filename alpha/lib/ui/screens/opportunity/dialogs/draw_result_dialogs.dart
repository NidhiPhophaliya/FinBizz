import 'package:alpha/extensions.dart';
import 'package:alpha/logic/opportunity_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildOpportunityDrawResultDialog(BuildContext context,
    Opportunity opportunity, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Opportunity",
    child: OpportunityDrawResultDialog(opportunity),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class OpportunityDrawResultDialog extends StatelessWidget {
  final Opportunity opportunity;

  const OpportunityDrawResultDialog(this.opportunity, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          opportunity.description,
          style: TextStyles.bold28,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6.0),
        SizedBox(
          width: 520.0,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyles.medium22.copyWith(
                  fontFamily: "MazzardH", color: Colors.black, height: 1.6),
              children: [
                TextSpan(
                  text:
                      "You will ${opportunity.cashPenaltyPercentage < 0 ? "lose" : "receive"} ",
                  style: TextStyles.medium22,
                ),
                TextSpan(
                  text: opportunity.cashBonus != 0
                      ? opportunity.cashBonus.prettyCurrency
                      : "${opportunity.cashPenaltyPercentage.abs().toStringAsFixed(0)}%",
                  style: TextStyles.medium22.copyWith(
                      color: opportunity.cashBonus != 0
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                        "${opportunity.cashBonus != 0 ? " in cash" : " of your savings"}.",
                    style: TextStyles.medium22),
                if (opportunity.happinessBonus != 0)
                  TextSpan(
                      text:
                          " You will ${opportunity.happinessBonus > 0 ? "gain" : "lose"} ",
                      style: TextStyles.medium22),
                if (opportunity.happinessBonus != 0)
                  TextSpan(
                      text:
                          "${opportunity.happinessBonus > 0 ? "+" : ""}${opportunity.happinessBonus}",
                      style: TextStyles.bold22.copyWith(
                          color: opportunity.happinessBonus > 0
                              ? Colors.green
                              : Colors.red)),
                if (opportunity.happinessBonus != 0)
                  const TextSpan(
                      text: " Happiness ❤️.", style: TextStyles.medium22),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
