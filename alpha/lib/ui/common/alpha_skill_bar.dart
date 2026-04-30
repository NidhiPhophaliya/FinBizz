import 'dart:math';

import 'package:alpha/logic/skills_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class AlphaSkillBar extends StatelessWidget {
  final PlayerSkill skill;
  final double width;

  const AlphaSkillBar(this.skill, {super.key, this.width = 450.0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          // Outer white container
          width: width,
          height: 40.0,
          padding: const EdgeInsets.only(left: 35.0, right: 14.0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: Colors.black, width: 3.0),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Colors.black, offset: Offset(1.0, 2.0))
              ]),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double xpWidth = constraints.maxWidth - 118.0;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    /// Check whether enough space to display XP text
                    width: (constraints.maxWidth >= 200.0)
                        ? xpWidth
                        : constraints.maxWidth,
                    height: 12.0,
                    // Inner XP bar background / container
                    decoration: BoxDecoration(
                        color: const Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(color: Colors.black, width: 2.0)),
                  ),
                  ListenableBuilder(
                    listenable: skill,
                    builder: (context, _) => TweenAnimationBuilder<double>(
                        tween: Tween(
                            begin: 0.0, end: skill.levelPercent * xpWidth),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, _) {
                          return Container(
                            // Inner red XP bar
                            width: (value + 5.0).clamp(0, xpWidth),
                            height: 12.0,
                            decoration: BoxDecoration(
                                color: const Color(0xffFF6B6B),
                                borderRadius: BorderRadius.circular(50.0),
                                border: Border.all(
                                    color: Colors.black, width: 2.0)),
                          );
                        }),
                  ),
                  constraints.maxWidth >= 200.0
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(
                              "XP ${skill.levelExp} / ${PlayerSkill.xpPerLevel}",
                              style: TextStyles.bold15.copyWith(height: 2.45),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              );
            },
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: pi / 4,
              child: Container(
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                    color: AlphaColors.red,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(width: 2.0),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: Colors.black, offset: Offset(1.0, 1.0))
                    ]),
              ),
            ),
            Transform.translate(
              offset: const Offset(-0.5, 2.0),
              child: Text(skill.level.toString(),
                  style: TextStyles.bold21.copyWith(
                    color: Colors.black87,
                  )),
            ),
          ],
        ),
      ],
    );
  }
}

class AlphaSkillBarMedium extends StatelessWidget {
  final double width;
  final PlayerSkill skill;

  const AlphaSkillBarMedium(this.skill, {super.key, this.width = 500.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 45.0,
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
          border: Border.all(color: Colors.black, width: 3.0),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5))
          ]),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double xpWidth = constraints.maxWidth - 180.0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  const Text(
                    "Level ",
                    style: TextStyles.bold15,
                  ),
                  ListenableBuilder(
                    listenable: skill,
                    builder: (context, _) => Text(
                      "${skill.level}",
                      style: TextStyles.bold18.copyWith(height: 2.3),
                    ).animate().scale(
                        duration: Durations.long2,
                        delay: Durations.short4,
                        begin: const Offset(3.0, 3.0),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.easeOut),
                  )
                ],
              ),
              Stack(
                children: <Widget>[
                  Container(
                    width: xpWidth,
                    height: 12.0,
                    decoration: BoxDecoration(
                        color: const Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(color: Colors.black, width: 2.0)),
                  ),
                  ListenableBuilder(
                    listenable: skill,
                    builder: (context, _) => TweenAnimationBuilder(
                        tween: Tween<double>(
                            begin: 0.0, end: skill.levelPercent * xpWidth),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, value, _) => Container(
                              width: value.clamp(0.0, xpWidth),
                              height: 12.0,
                              decoration: value <= 5.0
                                  ? null
                                  : BoxDecoration(
                                      color: const Color(0xffFF6B6B),
                                      borderRadius: BorderRadius.circular(50.0),
                                      border: Border.all(
                                          color: Colors.black, width: 2.0)),
                            )),
                  ),
                ],
              ),
              SizedBox(
                width: 113.0,
                child: ListenableBuilder(
                  listenable: skill,
                  builder: (context, _) => Row(
                    children: [
                      const Text(
                        "XP",
                        textAlign: TextAlign.right,
                        style: TextStyles.bold15,
                      ),
                      const SizedBox(width: 5.0),
                      AnimatedNumber<int>(
                        skill.levelExp,
                        style: TextStyles.bold15,
                        duration: Durations.medium4,
                      ),
                      Text(
                        " / ${PlayerSkill.xpPerLevel}",
                        textAlign: TextAlign.right,
                        style: TextStyles.bold15,
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class AlphaSkillBarLarge extends StatelessWidget {
  final PlayerSkill skill;
  final double width;

  const AlphaSkillBarLarge(this.skill, {super.key, this.width = 750.0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: width,
          height: 55.0,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(color: Colors.black, width: 4.0),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Colors.black, offset: Offset(1.0, 1.0))
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                Container(
                  height: 12.0,
                  decoration: BoxDecoration(
                      color: const Color(0xffD9D9D9),
                      borderRadius: BorderRadius.circular(50.0),
                      border: Border.all(color: Colors.black, width: 2.0)),
                ),
                LayoutBuilder(
                  builder: (context, constraints) => ListenableBuilder(
                      listenable: skill,
                      builder: (context, child) =>
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                                begin: 0.0,
                                end: constraints.maxWidth * skill.levelPercent),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) => value >= 10.0
                                ? Container(
                                    width: value.clamp(0, constraints.maxWidth),
                                    height: 12.0,
                                    decoration: BoxDecoration(
                                        color: const Color(0xffFF6B6B),
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        border: Border.all(
                                            color: Colors.black, width: 2.0)),
                                  )
                                : const SizedBox.shrink(),
                          )),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            right: 20.0,
            child: Transform.translate(
              offset: const Offset(0.0, -28.0),
              child: ListenableBuilder(
                listenable: skill,
                builder: (context, child) => Text(
                  "XP ${skill.levelExp} / ${PlayerSkill.xpPerLevel}",
                  style: TextStyles.bold18,
                ),
              ),
            )),
        Positioned(
            left: 20.0,
            child: Transform.translate(
              offset: const Offset(0.0, -28.0),
              child: ListenableBuilder(
                listenable: skill,
                builder: (context, child) => Text(
                  "LEVEL ${skill.level}",
                  style: TextStyles.bold18,
                ),
              ),
            )),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              alignment: Alignment.center,
              transform: Matrix4.translation(Vector3(0, -30.0, 0)),
              padding: const EdgeInsets.only(top: 4.0, right: 2.0),
              width: 150.0,
              height: 40.0,
              decoration: BoxDecoration(
                  color: const Color(0xffFFBFCA),
                  borderRadius: BorderRadius.circular(50.0),
                  border: Border.all(color: Colors.black, width: 3.0),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5))
                  ]),
              child: const Text(
                "Skill Level",
                style: TextStyles.bold18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
