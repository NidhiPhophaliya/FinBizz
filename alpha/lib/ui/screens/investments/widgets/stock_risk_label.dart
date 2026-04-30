import 'package:alpha/logic/data/stocks.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class StockRiskLabel extends StatelessWidget {
  final StockRisk risk;

  const StockRiskLabel({super.key, required this.risk});

  static const riskColors = {
    StockRisk.low: Color(0xFF4AC170),
    StockRisk.medium: Color(0xFFE89A47),
    StockRisk.high: Color(0xFFE45757),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.0,
      height: 30.0,
      alignment: Alignment.center,
      transform: Matrix4.translation(Vector3(-3.0, 1.0, 0.0)),
      decoration: BoxDecoration(
        color: riskColors[risk],
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.black, width: 2.5),
      ),
      child: Transform.translate(
        offset: const Offset(-1.0, 0.5),
        child: Text(risk.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
