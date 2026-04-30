import 'package:alpha/extensions.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scrollbar.dart';
import 'package:alpha/ui/common/should_render_widget.dart';
import 'package:flutter/material.dart';

/// Creates a custom alert dialog widget in the style of the game.\
/// This widget should only be used by [AlphaScaffold] and not be
/// created anywhere else.
class AlphaAlertDialog extends StatelessWidget {
  final ScrollController scollController;

  /// The top title of the dialog.
  final String title;

  /// The properties of the "next" and cancel buttons of the dialog.
  final DialogButtonData? next;
  final DialogButtonData? cancel;

  /// The child to display below the title.
  final Widget child;

  /// Whether or not to show the dialog.
  final bool show;

  /// The height of the dialog.
  final double? height;

  const AlphaAlertDialog(
      {super.key,
      required this.title,
      required this.child,
      required this.scollController,
      this.next,
      this.cancel,
      this.height,
      this.show = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: AnimatedContainer(
        margin: show ? const EdgeInsets.all(10.0) : EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 0.0, minHeight: 0.0),
        duration: show ? const Duration(milliseconds: 800) : Durations.short4,
        curve: show ? Curves.elasticOut : Curves.decelerate,

        /// Animates the dialog expanding and closing, when the
        /// widget's `show` property changes
        width: show ? 650.0 : 0.0,
        height: show ? (height ?? 400.0) : 0.0,
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            color: const Color(0xffFCF7E8),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(color: Colors.black, width: 4.5),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Colors.black, offset: Offset(1.0, 5.0))
            ]),

        /// Scale the contents of the dialog as it expands and closes.
        child: RenderIfTrue(
          condition: show,
          child: FittedBox(
              fit: BoxFit.contain,
              child: _AlertDialogContents(
                title: title,
                next: next,
                cancel: cancel,
                scrollController: scollController,
                child: child,
              )),
        ),
      ),
    );
  }
}

/// Helper class to encapsulate the parameters of the buttons of [AlphaAlertDialog].
class DialogButtonData {
  final String title;
  final double width;
  final double height;
  final void Function()? onTap;

  const DialogButtonData(
      {required this.title,
      this.width = 280.0,
      this.height = 60.0,
      this.onTap});

  /// Creates a [DialogButtonData] for a default `Cancel` button.
  static DialogButtonData cancel(BuildContext context) =>
      DialogButtonData(title: "Cancel", onTap: () => context.dismissDialog());

  /// Creates a [DialogButtonData] for a default `Confirm` button
  static DialogButtonData confirm({void Function()? onTap}) =>
      DialogButtonData(title: "Confirm", onTap: onTap);
}

/// Creates a widget for the contents of the [AlphaAlertDialog].
class _AlertDialogContents extends StatelessWidget {
  /// The top title of the alert dialog.
  final String title;

  /// The data of the `next` button of the alert dialog.
  final DialogButtonData? next;

  /// The data of the `cancel` button of the alert dialog.
  final DialogButtonData? cancel;

  /// The `child` to display below the title.
  final Widget child;

  final ScrollController scrollController;

  const _AlertDialogContents(
      {required this.title,
      this.next,
      this.cancel,
      required this.child,
      required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 348.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: const TextStyle(
                fontFamily: "LexendMega",
                fontWeight: FontWeight.w700,
                fontSize: 34.0),
          ),
          const SizedBox(height: 10.0),
          Container(
            height: 3.0,
            width: 300.0,
            decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10.0)),
          ),
          const SizedBox(height: 15.0),
          Expanded(
              child: AlphaScrollbar(
                  controller: scrollController,
                  child: SingleChildScrollView(
                      controller: scrollController,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: 585.0, minHeight: 195.0),
                        child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Center(child: child)),
                      )))),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              cancel != null
                  ? AlphaButton(
                      width: cancel!.width,
                      height: cancel!.height,
                      title: cancel!.title,
                      onTap: cancel!.onTap,
                      icon: Icons.arrow_forward_rounded,
                    )
                  : const SizedBox(),
              RenderIfAllNotNull(
                  nullables: [next, cancel],
                  child: const SizedBox(width: 20.0)),
              next != null
                  ? AlphaButton(
                      width: next!.width,
                      height: next!.height,
                      title: next!.title,
                      color: const Color.fromARGB(255, 164, 211, 151),
                      onTap: next!.onTap,
                      icon: Icons.arrow_forward_rounded,
                    )
                  : const SizedBox()
            ],
          )
        ],
      ),
    );
  }
}
