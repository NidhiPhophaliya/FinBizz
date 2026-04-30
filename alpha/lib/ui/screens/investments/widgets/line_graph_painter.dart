import 'dart:math';

import 'package:flutter/material.dart';

/// WARNING! I had no idea what this class is doing. I just yolod until the view looked correct.
class LineGraphPainter extends CustomPainter {
  final bool hasGrid;
  final double strokeWidth;
  final Color color;
  final int startNumber;

  final List<int>? xLabel;
  final List<double>? yLabel;

  final double yMax;
  final double yMin;

  final List<Point<double>> points;

  static const translateX = 20.0;
  static const kGridNumLines = 5;

  LineGraphPainter(this.points,
      {this.hasGrid = false,
      this.strokeWidth = 2.5,
      this.startNumber = 1,
      this.xLabel,
      this.yLabel,
      this.yMax = 0.0,
      this.yMin = 0.0,
      this.color = const Color(0xffDF4141)});

  void _drawGrid(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = const Color(0xFFA9A9A9).withValues(alpha: 0.3)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    for (int i = 0; i < kGridNumLines; i++) {
      final dy = i * (size.height / (kGridNumLines - 1)) - 20.0;
      canvas.drawLine(Offset(20.0, dy), Offset(size.width, dy), gridPaint);
    }
  }

  void _drawLineFill(Canvas canvas, Size size) {
    final Paint fillPaint = Paint()
      // ..color = const Color(0xffDF4141).withOpacity(0.2)
      ..shader = LinearGradient(colors: [
        color.withValues(alpha: 0.5),
        color.withValues(alpha: 0.01),
      ], transform: const GradientRotation(1.571))
          .createShader(Rect.fromPoints(Offset(points.first.x, points.first.y),
              Offset(points.last.x, points.last.y)))
      ..style = PaintingStyle.fill;

    final Path path = Path();
    path.moveTo(points.first.x - 1.5 + translateX, size.height);
    for (final point in points) {
      /// Offset the first and last points to account for the stroke width and
      /// rounded edges
      if (point == points.first) {
        path.lineTo(point.x - 1.5 + translateX, point.y);
        continue;
      }

      if (point == points.last) {
        path.lineTo(point.x + 1.5 + translateX, point.y);
        continue;
      }
      path.lineTo(point.x + translateX, point.y);
    }

    path.lineTo(points.last.x + 1.5 + translateX, size.height);
    path.close();
    canvas.drawPath(path, fillPaint);
  }

  void _drawPriceLine(Canvas canvas) {
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = Offset(points[i].x + translateX, points[i].y);
      final p2 = Offset(points[i + 1].x + translateX, points[i + 1].y);
      canvas.drawLine(p1, p2, linePaint);
    }
  }

  void _drawXLabels(Canvas canvas, Size size) {
    const style = TextStyle(
        color: Color.fromARGB(255, 156, 156, 156),
        fontSize: 12.0,
        fontFamily: "MazzardH",
        fontWeight: FontWeight.w700);

    final TextPainter labelPainter = TextPainter(
        text: const TextSpan(text: "Historical Prices", style: style),
        textDirection: TextDirection.ltr);

    labelPainter.layout();
    labelPainter.paint(canvas,
        Offset((size.width - labelPainter.width) / 2, size.height + 20.0));
  }

  void _drawYLabels(Canvas canvas, Size size) {
    const style = TextStyle(
        color: Color.fromARGB(255, 156, 156, 156),
        fontSize: 12.0,
        fontFamily: "MazzardH",
        fontWeight: FontWeight.w700);

    final TextPainter painter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < kGridNumLines; i++) {
      painter.text = TextSpan(
          text: yLabel![kGridNumLines - i - 1].toStringAsFixed(1),
          style: style);
      painter.layout();

      final Offset offset =
          Offset(-12.0, i * (size.height / (kGridNumLines - 1)) - 26.0);
      painter.paint(canvas, offset);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    if (hasGrid) {
      _drawGrid(canvas, size);
      _drawXLabels(canvas, size);
      _drawYLabels(canvas, size);
    }
    _drawLineFill(canvas, size);
    _drawPriceLine(canvas);
  }

  @override
  bool shouldRepaint(covariant LineGraphPainter oldDelegate) {
    if (oldDelegate.points.length != points.length) return true;

    for (int i = 0; i < points.length; i++) {
      if (oldDelegate.points[i] != points[i]) return true;
    }

    return false;
  }
}
