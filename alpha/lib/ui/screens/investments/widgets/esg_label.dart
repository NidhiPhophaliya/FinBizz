import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class ESGLabel extends StatelessWidget {
  final int esgRating;

  const ESGLabel(this.esgRating, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 95.0,
      height: 30.0,
      alignment: Alignment.center,
      transform: Matrix4.translation(Vector3(-3.0, 1.0, 0.0)),
      decoration: BoxDecoration(
        color: AlphaColors.green,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.black, width: 2.5),
      ),
      child: Transform.translate(
        offset: const Offset(-1.0, 0.5),
        child: Text("ESG $esgRating",
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
