import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DiceRollAnimation extends StatelessWidget {
  final AnimationController controller;
  const DiceRollAnimation({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LottieBuilder.asset(
      "assets/anim/dice_roll.json",
      controller: controller,
      frameRate: FrameRate.composition,
      renderCache: RenderCache.drawingCommands,
    );
  }
}
