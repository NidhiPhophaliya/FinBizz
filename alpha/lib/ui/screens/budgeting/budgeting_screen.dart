import 'package:alpha/extensions.dart';
import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/logic/budget_logic.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_animations.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/screens/budgeting/dialogs/confirm_budget_dialog.dart';
import 'package:alpha/ui/screens/budgeting/widgets/budgeting_tile.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';

class BudgetingScreen extends StatelessWidget {
  final PlayerAccount accounts = accountsManager.getPlayerAccount(activePlayer);
  final PlayerDebt debt = loanManager.getPlayerDebt(activePlayer);

  final tempBudget = BudgetAllocation(budgets: activePlayer.budgets.value);

  BudgetingScreen({super.key});

  void _handleIncrementBudget(Budget budget) =>
      tempBudget[budget] = tempBudget[budget] + 1;

  void _handleDecrementBudget(Budget budget) =>
      tempBudget[budget] = tempBudget[budget] - 1;

  void _handleConfirmInvalidBudget(BuildContext context) {
    context.showSnackbar(
        message:
            "✋🏼 Invalid budget. Ensure you allocated budget to daily expenses.");
  }

  void _handleConfirmBudget(BuildContext context) {
    context.showDialog(buildConfirmBudgetDialog(context, () {
      budgetManager.applyBudget(activePlayer, tempBudget);
      context.navigateAndPopTo(DashboardScreen());
    }));
  }

  void _handleShowInfo(BuildContext context, Budget budget) {
    switch (budget) {
      case Budget.dailyExpenses:
        _handleInfoDailyExpenses(context);
        break;
      case Budget.selfImprovement:
        _handleInfoSelfImprovement(context);
        break;
      case Budget.recreational:
        _handleInfoRecreational(context);
        break;
      case Budget.investments:
        _handleInfoInvestments(context);
        break;
      case Budget.savings:
        _handleInfoSavings(context);
        break;
    }
  }

  void _handleInfoDailyExpenses(BuildContext context) {
    context.showSnackbar(
        message: "🍏 Daily expenses are a neccesity but must be minimised.");
  }

  void _handleInfoSelfImprovement(BuildContext context) {
    context.showSnackbar(
        message: "🧠 Investing in self-improvement improves skill level. ");
  }

  void _handleInfoRecreational(BuildContext context) {
    context.showSnackbar(
        message: "🏞 Investing in recreational increaes happiness.");
  }

  void _handleInfoInvestments(BuildContext context) {
    context.showSnackbar(
        message:
            "📈 This amount will be allocated to your investment account.");
  }

  void _handleInfoSavings(BuildContext context) {
    context.showSnackbar(
        message:
            "💵 This amount will be allocated to your investment account.");
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
        title: "Budgeting",
        next: ValueListenableBuilder(
          valueListenable: tempBudget.valid,
          builder: _buildConfirmBtn,
        ),
        children: <Widget>[
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlayerSavingsStatCard(accounts),
              const SizedBox(width: 10.0),
              PlayerInvestmentsStatCard(accounts),
            ],
          ),
          const SizedBox(height: 25.0),
          const Text("Total unallocated budget", style: TextStyles.bold24),
          AnimatedNumber<double>(
            accountsManager.getUnbudgetedSavings(activePlayer),
            style: const TextStyle(
                fontSize: 40.0,
                color: Colors.black,
                fontWeight: FontWeight.w700),
            formatCurrency: true,
          ),
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: tempBudget.value.keys
                  .map((Budget key) => _buildBudgetingTile(key))
                  .toList(),
            ),
          ),
        ]);
  }

  /// Widget builders
  Widget _buildConfirmBtn(BuildContext context, bool value, Widget? child) =>
      AlphaButton(
        width: 300.0,
        title: "Apply Budget",
        disabled: !value,
        onTapDisabled: () => _handleConfirmInvalidBudget(context),
        onTap: () => _handleConfirmBudget(context),
      );

  Widget _buildBudgetingTile(Budget key) => ListenableBuilder(
        listenable: tempBudget,
        builder: (context, child) => BudgetingTile(
          title: key.title,
          proportion: tempBudget[key],
          amount: (tempBudget[key] / 10) *
              accountsManager.getUnbudgetedSavings(activePlayer),
          onIncrement: () => _handleIncrementBudget(key),
          onDecrement: () => _handleDecrementBudget(key),
          showInfo: () => _handleShowInfo(context, key),
        ),
      );
}
