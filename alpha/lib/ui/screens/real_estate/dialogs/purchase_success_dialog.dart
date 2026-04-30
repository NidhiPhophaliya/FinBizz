import 'package:alpha/logic/real_estate_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

AlphaDialogBuilder buildBoughtRealEstateDialog(BuildContext context,
        RealEstate selectedRealEstate, void Function() onTapConfirm) =>
    AlphaDialogBuilder(
        title: "Congratulations",
        child: Column(
          children: <Widget>[
            const Text(
              "You have successfully bought",
              style: TextStyles.bold24,
            ),
            const SizedBox(height: 10.0),
            Text(
              selectedRealEstate.name,
              style: TextStyles.bold25,
            ),
            const SizedBox(height: 30.0)
          ],
        ),
        next: DialogButtonData(
            title: "Proceed", width: 380.0, onTap: onTapConfirm));
