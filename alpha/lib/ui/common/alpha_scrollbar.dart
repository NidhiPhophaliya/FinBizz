import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';

class AlphaScrollbar extends StatelessWidget {
  final ScrollController controller;
  final Widget child;

  const AlphaScrollbar(
      {super.key, required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: controller,
      thumbColor: AlphaColors.red,
      trackColor: const Color(0xFFE0E0E0),
      trackVisibility: true,
      thumbVisibility: true,
      thickness: 10.0,
      shape: const StadiumBorder(
          side: BorderSide(color: Colors.black, width: 2.0)),
      trackRadius: const Radius.circular(15.0),
      trackBorderColor: Colors.transparent,
      child: child,
    );
  }
}
