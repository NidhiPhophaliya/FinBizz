import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// Creates an animated button in the style of the game.
class AlphaButton extends StatefulWidget {
  final double width, height;
  final String title;
  final double? fontSize;
  final Color? color;
  final IconData? icon;
  final bool? disableIcon;

  /// Whether or not the button is disabled.\
  /// The button turns grey when disabled and [onTapDisabled] is called instead
  /// of [onTap] when the button is tapped.
  final bool disabled;

  /// The function called when the button is tapped while `disabled` is false.
  final void Function()? onTap;

  /// The function called when the button is tapped while `disabled` is true.
  final void Function()? onTapDisabled;

  const AlphaButton(
      {super.key,
      required this.width,
      this.height = 70.0,
      required this.title,
      this.color,
      this.icon,
      this.disabled = false,
      this.onTap,
      this.onTapDisabled,
      this.fontSize,
      this.disableIcon});

  /// Creates a default [AlphaButton] for the next action.
  static AlphaButton next({void Function()? onTap}) {
    return AlphaButton(
      width: 185.0,
      height: 70.0,
      title: "Next",
      icon: Icons.arrow_forward_rounded,
      onTap: onTap,
    );
  }

  @override
  State<AlphaButton> createState() => _AlphaButtonState();
}

class _AlphaButtonState extends State<AlphaButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hover = true),
      onTapCancel: () => setState(() => _hover = false),
      onTapUp: (_) => setState(() => _hover = false),
      onTap: !widget.disabled ? widget.onTap : widget.onTapDisabled,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 80),
        offset: _hover ? const Offset(0.04, 0.04) : Offset.zero,
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            padding: const EdgeInsets.fromLTRB(30.0, 5.0, 22.0, 5.0),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 4.0),
              borderRadius: BorderRadius.circular(14.0),
              boxShadow: !_hover
                  ? const <BoxShadow>[
                      BoxShadow(color: Colors.black, offset: Offset(4.0, 4.0))
                    ]
                  : null,
              color: !widget.disabled
                  ? (widget.color ?? const Color(0xffFF6B6B))
                  : const Color(0xFFBCBCBC),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: AutoSizeText(
                    widget.title.toUpperCase(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontFamily: "PublicSans",
                        fontWeight: FontWeight.w900,
                        fontSize: widget.fontSize ?? 24.0),
                  ),
                ),
                if (widget.disableIcon == null || widget.disableIcon == false)
                  Icon(widget.icon ?? Icons.arrow_forward_rounded, size: 32.0)
              ],
            )),
      ),
    );
  }
}
