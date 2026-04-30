import 'package:alpha/extensions.dart';
import 'package:flutter/material.dart';

/// A generic widget that animates changes to a number over a duration.
/// It is ysed throughout the game to animate any dynamic values.
class AnimatedValue<T extends num> extends StatelessWidget {
  /// The [num] value to animate to.
  final T value;

  /// The [TextStyle] to apply to the [Text] of the animated value.
  final TextStyle? style;

  /// The [Duration] of the animation.
  final Duration? duration;

  /// Whether the value should be formatted as a currency, ie $1,000.00.
  final bool currency;

  /// Creates a widget that animates changes to a given value over a duration.
  const AnimatedValue(this.value,
      {super.key, this.style, this.duration, this.currency = false});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(
        begin: 0.0,
        end: value.toDouble(),
      ),
      duration: this.duration ?? Durations.medium3,
      builder: (BuildContext context, double value, Widget? child) => Text(
        currency
            ? value.prettyCurrency
            : (T is double ? value.toStringAsFixed(2) : value.toString()),
        style: style,
      ),
    );
  }
}
