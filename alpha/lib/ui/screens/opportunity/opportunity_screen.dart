import 'package:alpha/extensions.dart';
import 'package:alpha/logic/hints_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:alpha/ui/screens/opportunity/dialogs/draw_result_dialogs.dart';
import 'package:alpha/ui/screens/opportunity/dialogs/opportunity_landing_dialog.dart';
import 'package:alpha/ui/screens/opportunity/widgets/opportunity_card.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class OpportunityScreen extends StatefulWidget {
  const OpportunityScreen({super.key});

  @override
  State<OpportunityScreen> createState() => _OpportunityScreenState();
}

class _OpportunityScreenState extends State<OpportunityScreen>
    with SingleTickerProviderStateMixin {
  double _drawProgress = 0.0;

  late OpportunityCardController opportunityCardController =
      OpportunityCardController();

  void _handleCardDrawing(DragUpdateDetails details) {
    setState(() {
      double deltaP = details.delta.dx / 400.0;

      if (_drawProgress + deltaP > 1.0) {
        _drawProgress = 1.0;
      } else if (_drawProgress + deltaP < 0.0) {
        _drawProgress = 0.0;
      } else {
        _drawProgress += deltaP;
      }
    });
  }

  void _handleCardDrawEnd(BuildContext context) {
    setState(() {
      if (_drawProgress > 0.70) {
        _drawProgress = 1.0;
        opportunityCardController.openCard();

        Future.delayed(const Duration(milliseconds: 1000),
            () => _handleShowDrawResultDialog(context));
      } else {
        _drawProgress = 0.0;
      }
    });
  }

  void _handleShowDrawResultDialog(BuildContext context) {
    context.showDialog(buildOpportunityDrawResultDialog(
        context, opportunityManager.getCurrentOpportunity(), () {
      opportunityManager.applyOpportunity(activePlayer);
      context.dismissDialog();
      context.navigateTo(DashboardScreen());
    }));
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
        title: "Opportunity",
        onTapBack: () => Navigator.of(context).pop(),
        landingDialog:
            hintsManager.shouldShowHint(activePlayer, Hint.opportunity)
                ? AlphaDialogBuilder.dismissable(
                    title: "Welcome",
                    dismissText: "Try my luck",
                    width: 280.0,
                    child: const OpportunityLandingDialog())
                : null,
        children: [
          const SizedBox(height: 100.0),
          SizedBox(
            width: 700.0,
            child: Stack(
              children: [
                const Positioned(
                  top: 0.0,
                  bottom: 0.0,
                  right: 0.0,
                  child: SizedBox(
                    width: 200.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_rounded,
                            size: 180.0, color: Colors.black54),
                        Text("Drag to draw an opportunity card",
                            textAlign: TextAlign.center,
                            style: TextStyles.bold24)
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Transform(
                          origin: const Offset(175.0, 250.0),
                          transform:
                              Matrix4.translation(Vector3(-90.0, 0.0, 0.0)),
                          child: const OpportunityCardBack(
                            cardColor: Color(0xFF8DE791),
                          )),
                      Transform(
                          origin: const Offset(175.0, 225.0),
                          transform:
                              Matrix4.translation(Vector3(-60.0, 0.0, 0.0)),
                          child: const OpportunityCardBack(
                            cardColor: Color(0xFFEC89C9),
                          )),
                      Transform(
                          origin: const Offset(175.0, 225.0),
                          transform:
                              Matrix4.translation(Vector3(-30.0, 0.0, 0.0)),
                          child: const OpportunityCardBack(
                            cardColor: Color(0xFF7CB9EB),
                          )),
                      AnimatedPositioned(
                          duration: const Duration(milliseconds: 5),
                          curve: Curves.decelerate,
                          left: 400.0 * _drawProgress,
                          child: Builder(
                            builder: (context) => GestureDetector(
                              onPanUpdate: _handleCardDrawing,
                              onPanEnd: (_) => _handleCardDrawEnd(context),
                              onPanCancel: () => _handleCardDrawEnd(context),
                              child: FlippableOpportunityCard(
                                opportunity:
                                    opportunityManager.getCurrentOpportunity(),
                                controller: opportunityCardController,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          )
        ]);
  }
}
