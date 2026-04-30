import 'package:alpha/ui/common/should_render_widget.dart';
import 'package:flutter/material.dart';

class StockPriceChangeIndicator extends StatelessWidget {
  final double change;

  const StockPriceChangeIndicator({super.key, required this.change});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          "$change%",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22.0,
              color: change == 0
                  ? const Color(0xFF5B5B5B)
                  : (change < 0
                      ? const Color(0xffE15353)
                      : const Color(0xff3AB59E))),
        ),
        const SizedBox(width: 5.0),
        RenderIfTrue(
            condition: change != 0,
            child: Transform.translate(
              offset: const Offset(0, -3.5),
              child: Transform.rotate(
                angle: change <= 0 ? -1.571 : 1.571,
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: change < 0
                      ? const Color(0xffE15353)
                      : const Color(0xff3AB59E),
                  size: 24.0,
                ),
              ),
            )),
      ],
    );
  }
}
