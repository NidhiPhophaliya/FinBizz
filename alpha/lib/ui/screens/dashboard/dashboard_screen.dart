import 'package:alpha/assets.dart';
import 'package:alpha/extensions.dart';
import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/skills_logic.dart';
import 'package:alpha/logic/stats_logic.dart';
import 'package:alpha/logic/data/world_event.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_skill_bar.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/screens/assets/assets_screen.dart';
import 'package:alpha/ui/screens/budgeting/budgeting_screen.dart';
import 'package:alpha/ui/screens/business/business_owned_screen.dart';
import 'package:alpha/ui/screens/dashboard/dialog/budgeting_dialog.dart';
import 'package:alpha/ui/screens/dashboard/dialog/economic_cycle_info_dialog.dart';
import 'package:alpha/ui/screens/dashboard/widgets/dashboard_action_card.dart';
import 'package:alpha/ui/screens/investments/investments_screen.dart';
import 'package:alpha/ui/screens/next_turn/next_turn_screen.dart';
import 'package:alpha/ui/screens/next_turn/widgets/player_avatar.dart';
import 'package:alpha/ui/screens/world_event/world_event_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardScreen extends StatelessWidget {
  final GlobalKey scaffoldKey = GlobalKey();

  final PlayerAccount accounts = accountsManager.getPlayerAccount(activePlayer);
  final PlayerDebt debt = loanManager.getPlayerDebt(activePlayer);
  final PlayerSkill skill = skillManager.getPlayerSkill(activePlayer);
  final PlayerStats stats = statsManager.getPlayerStats(activePlayer);

  DashboardScreen({super.key});

  void _handleEndTurn(BuildContext context) {
    gameManager.nextTurn();
    context.navigateAndPopTo(const PlayersMenuScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
        title: "Dashboard",
        key: scaffoldKey,
        useDefaultPadding: true,
        next: Builder(
          builder: (context) => AlphaButton(
            width: 235.0,
            title: "End Turn",
            onTap: () => _handleEndTurn(context),
          ),
        ),
        children: <Widget>[
          const SizedBox(height: 10.0),
          _DashboardPlayerInfo(),
          const SizedBox(height: 20.0),
          ListenableBuilder(
            /// Additionally listen to unbudgeted changes in [SavingsAccount]
            listenable: accounts.savings,
            builder: (context, child) {
              /// Check if the player has any savings that are not budgeted
              /// The reason the dialog is always checked after build
              /// is because the player may have did actions in their turn that
              /// added unbudgeted savings to their account
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (accounts.savings.unbudgeted > 0.0) {
                  Future.delayed(Durations.short4, () {
                    (scaffoldKey.currentState! as AlphaScaffoldState)
                        .showDialog(
                            buildBudgetingDialog(context, accounts.savings, () {
                      context.navigateTo(BudgetingScreen());
                    }));
                  });
                }
              });

              return child!;
            },
            child: _DashboardPlayerStats(accounts, debt, skill, stats),
          ),
          const SizedBox(height: 30.0),
          const _DashboardActions(),
          const SizedBox(height: 30.0),
          if (worldEventManager.currentEvent != WorldEvent.none)
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child:
                        _DashboardWorldEvent(worldEventManager.currentEvent)))
        ]);
  }
}

class _DashboardPlayerInfo extends StatelessWidget {
  final PlayerSkill skill = skillManager.getPlayerSkill(activePlayer);
  final PlayerAccount accounts = accountsManager.getPlayerAccount(activePlayer);
  final PlayerDebt debt = loanManager.getPlayerDebt(activePlayer);

  void _handleShowEconomyInfo(BuildContext context) {
    context.showDialog(buildEconomicCycleInfoDialog(
        context, economyManager.currentCycle, economyManager.next, () {
      context.dismissDialog();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      // const _DashboardPlayerAvatar(),
      PlayerAvatarWidget(player: activePlayer, radius: 46.0),
      const SizedBox(width: 10.0),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 2.0, bottom: 8.0),
              child: Text(activePlayer.name, style: TextStyles.bold18)),
          AlphaSkillBar(skill, width: 350.0)
        ],
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
                height: 30.0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Round ${gameManager.round}: ${economyManager.currentCycle.description}",
                        style: TextStyles.bold18,
                      ),
                      const SizedBox(width: 10.0),
                      GestureDetector(
                        onTap: () => _handleShowEconomyInfo(context),
                        child: const Icon(
                          Icons.info_outline_rounded,
                        ),
                      )
                    ],
                  ),
                )),
            PlayerCareerStatCard(careerManager.getPlayerJob(activePlayer)),
          ],
        ),
      ),
    ]);
  }
}

class _DashboardPlayerStats extends StatelessWidget {
  final PlayerAccount accounts;
  final PlayerDebt debt;
  final PlayerSkill skill;
  final PlayerStats stats;

  const _DashboardPlayerStats(this.accounts, this.debt, this.skill, this.stats);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      spacing: 15.0,
      children: <Widget>[
        PlayerAccountBalanceStatCard(accounts),
        PlayerDebtStatCard(debt),
        PlayerHappinessStatCard(stats),
        PlayerESGStatCard(stats),
      ],
    );
  }
}

class _DashboardWorldEvent extends StatelessWidget {
  final WorldEvent event;

  const _DashboardWorldEvent(this.event);

  void _handleWorldNewsInfo(BuildContext context) {
    context.showDialog(
        buildWorldEventDialog(context, worldEventManager.currentEvent, () {
      context.dismissDialog();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return AlphaContainer(
      width: 640.0,
      height: 115.0,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xfffcf7e8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xff000000),
                        offset: Offset(0, 2.0),
                      )
                    ],
                    border:
                        Border.all(color: const Color(0xff383838), width: 2.0)),
              ),
              Container(
                width: 75.0,
                height: 75.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xfffcf7e8),
                    border:
                        Border.all(color: const Color(0xff383838), width: 1.0)),
              ),
              SizedBox(
                width: 100.0,
                height: 100.0,
                child: Image.asset(AlphaAsset.dashboardWorldEvent.path),
              )
            ],
          ),
          const SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4.0),
              SizedBox(
                width: 495.0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Breaking News", style: TextStyles.bold19),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => _handleWorldNewsInfo(context),
                        child: const Icon(Icons.info_outline,
                            size: 30.0, color: Colors.black87),
                      )
                    ]),
              ),
              const SizedBox(height: 1.0),
              SizedBox(
                width: 500.0,
                child: AutoSizeText.rich(
                    maxLines: 2,
                    TextSpan(children: [
                      TextSpan(
                        text: event.title,
                        style: TextStyles.bold16,
                      ),
                      TextSpan(
                        text: " - ${event.description} ",
                        style:
                            TextStyles.medium16.copyWith(color: Colors.black87),
                      ),
                    ])),
              )
            ],
          ),
        ],
      ),
    ).animate().slideY(
        curve: Curves.elasticOut,
        duration: const Duration(milliseconds: 1500),
        delay: const Duration(milliseconds: 500),
        begin: 1.5,
        end: 0.0);
  }
}

class _DashboardActions extends StatelessWidget {
  const _DashboardActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 15.0,
      children: <Widget>[
        DashboardActionCard(
          title: "Assets",
          description: "Manage your assets and liabilities.",
          image: AlphaAsset.dashboardAssets,
          onTap: () => context.navigateTo(const AssetsScreen()),
        ).animate().scale(
            curve: Curves.elasticOut,
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 50),
            begin: Offset.zero,
            end: const Offset(1.0, 1.0)),
        DashboardActionCard(
          title: "Investments",
          description: "Invest in various assets to earn money.",
          image: AlphaAsset.dashboardInvestment,
          onTap: () => context.navigateTo(const InvestmentsScreen()),
        ).animate().scale(
            curve: Curves.elasticOut,
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 250),
            begin: Offset.zero,
            end: const Offset(1.0, 1.0)),
        DashboardActionCard(
          title: "Businesses",
          description: "Manage your business operations.",
          image: AlphaAsset.dashboardBusiness,
          onTap: () => context.navigateTo(const BusinessOwnedScreen()),
        ).animate().scale(
            curve: Curves.elasticOut,
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 450),
            begin: Offset.zero,
            end: const Offset(1.0, 1.0)),
      ],
    );
  }
}
