import 'package:alpha/extensions.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/should_render_widget.dart';
import 'package:flutter/material.dart';

class EducationCard extends StatelessWidget {
  final String title;
  final String description;
  final double cost;
  final int xp;
  final bool selected;
  final bool affordable;
  const EducationCard(
      {super.key,
      required this.cost,
      required this.xp,
      required this.title,
      required this.description,
      this.selected = false,
      this.affordable = true});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 120),
      offset: !selected ? Offset.zero : const Offset(0.0, -0.03),
      child: AnimatedScale(
        scale: !selected ? 1.0 : 1.07,
        duration: const Duration(milliseconds: 120),
        child: Stack(
          children: <Widget>[
            AlphaAnimatedContainer(
                width: 400.0,
                height: 250.0,
                duration: const Duration(milliseconds: 120),
                shadowOffset:
                    !selected ? const Offset(0.5, 3.0) : const Offset(5.0, 6.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0, top: 10.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text("+${xp.toString()} xp",
                            style: const TextStyle(
                                fontSize: 25.0,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF61D465))),
                      ),
                    ),
                    SizedBox(
                      height: 120.0,
                      child: Column(
                        children: <Widget>[
                          Text(title, style: TextStyles.bold22),
                          const SizedBox(height: 4.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: Text(
                              description,
                              textAlign: TextAlign.center,
                              style: TextStyles.medium15.copyWith(height: 1.6),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: Container(
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            border: const Border(
                                top: BorderSide(
                              color: Colors.black,
                              width: 4.0,
                            )),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15.0),
                                bottomRight: Radius.circular(15.0)),
                            color: affordable
                                ? const Color(0xffFEA079)
                                : const Color(0xffBDBDBD)),
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "💵",
                                style: TextStyle(
                                  fontSize: 28.0,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text("-${cost.prettyCurrency}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22.0,
                                      color: Color.fromARGB(255, 233, 16, 0))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
            RenderIfFalse(condition: affordable, child: _UnaffordableBanner())
          ],
        ),
      ),
    );
  }
}

class _UnaffordableBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.topLeft,
      transform: Matrix4.identity()
        ..rotateZ(-0.5236)
        ..translate(-40.0, 20.0),
      child: Container(
        alignment: Alignment.center,
        width: 110.0,
        height: 35.0,
        padding: const EdgeInsets.only(top: 4.0),
        decoration: BoxDecoration(
          color: const Color(0xffEC5757),
          border: Border.all(color: Colors.black, width: 2.5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black, offset: Offset(1.0, 3.0))
          ],
        ),
        child: const Text(
          "Cannot Afford",
          style: TextStyles.bold13,
        ),
      ),
    );
  }
}
