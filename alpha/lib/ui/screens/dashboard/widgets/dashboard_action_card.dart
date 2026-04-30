import 'package:alpha/assets.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:flutter/material.dart';

class DashboardActionCard extends StatefulWidget {
  final String title;
  final String description;
  final AlphaAsset? image;
  final void Function()? onTap;

  const DashboardActionCard(
      {super.key,
      required this.title,
      required this.description,
      this.image,
      this.onTap});

  @override
  State<DashboardActionCard> createState() => _DashboardActionCardState();
}

class _DashboardActionCardState extends State<DashboardActionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _hover ? 1.02 : 1.0,
      duration: Durations.short4,
      curve: Curves.decelerate,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hover = true),
        onTapUp: (_) => setState(() => _hover = false),
        onTapCancel: () => setState(() => _hover = false),
        onTap: widget.onTap,
        child: AlphaContainer(
          width: 290.0,
          height: 350.0,
          child: Column(
            children: <Widget>[
              Container(
                  height: 180.0,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 203, 180),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                  ),
                  child: widget.image != null
                      ? Image.asset(
                          widget.image!.path,
                          fit: BoxFit.fitHeight,
                        )
                      : null),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15.0),
                    Text(
                      widget.title,
                      style: TextStyles.bold23,
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      widget.description,
                      style: TextStyles.medium15,
                    ),
                    Transform.translate(
                        offset: const Offset(215.0, 25.0),
                        child: const Icon(Icons.arrow_forward_ios_rounded))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget build2(BuildContext context) {
    return AnimatedScale(
      scale: _hover ? 1.02 : 1.0,
      duration: Durations.short2,
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _hover = true),
        onTapUp: (_) => setState(() => _hover = false),
        onTapCancel: () => setState(() => _hover = false),
        onTap: widget.onTap,
        child: AlphaContainer(
          width: 240.0,
          height: 320.0,
          child: Column(
            children: <Widget>[
              Container(
                  height: 160.0,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 203, 180),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                  ),
                  child: widget.image != null
                      ? Image.asset(
                          widget.image!.path,
                          fit: BoxFit.contain,
                        )
                      : null),
              const SizedBox(height: 20.0),
              Text(
                widget.title,
                style: TextStyles.bold24,
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyles.medium15,
                ),
              ),
              const SizedBox(height: 10.0),
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Transform.rotate(
                        angle: 3.14,
                        child: const Icon(Icons.arrow_back, size: 25.0)),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
