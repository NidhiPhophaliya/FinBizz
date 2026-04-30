import 'package:alpha/extensions.dart';
import 'package:alpha/logic/car_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CarListing extends StatelessWidget {
  final Car car;
  final bool selected;

  const CarListing({super.key, required this.car, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: !selected ? Offset.zero : const Offset(0.05, 0.0),
      curve: Curves.decelerate,
      duration: Durations.medium1,
      child: AlphaAnimatedContainer(
          width: 360.0,
          height: 175.0,
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 100.0,
                height: double.infinity,
                child: Image.asset(
                  car.type.image.path,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 200.0,
                    child: AutoSizeText(car.name,
                        style: TextStyles.bold19.copyWith(height: 1.4),
                        maxLines: 1),
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    children: [
                      _GenericTitleValue(
                          title: "Car Type",
                          child: Text(
                            car.type.name,
                            style: TextStyles.bold20,
                          )),
                      const SizedBox(width: 14.0),
                      _GenericTitleValue(
                          title: "ESG",
                          child: Text(
                            car.esgBonus.toString(),
                            style: TextStyles.bold20,
                          )),
                      const SizedBox(width: 14.0),
                      _GenericTitleValue(
                          title: "Happiness",
                          child: Text(
                            car.happinessBonus.toString(),
                            style: TextStyles.bold20,
                          )),
                    ],
                  ),
                  _GenericTitleValue(
                      title: "Cost",
                      child: Text(
                        car.price.prettyCurrency,
                        style: TextStyles.bold20,
                      )),
                ],
              )
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
