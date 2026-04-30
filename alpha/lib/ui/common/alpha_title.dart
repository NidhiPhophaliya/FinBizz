import 'package:flutter/material.dart';

/// Creates a widget for the title text in the style of the game.
class AlphaTitle extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final Offset? shadowOffset;
  final double? strokeWidth;

  final Offset _defaultShadowOffset = const Offset(3.0, 3.0);
  final double _defaultStrokeWidth = 4.5;

  const AlphaTitle(this.text,
      {super.key,
      this.color,
      this.fontSize,
      this.shadowOffset,
      this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text(
          text.toUpperCase(),
          style: TextStyle(
              height: 0.0,
              letterSpacing: 1.8,
              fontFamily: "LexendMega",
              fontSize: fontSize ?? 30.0,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth ?? _defaultStrokeWidth
                ..strokeJoin = StrokeJoin.round
                ..color = Colors.black,
              shadows: <Shadow>[
                Shadow(
                    color: Colors.black,
                    offset: shadowOffset ?? _defaultShadowOffset)
              ]),
        ),
        Text(
          text.toUpperCase(),
          style: TextStyle(
              height: 0.0,
              letterSpacing: 1.8,
              fontFamily: "LexendMega",
              fontSize: fontSize ?? 30.0,
              color: color ?? const Color(0xffFF6B6B)),
        )
      ],
    );
  }
}
