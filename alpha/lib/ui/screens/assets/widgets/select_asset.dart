import 'package:alpha/assets.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:flutter/material.dart';

class SelectableAsset extends StatefulWidget {
  final String title;
  final String description;
  final AlphaAsset image;
  final Color color;
  final void Function()? onTap;

  const SelectableAsset(
      {super.key,
      required this.title,
      required this.description,
      required this.image,
      required this.color,
      this.onTap});

  @override
  State<SelectableAsset> createState() => _SelectableAssetState();
}

class _SelectableAssetState extends State<SelectableAsset> {
  bool _tappedDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap?.call(),
      onPanDown: (_) => setState(() => _tappedDown = true),
      onPanCancel: () => setState(() => _tappedDown = false),
      onPanEnd: (_) => setState(() => _tappedDown = false),
      child: AnimatedScale(
        duration: Durations.short3,
        curve: Curves.easeInOut,
        scale: _tappedDown ? 1.03 : 1.0,
        child: AlphaContainer(
          width: 380.0,
          height: 500.0,
          color: widget.color,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 40.0),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 240.0,
                    height: 240.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xfffcf7e8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xff000000),
                            offset: Offset(0, 4),
                          )
                        ],
                        border: Border.all(
                            color: const Color(0xff383838), width: 3.0)),
                  ),
                  Container(
                    width: 220.0,
                    height: 220.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xfffcf7e8),
                        border: Border.all(
                            color: const Color(0xff383838), width: 3.0)),
                  ),
                  SizedBox(
                    width: 230.0,
                    height: 230.0,
                    child: Image.asset(widget.image.path),
                  )
                ],
              ),
              const SizedBox(height: 25.0),
              Text(
                widget.title,
                style: TextStyles.bold24,
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: TextStyles.medium18.copyWith(height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
