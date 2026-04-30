import 'package:flutter/material.dart';

class AlphaAppBar extends StatelessWidget {
  final String? title;
  final void Function()? onTapBack;
  final bool hasBack;
  final Widget? action;

  const AlphaAppBar(
      {super.key,
      this.title,
      this.hasBack = true,
      this.onTapBack,
      this.action});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0.0,
      leading: hasBack
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (onTapBack != null) onTapBack!();
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.arrow_back,
                size: 28.0,
                color: Colors.black87,
              ),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            )
          : null,
      actions: (action != null)
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: action!,
              )
            ]
          : null,
    );
  }
}
