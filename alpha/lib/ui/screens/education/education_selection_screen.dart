import 'package:alpha/extensions.dart';
import 'package:alpha/logic/education_logic.dart';
import 'package:alpha/logic/hints_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_skill_bar.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:alpha/ui/screens/education/dialogs/education_confirm_dialog.dart';
import 'package:alpha/ui/screens/education/dialogs/educaton_success_dialog.dart';
import 'package:alpha/ui/screens/education/dialogs/education_landing_dialog.dart';
import 'package:alpha/ui/screens/education/widgets/education_card.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class EducationSelectionScreen extends StatefulWidget {
  const EducationSelectionScreen({super.key});

  @override
  State<EducationSelectionScreen> createState() =>
      _EducationSelectionScreenState();
}

class _EducationSelectionScreenState extends State<EducationSelectionScreen> {
  EducationSelection? _selection;
  late final ConfettiController confettiController;

  late final PlayerEducation education =
      educationManager.getEducation(activePlayer);

  /// All possible education selection options
  late final List<EducationSelection> _selections = [
    EducationSelection(0,
        title: "Pursue ${education.getNext().title}",
        description:
            "Further your education to significantly improve your skill XP and unlock more job oppurtunities.",
        cost: education.getNext().cost,
        xp: education.getNext().xp,
        action: () => educationManager.pursueNext(activePlayer)),
    EducationSelection(1,
        title: "Study Online Course",
        description:
            "Study an online course to slightly improve your skill XP.",
        cost: EducationManager.kOnlineCoursePrice,
        xp: EducationManager.kOnlineCourseXP,

        /// Pursue online course on activePlayer
        action: () => educationManager.pursueOnlineCourse(activePlayer)),
    EducationSelection(2,
        title: "Skip Education",
        description:
            "Skipping education will result in not increasing your skill XP.",
        cost: 0,
        xp: 0,

        /// Skip education, do nothing
        action: () => {}),
  ];

  void _handleNextConfirm(BuildContext context) {
    if (_selection == null) {
      context.showSnackbar(message: "✋🏼 Please select an education choice");
      return;
    }

    context.showDialog(buildEducationConfirmDialog(
        context, _selection!, () => _handleDialogConfirmation(context)));
  }

  void _handleDialogConfirmation(BuildContext context) {
    if (_selection!.cost == 0.0) {
      context.navigateAndPopTo(DashboardScreen());
      return;
    }

    _selection!.action();

    Future.delayed(Durations.short2, () {
      context.showDialog(buildEducationSuccessDialog(
          context,
          skillManager.getPlayerSkill(activePlayer),
          () => context.navigateAndPopTo(DashboardScreen())));
      confettiController.play();
    });
  }

  void _handleUnaffordable(BuildContext context, String action) {
    context.showSnackbar(message: "✋🏼 You cannot afford to $action.");
  }

  @override
  void initState() {
    confettiController = ConfettiController(duration: Durations.medium4);
    super.initState();
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      title: "Choose Education",
      landingMessage: "🎓 Choose whether or not to pursue an education.",
      landingDialog: (hintsManager.shouldShowHint(activePlayer, Hint.education))
          ? AlphaDialogBuilder.dismissable(
              title: "Education",
              dismissText: "Continue",
              width: 350.0,
              child: const EducationLandingDialog())
          : null,
      onTapBack: () => Navigator.of(context).pop(),
      next: Builder(
        builder: (context) =>
            AlphaButton.next(onTap: () => _handleNextConfirm(context)),
      ),
      children: <Widget>[
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PlayerAccountBalanceStatCard(
                accountsManager.getPlayerAccount(activePlayer)),
            const SizedBox(width: 20.0),
            ListenableBuilder(
                listenable: skillManager.getPlayerSkill(activePlayer),
                builder: (context, child) => AlphaSkillBarMedium(
                    skillManager.getPlayerSkill(activePlayer)))
          ],
        ),
        const SizedBox(height: 40.0),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 30.0,
          runSpacing: 45.0,
          children: _selections
              .map((selectable) => _buildEducationCardWithGestures(
                  context, selectable, _selection?.index ?? -1))
              .toList(),
        )
      ],
    );
  }

  Widget _buildEducationCardWithGestures(
      BuildContext context, EducationSelection selection, int current) {
    bool affordable =
        accountsManager.getAvailableBalance(activePlayer) >= selection.cost;

    return Builder(
      builder: (BuildContext context) => GestureDetector(
          onTap: affordable
              ? () => setState(() => _selection = selection)
              : () =>
                  _handleUnaffordable(context, selection.title.toLowerCase()),
          child: EducationCard(
            title: selection.title,
            description: selection.description,
            affordable: affordable,
            cost: selection.cost,
            xp: selection.xp,
            selected: selection.index == current,
          )),
    );
  }
}

class EducationSelection {
  final String title;
  final String description;
  final double cost;
  final int xp;
  final int index;
  final void Function() action;

  EducationSelection(this.index,
      {required this.title,
      required this.description,
      required this.cost,
      required this.xp,
      required this.action});
}
