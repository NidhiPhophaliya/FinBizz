import 'dart:collection';
import 'dart:math';

import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

enum Budget {
  dailyExpenses("Daily Expenses", priority: 5),
  selfImprovement("Self Improvement", priority: 4),
  recreational("Recreational", priority: 3),
  investments("Investment", priority: 2),
  savings("Savings", priority: 1);

  final String title;
  final int priority;

  const Budget(this.title, {required this.priority});
}

class BudgetAllocation extends ChangeNotifier {
  late Map<Budget, int> _budgets;
  final valid = ValueNotifier<bool>(true);

  BudgetAllocation({required Map<Budget, int> budgets}) {
    _budgets = Map.from(budgets);
  }

  UnmodifiableMapView<Budget, int> get value => UnmodifiableMapView(_budgets);
  Iterable<int> get values => UnmodifiableMapView(_budgets).values;

  operator [](Budget budget) => _budgets[budget]; // get

  operator []=(Budget budget, int value) {
    if (value == _budgets[budget]) return;

    _updateBudget(budget, value);
    notifyListeners();
  }

  /// Update local budgets map with an exact copy of the `budgets` provided
  void apply(BudgetAllocation tempBudgets) {
    _budgets = Map<Budget, int>.from(tempBudgets.value);
    notifyListeners();
  }

  void _updateBudget(Budget budget, int value) {
    if (value < 0 || value > 10) return;

    _budgets[budget] = value;

    final int proportionSum = sum<int>(_budgets.values);

    /// Else > 10, decrement the least priority budget by the exceeded amount.
    int excess = proportionSum - 10;

    final List<Budget> sortedBudgets = List.from(Budget.values)
      ..sort((a, b) => a.priority - b.priority);

    for (final b in sortedBudgets) {
      if (b == budget || this[b] <= 0) {
        continue;
      }

      if (excess <= 0) {
        break;
      }

      final int newBudget = this[b] - excess;
      excess -= this[b] - newBudget as int;
      _budgets[b] = newBudget >= 0 ? newBudget : 0;
    }

    if (proportionSum >= 10 && _budgets[Budget.dailyExpenses]! > 0) {
      valid.value = true;
      return;
    }

    if (proportionSum < 10 || _budgets[Budget.dailyExpenses]! <= 0) {
      valid.value = false;
      return;
    }

    valid.value = false;
  }
}

class BudgetManager implements IManager {
  /// 10% of total budget is equivalent to 100 exp
  static const kHappinessPerBudget = 2;

  static const kSkillExpPer1kBudget = 300;

  @override
  Logger log = Logger("BudgetManager");

  void applyBudget(Player player, BudgetAllocation allocation) {
    final double totalBudget = accountsManager.getUnbudgetedSavings(player);

    accountsManager.creditToSavings(
        player, totalBudget * allocation[Budget.savings]! / 10);

    accountsManager.creditToInvestments(
        player, totalBudget * allocation[Budget.investments]! / 10);

    /// Credit skill level based on budget allocation
    final int exp =
        budgetToExp(totalBudget * allocation[Budget.selfImprovement]! / 10);
    skillManager.addExp(player, exp);

    /// Credit happiness based on budget allocation
    final int happiness =
        allocation[Budget.recreational]! * kHappinessPerBudget;
    statsManager.addHappiness(player, happiness);

    accountsManager.clearUnbudgetedSavings(player);

    log.info(
        "Budget applied for ${player.name}, skill bonus: $exp, happiness bonus: $happiness");
  }

  int budgetToExp(double amount) {
    final int amountInt = (amount / 1000).floor();
    return max(amountInt * kSkillExpPer1kBudget, kSkillExpPer1kBudget);
  }
}
