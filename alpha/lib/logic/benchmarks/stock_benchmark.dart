import 'dart:math';

import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/logic/data/stocks.dart';
import 'package:alpha/logic/data/world_event.dart';
import 'package:alpha/logic/economy_logic.dart';
import 'package:alpha/logic/financial_market_logic.dart';
import 'package:alpha/logic/game_logic.dart';
import 'package:alpha/logic/world_event_logic.dart';
import 'package:logging/logging.dart';

typedef StockAllocation = Map<StockItem, double>;

class StockBenchmark {
  final Logger log = Logger("StockBenchmark");

  final int? seed;
  final int numRounds;

  final trader = IdealMultiAssetKellyCriterionTrader(StockItem.values, 0.025);

  late final GameManager gameManager = MockGameManager();

  late final InvestmentAccount investmentAccount = InvestmentAccount();

  late final financialMarketManager = FinancialMarketManager(seed: seed);

  late final worldEventManager = WorldEventManager(seed: seed);

  final economyManager = EconomyManager();

  late final _random = Random(seed);

  StockBenchmark(
      {this.seed, this.numRounds = 10, double initialCapital = 1000.0}) {
    investmentAccount.add(initialCapital);
  }

  void runBenchmark() {
    for (int i = 0; i < numRounds; i++) {
      simulateTriggerWorldEvent();
      performTrades();
      updateMarket();
      incrementWorldEvent();
      simulateCreditedCapital();
    }

    log.info(
        "Benchmark completed, Balance: ${investmentAccount.balance}, Portfolio: ${getPortfolioValue()}, Profit: ${getPortfolioValue() + investmentAccount.balance - 1000.0 - numRounds * 3000.0}");
  }

  double getPortfolioValue() {
    return investmentAccount.shareOwnership.fold(
        0.0,
        (previousValue, element) =>
            previousValue +
            element.units * financialMarketManager.getStockPrice(element.item));
  }

  void simulateTriggerWorldEvent() {
    if (_random.nextDouble() < 0.3) {
      worldEventManager.triggerEvent();
    }
  }

  void incrementWorldEvent() {
    worldEventManager.incrementWorldEvent();
  }

  void simulateCreditedCapital() {
    investmentAccount.add(3000.0);
  }

  void performTrades() {
    final StockAllocation allocation = trader.trade(
        worldEventManager.currentEvent, economyManager.currentCycle);

    /// Sell entire portfolio
    for (ShareOwnership ownership
        in List.from(investmentAccount.shareOwnership)) {
      investmentAccount.sellShare(
          financialMarketManager.stocks
              .firstWhere((stock) => stock.item == ownership.item),
          ownership.units);
    }

    /// Rebalance portfolio
    for (StockItem item in allocation.keys) {
      final int units = ((allocation[item]! * investmentAccount.balance) /
              financialMarketManager.stocks
                  .firstWhere((stock) => stock.item == item)
                  .price)
          .floor();

      investmentAccount.purchaseShare(
          financialMarketManager.stocks
              .firstWhere((stock) => stock.item == item),
          units);
    }
  }

  void updateMarket() {
    economyManager.updateCycle();

    for (Stock stock in financialMarketManager.stocks) {
      financialMarketManager.updateStockPrice(stock,
          mockCycle: economyManager.currentCycle,
          mockEvent: worldEventManager.currentEvent);
    }
  }
}

class IdealMultiAssetKellyCriterionTrader {
  final List<StockItem> _stockItems;
  final double riskFreeReturns;

  double get allowedLeverage => 1.0; // No leverage beyond 100% capital

  double get alphaEcon => 0.6;
  double get alphaSentiment => 0.8;

  IdealMultiAssetKellyCriterionTrader(
      List<StockItem> stockItems, this.riskFreeReturns)
      : _stockItems = stockItems;

  double computeEtFromCycle(EconomicCycle cycle) {
    // Example cyclical values
    switch (cycle) {
      case EconomicCycle.recession:
        return -0.5;
      case EconomicCycle.depression:
        return -1.0;
      case EconomicCycle.recovery:
        return 0.5;
      case EconomicCycle.boom:
        return 1.0;
    }
  }

  double computeWtFromEvent(WorldEvent event, StockItem item) {
    // Event impact (positive/negative)
    if (event.sectorsAffected.contains(item.sector)) {
      return event.isPositiveEffect ? 1.0 : -1.0;
    }
    return 0.0;
  }

  double computeAdjustedDrift(StockItem stockItem, double et, double wt) {
    return stockItem.percentDrift +
        alphaEcon * et +
        alphaSentiment * wt -
        riskFreeReturns; // Focus on excess returns
  }

  StockAllocation trade(WorldEvent event, EconomicCycle cycle) {
    final double et = computeEtFromCycle(cycle);

    // Step 1: Compute raw Kelly ratios (mu_i - r) / sigma_i^2
    final List<double> kellyRatios = List.generate(_stockItems.length, (index) {
      final wt = computeWtFromEvent(event, _stockItems[index]);
      final adjustedDrift = computeAdjustedDrift(_stockItems[index], et, wt);
      return adjustedDrift / pow(_stockItems[index].percentVolatility, 2);
    }, growable: false);

    // Step 2: Set negative ratios to 0 (no short selling)
    final List<double> longOnlyRatios =
        kellyRatios.map((ratio) => max(ratio, 0.0)).toList();

    // Step 3: Normalize to sum to 1.0 (100% capital)
    final double sumRatios = longOnlyRatios.fold(0.0, (a, b) => a + b);
    final List<double> normalizedRatios = sumRatios > 0
        ? longOnlyRatios.map((r) => r / sumRatios).toList()
        : List.filled(_stockItems.length, 0.0); // All cash if no opportunities

    // Step 4: Create allocation map
    final StockAllocation allocation = {};
    for (int i = 0; i < _stockItems.length; i++) {
      allocation[_stockItems[i]] = normalizedRatios[i];
      // allocation[_stockItems[i]] = 1.0 / _stockItems.length;
    }

    return allocation;
  }
}

class MockGameManager extends GameManager {
  @override
  int get round => 9999;
}
