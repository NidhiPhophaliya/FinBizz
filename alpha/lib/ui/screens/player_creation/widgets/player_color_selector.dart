import 'package:flutter/material.dart';

class PlayerColorSelector extends StatelessWidget {
  final Color color;
  final bool selected;

  const PlayerColorSelector(
      {super.key, required this.color, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.1 : 1.0,
      duration: Durations.short3,
      curve: Curves.easeInOut,
      child: AnimatedContainer(
        duration: Durations.short4,
        curve: Curves.easeInOut,
        width: 70.0,
        height: 70.0,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border:
                Border.all(color: Colors.black, width: selected ? 4.5 : 3.5),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(0.0, 1.5))
            ]),
      ),
    );
  }
}
