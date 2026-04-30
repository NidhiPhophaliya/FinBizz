import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_snackbar.dart';
import 'package:alpha/ui/common/alpha_title.dart';
import 'package:alpha/ui/common/should_render_widget.dart';
import 'package:flutter/material.dart';

/// Creates a widget that acts as the scaffolding for each screen of the game.
///
/// This widget is built on top of a [Scaffold], with custom implementations of \
/// [AlertDialog] using [AlphaAlertDialog] and [Snackbar] using [AlphaSnackbar].
///
/// To display the [AlphaAlertDialog] or [AlphaSnackbar], obtain
/// the [AlphaScaffoldState] for the current [BuildContext] via
/// [AlphaScaffold.of] and use [AlphaScaffoldState.showDialog] and
/// [AlphaScaffoldState.showSnackbar] methods respectively.
///
/// To obtain the [AlphaScaffoldState] from the [BuildContext] of the build
/// method in which the [AlphaScaffold] is being built, wrap the widget in a
/// [Builder] instead and access the new context from the [Builder].
class AlphaScaffold extends StatefulWidget {
  /// The top title to be displayed.
  final String title;

  /// The color of the title.
  final Color? titleColor;

  /// Whether or not to include default padding on the contents.
  final bool useDefaultPadding;

  /// The alignment used for the [Column] of the contents.
  final MainAxisAlignment? mainAxisAlignment;

  /// The function that is called when the back button is pressed.
  /// Note that the back button is not showed if `onTapBack` is null.
  final void Function()? onTapBack;

  /// The button that is shown at the bottom right corner of the screen.
  /// Typically an [AlphaButton] is used.
  final Widget? next;

  /// The [AlphaSnackbar] message to show when the screen is first rendered.
  /// The animation is played after a fixed delay after
  /// calling [AlphaScaffoldState.initState].
  final String? landingMessage;

  /// The [AlphaAlertDialog] to show when the screen is first rendered.
  final AlphaDialogBuilder? landingDialog;

  /// The children to be spreaded in the [Column] of the contents.
  final List<Widget> children;

  /// The background color of the scaffold.
  final Color? backgroundColor;

  const AlphaScaffold(
      {super.key,
      required this.title,
      this.titleColor,
      this.useDefaultPadding = false,
      this.mainAxisAlignment,
      this.onTapBack,
      this.next,
      this.landingMessage,
      this.landingDialog,
      required this.children,
      this.backgroundColor});

  /// Finds the [AlphaScaffoldState] from the closest instance of this class
  /// that encloses the given [BuildContext].
  /// Call this method to obtain an [AlphaScaffoldState] to
  /// display [AlphaAlertDialog] and [AlphaSnackbar].
  static AlphaScaffoldState of(BuildContext context) {
    AlphaScaffoldState? result =
        context.findAncestorStateOfType<AlphaScaffoldState>();

    if (result == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'AlphaScaffold.of() called with a context that does not contain a AlphaScaffold.',
        ),
        context.describeElement('The context used was'),
      ]);
    }

    return result;
  }

  @override
  State<AlphaScaffold> createState() => AlphaScaffoldState();
}

/// State for a [AlphaScaffold].
///
/// Can display [AlphaAlertDialog]s and [AlphaSnackbar]s. Retrieve a
/// [AlphaScaffoldState] from the current [BuildContext] using [Scaffold.of].
class AlphaScaffoldState extends State<AlphaScaffold>
    with SingleTickerProviderStateMixin {
  /// Placeholder dialog builder, will be replaced when showDialog() is called.
  AlphaDialogBuilder _dialogBuilder =
      const AlphaDialogBuilder(title: "", child: SizedBox());

  /// setState will be called on this flag to expand and close the dialog.
  bool _showAlphaDialog = false;
  final ScrollController _scrollController = ScrollController();

  late final AnimationController _snackbarController;

  /// Placeholder message for the snackbar, will be replaced when showSnackbar() is called.
  String _snackbarMessage = "";

  /// Shows the [AlphaSnackbar] with the message given.
  ///
  /// This method updates the [message] of the current [AlphaSnackbar] using
  /// [setState] and begin the [AlphaSnackbar]'s animation.
  void showSnackbar(
      {required String message,
      Duration duration = const Duration(seconds: 1)}) {
    if (_snackbarController.isAnimating) return;

    setState(() => _snackbarMessage = message);

    _snackbarController.forward();
    Future.delayed(
        duration,
        () => {
              if (mounted) {dismissSnackbar()}
            });
  }

  /// Dismisses the [AlphaSnackbar] if it is being animated.
  void dismissSnackbar() {
    if (_snackbarController.isCompleted || _snackbarController.isAnimating) {
      _snackbarController.reverse();
    }
  }

  /// Builds an [AlphaAlertDialog] from the [AlphaDialogBuilder] provided and
  /// shows the dialog.
  ///
  /// The existing [AlphaAlertDialog] is replaced by the new [AlphaAlertDialog]
  /// built based on [builder] provided.
  void showDialog(AlphaDialogBuilder builder) {
    if (_showAlphaDialog) {
      dismissDialog();
      Future.delayed(Durations.medium1, () => showDialog(builder));
      return;
    }

    setState(() {
      _dialogBuilder = builder;

      /// _showAlphaDialog is set to `true` which triggers
      /// the dialog to implicitly animate and show.
      _showAlphaDialog = true;
    });
  }

  /// Dismisses the current [AlphaAlertDialog].
  void dismissDialog() {
    /// _showAlphaDialog is set to `false` which triggers
    /// the dialog to implicitly animate and close.
    setState(() => _showAlphaDialog = false);
  }

  @override
  void initState() {
    _snackbarController = AnimationController(vsync: this);

    /// Shows the landing message via the [AlphaSnackbar] after a 500ms delay,
    /// if not null.
    if (widget.landingMessage != null) {
      Future.delayed(
          const Duration(milliseconds: 500),
          () => showSnackbar(
              message: widget.landingMessage!,
              duration: const Duration(seconds: 3)));
    }

    if (widget.landingDialog != null) {
      AlphaDialogBuilder oldDialog = widget.landingDialog!;

      Widget child = oldDialog.child;
      AlphaDialogBuilder dialog = AlphaDialogBuilder(
        title: oldDialog.title,
        child: child,
        next: oldDialog.next == null
            ? null
            : DialogButtonData(
                title: oldDialog.next!.title,
                width: oldDialog.next!.width,
                height: oldDialog.next!.height,
                onTap: oldDialog.next!.onTap ?? () => dismissDialog(),
              ),
        cancel: oldDialog.cancel == null
            ? null
            : DialogButtonData(
                title: oldDialog.cancel!.title,
                width: oldDialog.cancel!.width,
                height: oldDialog.cancel!.height,
                onTap: oldDialog.cancel!.onTap ?? () => dismissDialog(),
              ),
      );

      Future.delayed(
          const Duration(milliseconds: 250), () => showDialog(dialog));
    }
    super.initState();
  }

  @override
  void dispose() {
    _snackbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: widget.backgroundColor ?? const Color(0xffFCF7E8),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              const SizedBox(height: 35.0),
              _AlphaScaffoldAppBar(
                  title: widget.title,
                  titleColor: widget.titleColor,
                  onTapBack: widget.onTapBack),
              _AlphaScaffoldContents(
                  mainAxisAlignment: widget.mainAxisAlignment,
                  useDefaultPadding: widget.useDefaultPadding,
                  next: widget.next,
                  children: widget.children)
            ],
          ),
          _AlphaScaffoldSnackbar(
              snackbarMessage: _snackbarMessage,
              snackbarController: _snackbarController),
          RenderIfTrue(
              condition: _showAlphaDialog,
              child: Container(color: const Color(0x78565656))),
          _AlphaScaffoldDialog(
              controller: _scrollController,
              showAlphaDialog: _showAlphaDialog,
              dialogBuilder: _dialogBuilder),
        ],
      ),
    );
  }
}

/// Creates a widget for the top app bar containing a back button and the
/// screen title in the [AlphaScaffold].
///
/// This widget should only be used by [AlphaScaffold].
class _AlphaScaffoldAppBar extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final void Function()? onTapBack;

  const _AlphaScaffoldAppBar(
      {required this.title, this.titleColor, required this.onTapBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        RenderIfNotNull(
            nullable: onTapBack,
            child: _AlphaScaffoldTapBack(onTapBack: onTapBack)),
        Align(
          alignment: Alignment.center,
          child: AlphaTitle(
            title,
            color: titleColor,
            fontSize: 40.0,
          ),
        ),
      ],
    );
  }
}

/// Creates a widget for the back button in [_AlphaScaffoldAppBar] in the
/// [AlphaScaffold]
///
/// This widget should only be used by [AlphaScaffold].
class _AlphaScaffoldTapBack extends StatelessWidget {
  final void Function()? onTapBack;
  const _AlphaScaffoldTapBack({required this.onTapBack});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Stack(
          children: [
            const Icon(Icons.arrow_back_rounded, size: 38.0),
            GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onTapBack,
                child: const SizedBox(width: 55.0, height: 50.0)),
          ],
        ),
      ),
    );
  }
}

class _AlphaScaffoldContents extends StatelessWidget {
  final MainAxisAlignment? mainAxisAlignment;
  final Widget? next;
  final List<Widget> children;
  final bool useDefaultPadding;

  const _AlphaScaffoldContents(
      {required this.mainAxisAlignment,
      required this.useDefaultPadding,
      required this.children,
      required this.next});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Stack(
      children: [
        // The SizedBox.expand will give constraints to the Column
        SizedBox.expand(
          child: Padding(
            padding: useDefaultPadding
                ? const EdgeInsets.symmetric(horizontal: 50.0)
                : EdgeInsets.zero,
            child: Column(
              mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomRight,
            child: Padding(
                padding: const EdgeInsets.only(right: 50.0, bottom: 50.0),
                child: next)),
      ],
    ));
  }
}

/// Creates a widget for the [AlphaSnackbar] in the [AlphaScaffold].
///
/// This widget should only be used by [AlphaScaffold].
class _AlphaScaffoldSnackbar extends StatelessWidget {
  final String snackbarMessage;
  final AnimationController snackbarController;

  const _AlphaScaffoldSnackbar(
      {required this.snackbarMessage, required this.snackbarController});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: AlphaSnackbar(
            message: snackbarMessage, controller: snackbarController));
  }
}

/// Creates a widget for the [AlphaAlertDialog] in the [AlphaScaffold].
///
/// This widget should only be used by [AlphaScaffold].
class _AlphaScaffoldDialog extends StatelessWidget {
  final AlphaDialogBuilder dialogBuilder;
  final bool showAlphaDialog;

  final ScrollController controller;

  const _AlphaScaffoldDialog(
      {required this.controller,
      required this.showAlphaDialog,
      required this.dialogBuilder});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Align(
        alignment: Alignment.center,
        child: AlphaAlertDialog(
          scollController: controller,
          title: dialogBuilder.title,
          show: showAlphaDialog,
          next: dialogBuilder.next,
          cancel: dialogBuilder.cancel,
          child: dialogBuilder.child,
        ),
      ),
    );
  }
}

/// Helper class to build an [AlphaAlertDialog].
class AlphaDialogBuilder {
  final String title;
  final Widget child;
  final double? height;
  final DialogButtonData? next;
  final DialogButtonData? cancel;

  static dismissable(
      {required String title,
      required String dismissText,
      double width = 350.0,
      required Widget child}) {
    return AlphaDialogBuilder(
        title: title,
        child: child,
        next: DialogButtonData(title: dismissText, width: width));
  }

  const AlphaDialogBuilder(
      {required this.title,
      required this.child,
      this.height,
      this.next,
      this.cancel});
}
