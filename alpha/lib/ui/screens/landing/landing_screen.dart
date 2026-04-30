import 'package:alpha/assets.dart';
import 'package:alpha/main.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  final void Function()? onTapNext;
  const LandingScreen({super.key, this.onTapNext});

  

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(title: "", children: [
      Expanded(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                const SizedBox(height: 30.0),
                SizedBox(
                    width: 800.0,
                    height: 450.0,
                    child: Image.asset(AlphaAsset.logoCashflow.path)),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AlphaButton(
                      width: 340.0,
                      title: "Start Game",
                      color: AlphaColors.green,
                      onTap: onTapNext,
                    ),
                    const SizedBox(width: 20.0),
                  ],
                ),
              ],
            ),
          ],
        ),
      )
    ]);
  }
}
