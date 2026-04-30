import 'package:alpha/extensions.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// An animated number widget that animates from 0 to the given number, and its
/// subsequent changes.
class AnimatedNumber<T extends num> extends StatelessWidget {
  final T value;
  final Duration? duration;
  final Duration? delay;
  final bool formatCurrency;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AnimatedNumber(this.value,
      {super.key,
      this.duration,
      this.delay,
      this.style,
      this.textAlign,
      this.formatCurrency = false});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: delay ?? Durations.short4,
        builder: (context, v, _) {
          if (v == 1) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: value.toDouble()),
              duration: this.duration ?? Durations.medium4,
              builder: (BuildContext context, double anim, Widget? child) =>
                  AutoSizeText(
                maxLines: 1,
                formatCurrency
                    ? anim.toDouble().prettyCurrency
                    : anim.toStringAsFixed(T == int ? 0 : 2),
                style: style ??
                    const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 40.0),
                textAlign: textAlign ?? TextAlign.start,
              ),
            );
          }

          return AutoSizeText(
            maxLines: 1,
            formatCurrency ? "\$0.00" : "0",
            textAlign: textAlign,
            style: style ??
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
          );
        });
  }
}
