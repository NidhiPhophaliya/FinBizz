import 'package:flutter/material.dart';

class AlphaTagButton extends StatefulWidget {
  final double width;
  final double height;
  final String title;
  final Color? color;
  final void Function()? onTap;

  const AlphaTagButton(
      {super.key,
      required this.width,
      required this.height,
      required this.title,
      this.color,
      this.onTap});

  @override
  State<AlphaTagButton> createState() => _AlphaTagButtonState();
}

class _AlphaTagButtonState extends State<AlphaTagButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanDown: (_) => setState(() => _hover = true),
      onTapCancel: () => setState(() => _hover = false),
      onTapUp: (_) => setState(() => _hover = false),
      onTap: widget.onTap,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 40),
        offset: _hover ? const Offset(0, 0.08) : Offset.zero,
        child: AnimatedContainer(
          transformAlignment: Alignment.center,
          duration: const Duration(milliseconds: 40),
          alignment: Alignment.centerLeft,
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.only(left: 15.0, top: 1.0),
          decoration: BoxDecoration(
              color: widget.color ?? Colors.white,
              border: Border.all(color: Colors.black, width: 3.0),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: !_hover
                  ? const <BoxShadow>[
                      BoxShadow(color: Colors.black, offset: Offset(0, 1.5))
                    ]
                  : null),
          child: Text(
            widget.title,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 20.0),
          ),
        ),
      ),
    );
  }
}
