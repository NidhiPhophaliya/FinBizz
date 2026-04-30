import 'package:alpha/assets.dart';
import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/should_render_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JobSelectionCard extends StatelessWidget {
  final Job job;
  final bool eligible;
  final bool disabled;
  final bool selected;
  const JobSelectionCard(
      {super.key,
      required this.job,
      this.eligible = true,
      this.disabled = false,
      this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 120),
      offset: !selected ? Offset.zero : const Offset(0.0, -0.03),
      child: AnimatedScale(
        scale: !selected ? 1.0 : 1.03,
        duration: const Duration(milliseconds: 120),
        child: Stack(
          children: <Widget>[
            Animate(
              child: AlphaAnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  shadowOffset: !selected
                      ? const Offset(0.5, 3.0)
                      : const Offset(5.0, 6.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 200.0,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0)),
                            color: !disabled
                                ? const Color(0xffFEA079)
                                : const Color(0xffBDBDBD)),
                      ),
                      const SizedBox(height: 20.0),
                      Column(
                        children: <Widget>[
                          Text(
                            job.title,
                            style: TextStyles.bold25,
                          ),
                          const SizedBox(height: 10.0),
                          JobDescriptionTagCollection(
                              job: job, disabled: disabled)
                        ],
                      ),
                    ],
                  )),
            ),
            _JobHeroImage(asset: job.asset, disabled: disabled),
            RenderIfFalse(condition: eligible, child: _IneligibleBanner())
          ],
        ),
      ),
    );
  }
}

class _JobHeroImage extends StatelessWidget {
  /// Widget for the hero image on each job card
  final AlphaAsset asset;
  final bool disabled;

  const _JobHeroImage({required this.asset, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0.0, -15.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: disabled
            ? ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
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
                ]),
                child: Image.asset(
                  asset.path,
                  height: 220.0,
                ),
              )
            : Image.asset(
                asset.path,
                height: 220.0,
              ),
      ),
    );
  }
}

class _IneligibleBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(0.0, -45.0)
            ..scale(1.06, 1.06, 1.0),
          width: 330.0,
          height: 45.0,
          padding: const EdgeInsets.only(top: 4.0),
          decoration: BoxDecoration(
              color: const Color(0xffEC5757),
              border: Border.all(color: Colors.black, width: 2.5),
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Colors.black, offset: Offset(1.0, 3.0))
              ]),
          child: const Text(
            "Ineligible",
            style: TextStyles.bold20,
          ),
        ));
  }
}

class _JobDescriptionTag extends StatelessWidget {
  final String title;
  final bool disabled;
  const _JobDescriptionTag({required this.title, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      height: 40.0,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3.0),
      decoration: BoxDecoration(
          color: !disabled ? const Color(0xffB5D2AD) : const Color(0xffBDBDBD),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.black, width: 2.5),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black, offset: Offset(0.5, 1.8))
          ]),
      child: Text(
        title,
        style: TextStyles.medium18,
      ),
    );
  }
}

class JobDescriptionTagCollection extends StatelessWidget {
  final Job job;
  final bool disabled;
  const JobDescriptionTagCollection(
      {super.key, required this.job, required this.disabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        verticalDirection: VerticalDirection.up,
        children: <Widget>[
          _JobDescriptionTag(
            title: "⭐ Level ${job.levelRequirement}",
            disabled: disabled,
          ),
          _JobDescriptionTag(
            title: "💵 \$${job.salary.toInt()}",
            disabled: disabled,
          ),
        ],
      ),
    );
  }
}
