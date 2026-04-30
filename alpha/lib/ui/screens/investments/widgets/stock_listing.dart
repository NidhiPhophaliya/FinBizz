import 'package:alpha/extensions.dart';
import 'package:alpha/logic/financial_market_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_graph.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_risk_label.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_sector_card.dart';
import 'package:flutter/material.dart';

class StockListing extends StatelessWidget {
  final Stock stock;
  final bool selected;

  const StockListing({super.key, required this.stock, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: !selected ? Offset.zero : const Offset(0.05, 0.0),
      curve: Curves.decelerate,
      duration: Durations.medium1,
      child: AlphaAnimatedContainer(
          width: 340.0,
          height: 160.0,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    stock.code,
                    style: TextStyles.bold22,
                  ),
                  const SizedBox(width: 10.0),
                  Builder(
                    builder: (context) {
                      final double percentPriceChange =
                          stock.percentPriceChange(
                              lastNth: StockGraph.kPriceHistoryDuration);

                      return Text(
                        "$percentPriceChange%",
                        style: TextStyle(
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            fontSize: 22.0,
                            color: percentPriceChange == 0
                                ? const Color(0xFF5B5B5B)
                                : (percentPriceChange < 0
                                    ? const Color(0xffE15353)
                                    : const Color(0xff3AB59E))),
                      );
                    },
                  ),
                  const SizedBox(width: 5.0),
                  Builder(builder: (context) {
                    final double percentPriceChange = stock.percentPriceChange(
                        lastNth: StockGraph.kPriceHistoryDuration);

                    if (percentPriceChange == 0) {
                      return const SizedBox.shrink();
                    }

                    return Transform.translate(
                      offset: const Offset(0, -3.5),
                      child: Transform.rotate(
                        angle: percentPriceChange <= 0 ? -1.571 : 1.571,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: percentPriceChange < 0
                              ? const Color(0xffE15353)
                              : const Color(0xff3AB59E),
                          size: 24.0,
                        ),
                      ),
                    );
                  }),
                  Expanded(
                      child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: StockGraph(
                            width: 100.0, height: 30.0, stock: stock)),
                  ))
                ],
              ),
              UnconstrainedBox(
                  child: Transform.translate(
                      offset: const Offset(-2.0, 0.0),
                      child: StockSectorCard(stock.item.sector))),
              const SizedBox(height: 7.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _GenericTitleValue(
                      title: "Risk Level",
                      child: StockRiskLabel(risk: stock.risk)),
                  const SizedBox(width: 15.0),
                  _GenericTitleValue(
                      title: "ESG Score",
                      child: Text(
                          stock.esgRating == 0
                              ? "N/A"
                              : "${stock.esgRating} ♻️",
                          style: TextStyle(
                              fontSize: stock.esgRating > 0 ? 24.0 : 20.0,
                              fontWeight: FontWeight.w700))),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: _GenericTitleValue(
                        title: "Share Price",
                        child: Text(stock.price.prettyCurrency,
                            style: TextStyles.bold23)),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

class _GenericTitleValue extends StatelessWidget {
  final String title;
  final Widget child;

  const _GenericTitleValue({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyles.bold14,
        ),
        const SizedBox(height: 3.0),
        child,
      ],
    );
  }
}
