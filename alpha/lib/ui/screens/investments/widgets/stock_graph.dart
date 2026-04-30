import 'dart:math';

import 'package:alpha/logic/financial_market_logic.dart';
import 'package:alpha/ui/screens/investments/widgets/line_graph_painter.dart';
import 'package:flutter/material.dart';

class StockGraph extends StatelessWidget {
  final double width;
  final double height;
  final Stock stock;

  late final double yMax;
  late final double yMin;

  static const kPriceHistoryDuration = 10;

  final List<Point<double>> points =
      List.filled(StockGraph.kPriceHistoryDuration, const Point(0.0, 0.0));

  StockGraph(
      {super.key,
      required this.width,
      required this.height,
      required this.stock}) {
    final List<double> prices = stock.market.historicPrices.sublist(
        stock.market.historicPrices.length - StockGraph.kPriceHistoryDuration);

    /// Calculate scale
    final double dx = width / StockGraph.kPriceHistoryDuration;
    yMax = prices.reduce(max);
    yMin = prices.reduce(min);
    final double dy = height / (yMax - yMin);

    /// Scale the prices to fit the points
    for (int i = 0; i < prices.length; i++) {
      // Coordinate system (0, 0) at top left of canvas (height increases downwards)
      // y_scaled = distance between y to top of canvas (x, 0)
      //          = canvasHeight - (y - yMin) * dy
      // the height * factor term is to add some padding below the line
      final Point<double> point =
          Point(i * dx, height - (prices[i] - yMin) * dy - height * 0.1);
      points[i] = point;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: LineGraphPainter(points,
          color: stock.percentPriceChange(lastNth: kPriceHistoryDuration) == 0
              ? const Color(0xFF5B5B5B)
              : (stock.percentPriceChange(lastNth: kPriceHistoryDuration) < 0
                  ? const Color(0xffE15353)
                  : const Color(0xff3AB59E))),
    );
  }
}

class LargeStockGraph extends StockGraph {
  late final List<int> xLabel;
  late final List<int> yLabel;

  LargeStockGraph(
      {super.key,
      required super.width,
      required super.height,
      required super.stock});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: LineGraphPainter(points,
          hasGrid: true,
          yMax: yMax,
          yMin: yMin,
          xLabel: List.generate(20, (index) => index + 1),
          yLabel: List.generate(
              5,
              (index) => (yMin +
                  index *
                      (yMax - yMin) /
                      4)), // generate between min and max price
          strokeWidth: 5.0,
          color: stock.percentPriceChange() == 0
              ? const Color(0xFF5B5B5B)
              : (stock.percentPriceChange() < 0
                  ? const Color(0xffE15353)
                  : const Color(0xff3AB59E))),
    );
  }
}
