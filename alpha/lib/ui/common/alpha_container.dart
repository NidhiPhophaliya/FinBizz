import 'package:flutter/material.dart';

/// Creates a [Container] that matches the default style of the the game.
class AlphaContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Alignment alignment;

  /// The [Offset] to use for the [BoxShadow] of the container.
  final Offset? shadowOffset;

  final Widget? child;

  const AlphaContainer(
      {super.key,
      this.width,
      this.height,
      this.padding,
      this.color,
      this.shadowOffset,
      this.alignment = Alignment.topLeft,
      this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.black, width: 4.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black,
                offset: shadowOffset ?? const Offset(0.5, 3.0))
          ]),
      child: child,
    );
  }
}

/// Animated version [AlphaContainer] that uses an [AnimatedContainer].
class AlphaAnimatedContainer extends AlphaContainer {
  /// The duration over which to animate the parameters of this container.
  final Duration duration;

  /// The curve to apply when animating the parameters of this container.
  final Curve curve;

  const AlphaAnimatedContainer(
      {super.key,
      this.duration = const Duration(milliseconds: 120),
      this.curve = Curves.linear,
      super.width,
      super.height,
      super.color,
      super.shadowOffset = const Offset(0.5, 3.0),
      super.padding,
      required super.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: duration,
        curve: curve,
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.black, width: 4.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black,
                  offset: shadowOffset ?? const Offset(0.5, 3.0))
            ]),
        child: child);
  }
}
