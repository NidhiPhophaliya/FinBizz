import 'dart:collection';
import 'dart:math';

import 'package:alpha/assets.dart';
import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/personal_life.dart';
import 'package:alpha/logic/data/real_estate.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:logging/logging.dart';

enum RealEstateType { hdb, condo, landed }

class RealEstate {
  final String name;
  final RealEstateType type;
  final AlphaAsset image;
  final double propertyValue;
  final int repaymentPeriod;
  final double growthRate;
  final double interestRate;

  double get downPayment => propertyValue * 0.2;
  double get mortgage => propertyValue - downPayment;
  double get loanAmount => mortgage * interestRate;
  double get repaymentPerRound => loanAmount / repaymentPeriod;

  RealEstate(
      {required this.name,
      required this.type,
      required this.image,
      required this.propertyValue,
      this.repaymentPeriod = 16,
      this.growthRate = 1.5,
      this.interestRate = 1.2});
}

class RealEstateOwnership {
  final RealEstate realEstate;
  final int ownedRound;
  final Player player;
  int _remainingRepaymentTerms;

  int get remainingRepaymentTerms => _remainingRepaymentTerms;

  RealEstateOwnership(
      {required this.realEstate,
      required this.player,
      required this.ownedRound})
      : _remainingRepaymentTerms = realEstate.repaymentPeriod;

  void deductRepaymentTerm() {
    _remainingRepaymentTerms--;
  }
}

class RealEstateManager implements IManager {
  static const kPurchaseRealEstateHappinessBonus = 5;

  @override
  Logger log = Logger("RealEstateManager");

  final List<RealEstateOwnership> _ownedRealEstates = [];

  /// Whether the player can buy the real estate based on their current financial status.
  /// The player must have enough savings to pay the down payment and be able to take a loan.
  bool canPlayerBuyRealEstate(Player player, RealEstate realEstate) {
    final double availableBalance = accountsManager.getAvailableBalance(player);

    if (availableBalance < realEstate.downPayment) {
      return false;
    }

    LoanApplicationOutcome outcome = loanManager.canPlayerTakeLoan(player,
        newLoanRepaymentPerRound: realEstate.repaymentPerRound,
        reason: LoanReason.mortgage);

    return outcome.isApproved;
  }

  /// Buy the real estate for the player.
  void buyRealEstate(Player player, RealEstate realEstate) {
    final SavingsAccount savings = accountsManager.getSavingsAccount(player);

    if (savings.balance < realEstate.downPayment) {
      log.warning("${player.name} does not have enough savings to buy");
      return;
    }

    /// Pay the downpayment of the real estate
    savings.deduct(realEstate.downPayment);

    /// Take a loan for the remaining mortgage
    loanManager.issueLoan(player,
        amount: realEstate.loanAmount,
        repaymentPeriod: realEstate.repaymentPeriod,
        reason: LoanReason.mortgage);

    /// Add the real estate to the player's ownership
    _ownedRealEstates.add(RealEstateOwnership(
        realEstate: realEstate, player: player, ownedRound: gameManager.round));

    log.info("${player.name} bought ${realEstate.name}");
  }

  /// Sell the real estate for the player.
  /// The player will use the current property value to repay the remaining mortgage
  /// and receive the profit from selling the real estate.
  void sellRealEstate(Player player, RealEstate realEstate) {
    RealEstateOwnership ownership;

    try {
      ownership = _ownedRealEstates
          .firstWhere((o) => o.realEstate == realEstate && o.player == player);
    } catch (e) {
      log.warning("${player.name} does not own ${realEstate.name}");
      return;
    }

    /// Get the current property value
    double propertyValue = getCurrentPropertyValue(player, realEstate);

    double remainingMortgage =
        loanManager.getRemainingLoanAmount(player, reason: LoanReason.mortgage);

    /// Repay the remaining mortgage
    loanManager.repayLoan(player,
        amount: remainingMortgage, reason: LoanReason.mortgage);

    log.info(
        "Repaid remaining mortgage of $remainingMortgage for ${player.name}");

    /// Credit the profit to the player's savings
    double profit = propertyValue - remainingMortgage;
    accountsManager.creditToSavingsUnbudgeted(player, profit);
    log.info(
        "Added profit of $profit to ${player.name} from selling ${realEstate.name}");

    /// Remove the real estate from the player's ownership
    _ownedRealEstates.remove(ownership);
    log.info("${player.name} sold ${realEstate.name}");
  }

  /// Get the list of real estates owned by the player.
  List<RealEstate> getOwnedRealEstates(Player player) {
    return _ownedRealEstates
        .where((element) => element.player == player)
        .map((e) => e.realEstate)
        .toList();
  }

  /// Get the current property value of the real estate given its growth.
  double getCurrentPropertyValue(Player player, RealEstate realEstate) {
    RealEstateOwnership ownership;

    try {
      ownership = _ownedRealEstates
          .firstWhere((o) => o.realEstate == realEstate && o.player == player);
    } catch (e) {
      log.warning("${player.name} does not own ${realEstate.name}");
      return 0.0;
    }

    final rounds = gameManager.round - ownership.ownedRound;
    return realEstate.propertyValue * pow(realEstate.growthRate, rounds);
  }

  /// Get the list of real estates that are available for purchase by the player.
  /// The player cannot buy the same real estate twice.
  List<RealEstate> getAvailableRealEstates(Player player) {
    bool isMarried = personalLifeManager.getPersonalLife(player).status ==
        PersonalLifeStatus.marriage;

    return UnmodifiableListView(RealEstates.listings.where((realEstate) {
      // Check if player already owns this property
      bool notOwned = !_ownedRealEstates.any((ownership) =>
          ownership.realEstate == realEstate && ownership.player == player);

      // Filter HDB properties based on marriage status
      if (realEstate.type == RealEstateType.hdb && !isMarried) {
        return false;
      }

      return notOwned;
    }).toList());
  }

  int getOwnedRounds(Player player, RealEstate realEstate) {
    RealEstateOwnership ownership;

    try {
      ownership = _ownedRealEstates
          .firstWhere((o) => o.realEstate == realEstate && o.player == player);
    } catch (e) {
      log.warning("${player.name} does not own ${realEstate.name}");
      return 0;
    }

    return gameManager.round - ownership.ownedRound;
  }

  double getTotalAssetValue(Player player) {
    double total = 0.0;

    for (RealEstate realEstate in getOwnedRealEstates(player)) {
      total += getCurrentPropertyValue(player, realEstate);
    }

    return total;
  }
}
