import 'package:flutter/material.dart';

/// Creates a custom snackbar widget in the style of the game.\
/// This widget should only be used by [AlphaScaffold] and not be
/// created anywhere else.
class AlphaSnackbar extends StatefulWidget {
  /// The message to display in the snackbar.
  final String message;

  /// The [AnimationController] handling the animation of the snackbar.
  final AnimationController controller;

  const AlphaSnackbar(
      {super.key, required this.message, required this.controller});

  @override
  State<AlphaSnackbar> createState() => _AlphaSnackbarState();
}

class _AlphaSnackbarState extends State<AlphaSnackbar>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _snackAnimation;

  @override
  void initState() {
    /// The default time the snackbar takes to animate in or out.
    widget.controller.duration = const Duration(milliseconds: 1200);

    /// The animation basically translates the snackbar vertically between
    /// +65.0 (offscren) and -45.0 (in view), to show and hide the snackbar
    _snackAnimation = Tween<double>(begin: 65.0, end: -40.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(widget.controller);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _snackAnimation,
        builder: (BuildContext context, Widget? child) => Transform.translate(
              offset: Offset(0.0, _snackAnimation.value),
              child: Container(
                width: 630.0,
                height: 60.0,
                padding: const EdgeInsets.fromLTRB(20.0, .0, 20.0, .0),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 4.0),
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(1.0, 3.0),
                      )
                    ]),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
            ));
  }
}
