import 'dart:math';

import 'package:alpha/assets.dart';
import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/cars.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:logging/logging.dart';

enum CarType {
  petrol(name: "Petrol", image: AlphaAsset.carPetrol),
  hybrid(name: "Hybrid", image: AlphaAsset.carHybrid),
  electric(name: "Electric", image: AlphaAsset.carElectric);

  const CarType({required this.name, required this.image});

  final String name;
  final AlphaAsset image;
}

class Car {
  final String name;
  final CarType type;

  final double price;
  final double depreciationRate;
  final int repaymentPeriod;

  final int timeBonus;
  final int esgBonus;
  final int happinessBonus;

  double get loanAmount => price * 0.8;
  double get upfrontPayment => price * 0.2;
  double get repaymentPerRound => loanAmount / repaymentPeriod;

  Car({
    required this.name,
    required this.price,
    this.depreciationRate = 0.065,
    this.repaymentPeriod = 5,
    required this.type,
    required this.happinessBonus,
    required this.esgBonus,
    this.timeBonus = 120,
  });
}

class CarOwnership {
  final Car car;
  final int ownedRound;
  final Player player;

  CarOwnership(
      {required this.car, required this.ownedRound, required this.player});
}

class CarManager implements IManager {
  static const kCOEBasePrice = 1000.0;
  static const kCOEIncrement = 500.0;

  @override
  final Logger log = Logger("CarManager");

  final List<CarOwnership> _ownedCars = [];

  bool canPurchaseCar(Player player, Car car) {
    final double availableBalance = accountsManager.getAvailableBalance(player);

    if (availableBalance > carManager.getCarPriceWithCOE(car)) {
      return true;
    }

    final double upfrontPrice = car.upfrontPayment + calculateCOEPrice();

    if (availableBalance < upfrontPrice) {
      return false;
    }

    LoanApplicationOutcome outcome = loanManager.canPlayerTakeLoan(player,
        newLoanRepaymentPerRound: car.repaymentPerRound,
        reason: LoanReason.car);

    return outcome.isApproved;
  }

  /// Calculate the COE price based on the number of cars owned by
  /// all players in the game.
  double calculateCOEPrice() {
    int numCars = _ownedCars.length;

    double baseCOE = kCOEBasePrice;
    double coePrice = baseCOE + (numCars * kCOEIncrement);

    return coePrice;
  }

  double getCarPriceWithCOE(Car car) {
    return car.price + calculateCOEPrice();
  }

  double getUpfrontPaymentWithCOE(Car car) {
    return car.upfrontPayment + calculateCOEPrice();
  }

  void buyCar(Player player, Car car, {bool takeLoan = true}) {
    final double availableBalance = accountsManager.getAvailableBalance(player);
    if (!takeLoan) {
      final totalPriceWithoutLoan = getCarPriceWithCOE(car);

      if (availableBalance < totalPriceWithoutLoan) {
        log.warning(
            "Player ${player.name} does not have enough savings to buy car, ignoring");
        return;
      }

      accountsManager.deductAny(player, totalPriceWithoutLoan);
      _ownedCars.add(CarOwnership(
          car: car, ownedRound: gameManager.round, player: player));

      log.info("Bought car ${car.name} for ${player.name} without loan");
      return;
    }

    /// Calculate the total price of the car including COE
    final double totalPrice = getUpfrontPaymentWithCOE(car);

    if (availableBalance < totalPrice) {
      log.warning(
          "Player ${player.name} does not have enough savings to buy car, ignoring");
      return;
    }

    accountsManager.deductAny(player, totalPrice);

    loanManager.issueLoan(player,
        amount: car.loanAmount,
        repaymentPeriod: car.repaymentPeriod,
        reason: LoanReason.car);

    statsManager.addHappiness(player, car.happinessBonus);
    statsManager.addESG(player, car.esgBonus);

    _ownedCars.add(
        CarOwnership(car: car, ownedRound: gameManager.round, player: player));
    log.info("Bought car ${car.name} for ${player.name}");
  }

  /// Sell the car owned by the player.
  void sellCar(Player player, Car car) {
    /// Get the value of the car after depreciation
    final double carValue = getCurrentCarValue(player, car);
    final double currentCOEPrice = calculateCOEPrice();

    final double totalValue = carValue + currentCOEPrice;

    /// Get the remaining loan amount
    final double remainingLoan =
        loanManager.getRemainingLoanAmount(player, reason: LoanReason.car);

    /// Cancel the loan
    loanManager.cancelLoan(player, reason: LoanReason.car);

    /// If the car's value is greater than the remaining loan
    /// credit the extra amount to the player's savings
    if (totalValue > remainingLoan) {
      accountsManager.creditToSavingsUnbudgeted(
          player, totalValue - remainingLoan);
    }

    statsManager.deductHappiness(player, car.happinessBonus);
    statsManager.deductESG(player, car.esgBonus);

    _ownedCars.removeWhere((o) => o.player == player && o.car == car);
    log.info("Sold car ${car.name} for ${player.name}");
  }

  /// Get the list of cars that are available for purchase by a player.
  List<Car> getAvailableCars(Player player) {
    return Cars.listings
        .where((car) => !_ownedCars.any((o) => o.car == car))
        .toList();
  }

  /// Get the current value of the player owned car after depreciation.
  double getCurrentCarValue(Player player, Car car) {
    CarOwnership ownership;

    try {
      ownership =
          _ownedCars.firstWhere((o) => o.player == player && o.car == car);
    } catch (e) {
      log.warning(
          "Player ${player.name} does not own car ${car.name}, ignoring");
      return 0;
    }

    final int roundsOwned = gameManager.round - ownership.ownedRound;
    double value = car.price * pow(1 - car.depreciationRate, roundsOwned);

    /// Car value can depreciate to a minimum of 10% of its original value
    return max(value, car.price * 0.1);
  }

  double getCarSalePrice(Player player, Car car) {
    return calculateCOEPrice() + getCurrentCarValue(player, car);
  }

  List<Car> getOwnedCars(Player player) {
    return _ownedCars
        .where((o) => o.player == player)
        .map((o) => o.car)
        .toList();
  }

  int getRoundsOwned(Player player, Car car) {
    CarOwnership ownership;

    try {
      ownership =
          _ownedCars.firstWhere((o) => o.player == player && o.car == car);
    } catch (e) {
      log.warning(
          "Player ${player.name} does not own car ${car.name}, ignoring");
      return 0;
    }

    return gameManager.round - ownership.ownedRound;
  }

  double getTotalAssetValue(Player player) {
    return _ownedCars
        .where((o) => o.player == player)
        .map((o) => getCurrentCarValue(player, o.car))
        .fold(0, (prev, value) => prev + value);
  }
}
