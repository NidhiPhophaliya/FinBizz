import 'package:alpha/extensions.dart';
import 'package:alpha/logic/personal_life_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:alpha/ui/screens/personal_life/dialogs/confirm_progress_life_dialog.dart';
import 'package:alpha/ui/screens/personal_life/dialogs/progress_life_success_dialog.dart';
import 'package:alpha/ui/screens/personal_life/widgets/personal_life_card.dart';
import 'package:flutter/material.dart';

class PersonalLifeScreen extends StatelessWidget {
  final PersonalLife personalLife =
      personalLifeManager.getPersonalLife(activePlayer);

  final ValueNotifier<bool> hasProgressed = ValueNotifier(false);

  PersonalLifeScreen({super.key});

  void _handleProgressPersonalLife(BuildContext context) {
    context.showDialog(buildConfirmProgressLifeDialog(
        context,
        personalLife.status,
        personalLifeManager.getNextLifeStage(activePlayer), () {
      personalLifeManager.nextLifeStage(activePlayer);

      Future.delayed(Durations.medium1, () {
        hasProgressed.value = false;
        context.showDialog(buildSuccessProgressLifeDialog(
            context, personalLifeManager.getPersonalLife(activePlayer).status,
            () {
          context.dismissDialog();
          context.navigateTo(DashboardScreen());
        }));
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
        title: "Personal Life",
        onTapBack: () => Navigator.pop(context),
        next: AlphaButton(
            title: "Skip",
            width: 190.0,
            onTap: () => context.navigateTo(DashboardScreen())),
        children: [
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlayerAccountBalanceStatCard(
                  accountsManager.getPlayerAccount(activePlayer)),
              const SizedBox(width: 15.0),
              PlayerHappinessStatCard(
                  statsManager.getPlayerStats(activePlayer)),
            ],
          ),
          const SizedBox(height: 25.0),
          ListenableBuilder(
              listenable: personalLife,
              builder: (context, _) => PersonalLifeCard(personalLife.status)),
          const SizedBox(height: 30.0),
          ValueListenableBuilder(
            valueListenable: hasProgressed,
            builder: (context, progressed, _) => !progressed
                ? AlphaButton(
                    width: 280.0,
                    title: personalLife.status.action,
                    color: const Color(0xFF71C5F6),
                    disabled:
                        !personalLifeManager.canAffordNextStage(activePlayer),
                    onTapDisabled: () => context.showSnackbar(
                      message:
                          "✋🏼 You cannot afford to progress to the next stage.",
                    ),
                    onTap: () => _handleProgressPersonalLife(context),
                  )
                : const SizedBox.shrink(),
          )
        ]);
  }
}
