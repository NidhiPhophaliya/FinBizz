import 'package:alpha/logic/data/player.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:flutter/material.dart';

class LifeGoalSelector extends StatelessWidget {
  final PlayerGoals goal;
  final bool selected;

  const LifeGoalSelector(
      {super.key, required this.goal, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.08 : 1.0,
      duration: Durations.short3,
      curve: Curves.easeInOut,
      child: AlphaContainer(
        width: 180.0,
        height: 205.0,
        color: const Color(0xFFFFFFEC),
        padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        shadowOffset: selected ? const Offset(0.0, 5.0) : null,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 95.0,
                  height: 95.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xfffcf7e8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xff000000),
                          offset: Offset(0, 4),
                        )
                      ],
                      border: Border.all(
                          color: const Color(0xff383838), width: 2.5)),
                ),
                Container(
                  width: 85.0,
                  height: 85.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xfffcf7e8),
                      border: Border.all(
                          color: const Color(0xff383838), width: 2.5)),
                ),
                SizedBox(
                  width: 95.0,
                  height: 95.0,
                  child: Image.asset(goal.image.path),
                )
              ],
            ),
            const SizedBox(height: 12.0),
            Text(goal.title, style: TextStyles.bold16),
            Text(goal.description,
                textAlign: TextAlign.center,
                style: TextStyles.medium13.copyWith(height: 1.6)),
          ],
        ),
      ),
    );
  }
}
