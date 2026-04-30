import 'dart:collection';

import 'package:alpha/extensions.dart';
import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

enum LoanReason { mortgage, car }

enum LoanRejectReason { insufficientIncome, existingLoan, none }

class LoanApplicationOutcome {
  final bool isApproved;
  final LoanRejectReason rejectReason;

  const LoanApplicationOutcome(
      {required this.isApproved, required this.rejectReason});
}

class LoanRepaymentReceipt {
  final double amountRemaining;
  final double amountPaid;

  bool get isCleared => amountRemaining == 0;

  const LoanRepaymentReceipt(
      {required this.amountRemaining, required this.amountPaid});
}

class LoanContract {
  final Player player;
  final double amount;
  final int roundIssued;
  final int repaymentPeriod;
  final LoanReason reason;

  double get repaymentPerRound => amount / repaymentPeriod;

  double _amountRemaining;
  double get amountRemaining => _amountRemaining;

  bool get isCleared => _amountRemaining == 0;

  LoanContract(
      {required this.player,
      required this.amount,
      required this.roundIssued,
      required this.repaymentPeriod,
      required this.reason})
      : _amountRemaining = amount;

  void repay(double amount) {
    _amountRemaining -= amount;
  }
}

class PlayerDebt extends ChangeNotifier {
  final List<LoanContract> _loans = [];
  double _businessDebt = 0.0;

  double get businessDebt => _businessDebt;

  double get totalDebt =>
      _loans.fold(0.0, (prev, loan) => prev + loan.amountRemaining) +
      _businessDebt;

  double get repaymentPerRound =>
      _loans.fold(0.0, (prev, loan) => prev + loan.repaymentPerRound);

  List<LoanContract> get loans => UnmodifiableListView(_loans);

  void addLoan(LoanContract loan) {
    _loans.add(loan);
    notifyListeners();
  }

  void removeLoan(LoanContract loan) {
    _loans.remove(loan);
    notifyListeners();
  }

  void payBusinessDebt(double amount) {
    _businessDebt -= amount;

    if (_businessDebt < 0) {
      _businessDebt = 0;
    }

    notifyListeners();
  }

  void incurBusinessDebt(double amount) {
    _businessDebt += amount;
    notifyListeners();
  }
}

class LoanManager implements IManager {
  static const kIncomeToDebtPaymentRatio = 0.80;
  static const kBusinessLoanAmount = 12000.0;

  @override
  final Logger log = Logger("LoanManager");

  final Map<Player, PlayerDebt> _playerDebts = {};

  void initialisePlayerDebts(List<Player> players) {
    for (Player player in players) {
      _playerDebts[player] = PlayerDebt();
    }
  }

  PlayerDebt getPlayerDebt(Player player) {
    if (!_playerDebts.containsKey(player)) {
      _playerDebts[player] = PlayerDebt();
    }

    return _playerDebts[player]!;
  }

  double getTotalDebt(Player player) {
    return _playerDebts[player]!.totalDebt;
  }

  double getRepaymentPerRound(Player player, {LoanReason? reason}) {
    if (reason != null) {
      List<LoanContract> loanContracts = _playerDebts[player]!.loans;

      return loanContracts
          .where((contract) =>
              contract.player == player && contract.reason == reason)
          .fold(0, (prev, contract) => prev + contract.repaymentPerRound);
    }

    return _playerDebts[player]!.repaymentPerRound;
  }

  double getRemainingLoanAmount(Player player, {required LoanReason? reason}) {
    if (reason != null) {
      List<LoanContract> loanContracts = _playerDebts[player]!.loans;
      try {
        return loanContracts
            .where((contract) =>
                contract.player == player && contract.reason == reason)
            .fold(0, (prev, contract) => prev + contract.amountRemaining);
      } catch (e) {
        log.warning("No loan found for ${player.name} with reason $reason");
        return 0.0;
      }
    }

    return _playerDebts[player]!.totalDebt;
  }

  LoanApplicationOutcome canPlayerTakeLoan(Player player,
      {required double newLoanRepaymentPerRound, required LoanReason reason}) {
    /// Check if player has existing loans of same [LoanReason]
    List<LoanContract> loanContracts = _playerDebts[player]!.loans;

    if (loanContracts.any(
        (contract) => contract.player == player && contract.reason == reason)) {
      log.info("Player ${player.name} already has a loan with reason $reason");

      return const LoanApplicationOutcome(
          isApproved: false, rejectReason: LoanRejectReason.existingLoan);
    }

    /// Else, check if player can afford the new loan
    double totalRepaymentPerRound = getRepaymentPerRound(player);

    bool canAfford =
        kIncomeToDebtPaymentRatio * accountsManager.getPlayerCashflow(player) >=
            totalRepaymentPerRound + newLoanRepaymentPerRound;

    if (!canAfford) {
      log.info(
          "Player ${player.name} cannot afford new loan, current repayment per round: $totalRepaymentPerRound but income is ${accountsManager.getPlayerCashflow(player)}");
      return const LoanApplicationOutcome(
          isApproved: false, rejectReason: LoanRejectReason.insufficientIncome);
    }

    return const LoanApplicationOutcome(
        isApproved: true, rejectReason: LoanRejectReason.none);
  }

  void issueLoan(Player player,
      {required double amount,
      required int repaymentPeriod,
      required LoanReason reason}) {
    _playerDebts[player]!.addLoan(LoanContract(
      player: player,
      amount: amount,
      roundIssued: gameManager.round,
      repaymentPeriod: repaymentPeriod,
      reason: reason,
    ));
  }

  void cancelLoan(Player player, {required LoanReason reason}) {
    List<LoanContract> loanContracts = _playerDebts[player]!.loans;

    try {
      loanContracts.removeWhere(
          (contract) => contract.player == player && contract.reason == reason);
    } catch (e) {
      log.warning("No loan found for ${player.name} with reason $reason");
    }
  }

  void autoRepayLoans() {
    for (Player player in _playerDebts.keys) {
      log.info("Auto-repaying loans for ${player.name}");
      for (LoanContract contract in _playerDebts[player]!.loans) {
        repayLoan(player, reason: contract.reason);
      }
    }
  }

  LoanRepaymentReceipt repayLoan(Player player,
      {required LoanReason reason, double? amount}) {
    LoanContract contract;
    List<LoanContract> loanContracts = _playerDebts[player]!.loans;

    try {
      contract = loanContracts.firstWhere(
        (contract) => contract.player == player && contract.reason == reason,
      );
    } catch (e) {
      log.warning("No loan found for ${player.name} with reason $reason");
      return const LoanRepaymentReceipt(amountRemaining: 0, amountPaid: 0);
    }

    amount ??= contract.repaymentPerRound;

    /// Check whether player trying to pay more than remaining amount
    if (amount > contract.amountRemaining) {
      log.warning(
          "Amount $amount exceeds remaining loan amount ${contract.amountRemaining}, repaying remaining amount");

      /// Cap the amount to the remaining amount
      amount = contract.amountRemaining;
    }

    final double availableBalance = accountsManager.getAvailableBalance(player);

    if (availableBalance < amount) {
      log.warning(
          "Player ${player.name} does not have enough balance to repay loan, ignoring");
      return const LoanRepaymentReceipt(amountRemaining: 0, amountPaid: 0);
    }

    contract.repay(amount);
    accountsManager.deductAny(player, amount);

    LoanRepaymentReceipt receipt = LoanRepaymentReceipt(
        amountRemaining: contract.amountRemaining, amountPaid: amount);

    log.info(
        "Repaid $amount for ${player.name}, Loan Reason: $reason, Amount Remaining: ${contract.amountRemaining}");

    if (contract.isCleared) {
      _playerDebts[player]!.removeLoan(contract);
      log.info(
          "Loan cleared for ${player.name}, Loan Reason: $reason, Amount: ${contract.amount}");
    }

    return receipt;
  }

  void applyBusinessLoan(Player player) {
    _playerDebts[player]!.incurBusinessDebt(kBusinessLoanAmount);
    accountsManager.creditToSavings(player, kBusinessLoanAmount);
    log.info(
        "Player ${player.name} took out a business loan, current business debt: ${_playerDebts[player]!.businessDebt.prettyCurrency}");
  }

  LoanRepaymentReceipt repayBusinessDebt(Player player, double amount) {
    final double remainingDebt = _playerDebts[player]!.businessDebt;

    if (amount > remainingDebt) {
      log.warning(
          "Amount $amount exceeds remaining business debt $remainingDebt, repaying remaining amount");

      amount = remainingDebt;
    }

    _playerDebts[player]!.payBusinessDebt(amount);

    log.info(
        "Repaid $amount for ${player.name}, Business Debt Remaining: ${_playerDebts[player]!.businessDebt}");

    return LoanRepaymentReceipt(
        amountRemaining: _playerDebts[player]!.businessDebt,
        amountPaid: amount);
  }

  double getBusinessDebt(Player player) {
    return _playerDebts[player]!.businessDebt;
  }

  void incurBusinessDebt(Player player, double amount) {
    _playerDebts[player]!.incurBusinessDebt(amount);
  }
}
