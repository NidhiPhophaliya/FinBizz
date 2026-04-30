import 'package:alpha/logic/data/business.dart';
import 'package:alpha/logic/data/world_event.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildWorldEventDialog(
    BuildContext context, WorldEvent worldEvent, void Function() onTapConfirm) {
  return AlphaDialogBuilder(
    title: "Breaking News",
    child: WorldEventDialog(worldEvent),
    next: DialogButtonData(title: "Confirm", width: 320.0, onTap: onTapConfirm),
  );
}

class WorldEventDialog extends StatelessWidget {
  final WorldEvent worldEvent;

  const WorldEventDialog(this.worldEvent, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          worldEvent.title,
          style: TextStyles.bold28,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5.0),
        Text(
          worldEvent.description,
          style: TextStyles.medium23,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10.0),
        Text(
          "Sectors Affected: ${worldEvent.sectorsAffected.length == BusinessSector.values.length ? "Everyone" : worldEvent.sectorsAffected.map((sector) => sector.name).join(", ")}",
          style: TextStyles.medium18,
        ),
      ],
    );
  }
}
