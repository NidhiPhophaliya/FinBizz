import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_unit_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

AlphaDialogBuilder buildStockUnitsInputDialog(BuildContext context,
    final StockUnitController controller, void Function() onTapConfirm) {
  final TextEditingController textController = TextEditingController();

  return AlphaDialogBuilder(
    title: "Select Units",
    child: StockUnitsInputDialog(controller, textController),
    cancel: DialogButtonData.cancel(context),
    next: DialogButtonData.confirm(onTap: () {
      controller.setUnits(int.tryParse(textController.text) ?? 0);
      onTapConfirm();
    }),
  );
}

class StockUnitsInputDialog extends StatelessWidget {
  final StockUnitController controller;
  final TextEditingController textController;

  const StockUnitsInputDialog(this.controller, this.textController,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text(
          "How many units would you like?",
          style: TextStyles.bold24,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10.0),
        SizedBox(
            width: 520.0,
            child: TextField(
              controller: textController,
              style: TextStyles.bold22,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
              decoration: InputDecoration(
                hintText: "Enter units",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.black, width: 3.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.black, width: 3.5),
                ),
              ),
            )),
        const SizedBox(height: 90.0),
      ],
    );
  }
}
