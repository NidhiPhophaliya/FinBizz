import 'package:alpha/assets.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:flutter/material.dart';

class BudgetingTile extends StatelessWidget {
  final String title;
  final int proportion;
  final double amount;
  final void Function()? onIncrement;
  final void Function()? onDecrement;
  final void Function()? showInfo;

  const BudgetingTile(
      {super.key,
      required this.title,
      required this.proportion,
      required this.amount,
      this.onIncrement,
      this.onDecrement,
      this.showInfo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: onIncrement,
          child: Transform.rotate(
            angle: 1.571,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 40.0,
            ),
          ),
        ),
        const SizedBox(height: 5.0),
        AlphaContainer(
          width: 200.0,
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: showInfo,
                    child: const Padding(
                        padding:
                            EdgeInsets.only(top: 8.0, right: 10.0, bottom: 2.0),
                        child: Icon(Icons.info_outline_rounded)),
                  )),
              Text(
                title,
                style: TextStyles.bold19,
              ),
              Text("${proportion * 10}%", style: TextStyles.bold45),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.0, end: amount),
                duration: Durations.medium3,
                builder: (BuildContext context, double value, Widget? child) =>
                    Text(
                  "\$${value.toStringAsFixed(2)}",
                  style: TextStyles.bold30,
                ),
              ),
              SizedBox(
                  width: 110.0,
                  height: 110.0,
                  child: () {
                    double proportion = this.proportion * 10;

                    if (proportion >= 80) {
                      return Image.asset(AlphaAsset.budgetingJar100.path);
                    }

                    if (proportion >= 50) {
                      return Image.asset(AlphaAsset.budgetingJar75.path);
                    }

                    if (proportion >= 30) {
                      return Image.asset(AlphaAsset.budgetingJar50.path);
                    }

                    if (proportion >= 10) {
                      return Image.asset(AlphaAsset.budgetingJar25.path);
                    }

                    return Image.asset(AlphaAsset.budgetingJar0.path);
                  }()),
            ],
          ),
        ),
        const SizedBox(height: 10.0),
        GestureDetector(
          onTap: onDecrement,
          child: Transform.rotate(
            angle: -1.571,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 40.0,
            ),
          ),
        ),
      ],
    );
  }
}
