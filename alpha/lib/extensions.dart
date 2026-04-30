import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

extension PrettyFormatNumber on double {
  String get prettyCurrency =>
      NumberFormat.currency(symbol: "\$", decimalDigits: 2).format(this);
}

extension GetScreenDimensions on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

extension ShowDismissDialog on BuildContext {
  void showDialog(AlphaDialogBuilder builder) =>
      AlphaScaffold.of(this).showDialog(builder);
  void dismissDialog() => AlphaScaffold.of(this).dismissDialog();
}

extension ShowDismissAlphaSnackbar on BuildContext {
  void showSnackbar(
          {required String message,
          Duration duration = const Duration(seconds: 1)}) =>
      AlphaScaffold.of(this).showSnackbar(message: message, duration: duration);
}

extension Navigation on BuildContext {
  void navigateAndPopTo(Widget screen) => Navigator.of(this).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (BuildContext context) => screen),
      (route) => false);

  void navigateTo(Widget screen) => Navigator.of(this).push(
        CupertinoPageRoute(builder: (BuildContext context) => screen),
      );
}
