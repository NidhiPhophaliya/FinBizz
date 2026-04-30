import 'package:alpha/logic/economy_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildEconomicCycleInfoDialog(BuildContext context,
    EconomicCycle current, EconomicCycle next, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Economic Cycle",
    child: EconomicCycleInfoDialog(current, next),
    next: DialogButtonData.confirm(onTap: onTapConfirm),
  );
}

class EconomicCycleInfoDialog extends StatelessWidget {
  final EconomicCycle current;
  final EconomicCycle next;

  const EconomicCycleInfoDialog(this.current, this.next, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          current.description,
          style: TextStyles.bold28,
        ),
        const SizedBox(height: 4.0),
        Text(current.longDescription,
            textAlign: TextAlign.center, style: TextStyles.medium22),
        const SizedBox(height: 12.0),
        Text("Next Cycle: ${next.name}",
            textAlign: TextAlign.center, style: TextStyles.bold22),
      ],
    );
  }
}
