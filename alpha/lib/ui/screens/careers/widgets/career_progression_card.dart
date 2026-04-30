import 'package:alpha/extensions.dart';
import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:flutter/material.dart';

class CareerProgressionCard extends StatelessWidget {
  final Job job;
  final bool disabled;

  const CareerProgressionCard(
      {super.key, required this.job, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return AlphaContainer(
        child: Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 220.0,
          decoration: BoxDecoration(
              image: DecorationImage(
                  colorFilter: disabled
                      ? const ColorFilter.matrix(<double>[
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ])
                      : null,
                  image: AssetImage(job.asset.path),
                  fit: BoxFit.contain),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
              color: !disabled
                  ? const Color(0xffFEA079)
                  : const Color(0xffBDBDBD)),
        ),
        const SizedBox(height: 20.0),
        Text(job.career.title, style: TextStyles.bold20),
        Text(job.title, style: TextStyles.bold28),
        const SizedBox(height: 15.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GenericTitleValue(
              "Salary Per Round",
              job.salary.prettyCurrency,
              width: 150.0,
            ),
            const SizedBox(width: 15.0),
            _GenericTitleValue(
              "Level Required",
              "Level ${job.levelRequirement}",
              width: 140.0,
            )
          ],
        )
      ],
    ));
  }
}

class _GenericTitleValue extends StatelessWidget {
  final String title;
  final String value;
  final double width;

  const _GenericTitleValue(this.title, this.value, {this.width = 200.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style:
                  TextStyles.bold17.copyWith(color: const Color(0xFF383838))),
          Text(value, style: TextStyles.bold25),
        ],
      ),
    );
  }
}
