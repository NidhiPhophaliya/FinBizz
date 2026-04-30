import 'dart:collection';
import 'dart:math';

import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/stocks.dart';
import 'package:alpha/logic/economy_logic.dart';
import 'package:alpha/logic/data/world_event.dart';
import 'package:alpha/services.dart';
import 'package:logging/logging.dart';

/// A controller for the financial market systems in the game. Currently
///  manages the stocks and their prices
class FinancialMarketManager implements IManager {
  final int? seed;

  @override
  Logger log = Logger('FinancialMarketManager');

  /// The list of [Stock] with simulated prices, based on parameters
  /// of the [StockItem].
  late final List<Stock> _stocks;

  /// Gets the list of [Stock] being managed.
  UnmodifiableListView<Stock> get stocks => UnmodifiableListView(_stocks);

  FinancialMarketManager({this.seed}) {
    _stocks = StockItem.values
        .map((StockItem item) => Stock(item, seed: seed))
        .toList();
  }

  void updateMarket() {
    _stocks.forEach(updateStockPrice);
    log.info("All stock prices updated for ${_stocks.length} stocks");
  }

  void updateStockPrice(Stock stock,
      {EconomicCycle? mockCycle, WorldEvent? mockEvent}) {
    final EconomicCycle cycle = mockCycle ?? economyManager.currentCycle;
    final WorldEvent event = mockEvent ?? worldEventManager.currentEvent;

    double marketSentiment = 0.0;
    double sectorTrend = 0.0;

    if (event.sectorsAffected.contains(stock.item.sector)) {
      sectorTrend = event.isPositiveEffect ? 1.0 : -1.0;
    }

    switch (cycle) {
      case EconomicCycle.recession:
        marketSentiment = 0.0;
        break;
      case EconomicCycle.depression:
        marketSentiment = -0.5;
        break;
      case EconomicCycle.recovery:
        marketSentiment = 0.5;
        break;
      case EconomicCycle.boom:
        marketSentiment = 1.0;
    }

    double lastPrice = stock.price;
    stock.updatePrice(
        marketSentiment: marketSentiment, sectorTrend: sectorTrend);

    log.info(
        "Stock price updated for ${stock.name} :  $lastPrice -> ${stock.price} (${stock.percentPriceChange(lastNth: 1)}%)");
  }

  /// Get the stock price of the [StockItem] at the nth round
  double getStockPrice(StockItem stock, {int? nth}) {
    nth = nth ?? gameManager.round;
    nth = nth.clamp(1, gameManager.round);

    final List<double> prices =
        _stocks.firstWhere((Stock s) => s.item == stock).history;

    return prices[prices.length - (gameManager.round - nth) - 1];
  }
}

/// This class simulates stock prices using Geometric Brownian Motion (GBM).
class StockMarket {
  static const double kSectorTrendDrift = 0.8;
  static const double kMarketSentimentDrift = 0.6;

  /// initial stock price
  final double s0;

  /// percent drift (average rate of return)
  final double mu;

  /// percent volatility
  final double sigma;

  /// total time period
  final double T;

  /// number of steps
  final int N;

  // delta time per step
  final double dt;

  // seed for random number generator
  final int? seed;

  // The uniform distribution function to use.
  late final Random _rand;

  // current stock price
  double S;

  // historical prices
  late List<double> historicPrices = [];

  /// This function generates a N(0, 1) random number using the Box-Muller transform.
  double _nextGaussion() {
    // Generate two independent samples from the uniform distribution
    double u1 = _rand.nextDouble();
    double u2 = _rand.nextDouble();

    // Transform U1 and U2 to random distributed Z0
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }

  StockMarket(
      {required this.s0,
      required this.mu,
      required this.sigma,
      this.seed,
      this.T = 15.0,
      this.N = 140})
      : dt = T / N,
        S = s0 {
    _rand = Random(seed);
  }

  /// Caluclate the next stock price using the Geometric Brownian Motion (GBM) model.
  /// The analytic solution to the GBM is: S_t = S_0 * exp((mu - 0.5 * sigma^2) * t + sigma * W_t)
  /// where W_t is a Wiener process, implemented using the Gaussian Random Walk.
  double getNextPrice(
      {double marketSentiment = 0.0, double sectorTrend = 0.0}) {
    /// Random Walk, W_t scaled by the square root of the time step
    /// Var(dW) = dt * Var(W) = dt
    final double dW = sqrt(dt) * _nextGaussion();

    /// Base price movement
    final double baseMovement = (mu - 0.5 * pow(sigma, 2)) * dt + (sigma * dW);

    /// Market influences
    final double sectorTendEffect = sectorTrend * kSectorTrendDrift * dt;
    final double marketSentimentEffect =
        marketSentiment * kMarketSentimentDrift * dt;

    /// Total movement
    final double totalMovement =
        baseMovement + sectorTendEffect + marketSentimentEffect;

    S *= exp(totalMovement);
    historicPrices.add(double.parse(S.toStringAsFixed(2)));

    return historicPrices.last;
  }

  /// Generate N stock prices from the current step and return the latest price
  double generatePrices({int N = 1}) {
    double historicPrices = 0.0;

    for (int i = 0; i < N; i++) {
      historicPrices = getNextPrice();
    }

    return historicPrices;
  }
}

class Stock {
  final StockItem item;
  final StockMarket market;

  final int? seed;

  UnmodifiableListView<double> get history =>
      UnmodifiableListView(market.historicPrices);

  double get price => market.historicPrices.last;

  String get name => item.name;
  String get code => item.code;
  double get initialPrice => item.initialPrice;
  double get percentDrift => item.percentDrift;
  double get percentVolatility => item.percentVolatility;
  int get esgRating => item.esgRating;
  StockRisk get risk => item.risk;

  double priceChange({int lastNth = 10}) {
    final int n = market.historicPrices.length;

    return market.historicPrices[n - 1] - market.historicPrices[n - lastNth];
  }

  /// Calculate the percent change in stock price over the [lastNth] rounds
  double percentPriceChange({int lastNth = 10}) {
    final int n = market.historicPrices.length;

    final double latestPrice = market.historicPrices[n - 1];
    final double lastNthPrice = market.historicPrices[max(n - 1 - lastNth, 0)];

    final double percentChange = (latestPrice / lastNthPrice - 1.0) * 100;

    return double.parse(percentChange.toStringAsFixed(2));
  }

  Stock(this.item, {this.seed})
      : market = StockMarket(
            seed: seed,
            s0: item.initialPrice,
            mu: item.percentDrift,
            sigma: item.percentVolatility) {
    /// Generate 10 prices to plot the price graph, essentially the game starts
    /// with the stock market at t = 10 rounds
    market.generatePrices(N: 10);
  }

  void updatePrice({double marketSentiment = 0.0, double sectorTrend = 0.0}) {
    /// This function should be called after every turn/round to update the stock price
    market.getNextPrice(
        marketSentiment: marketSentiment, sectorTrend: sectorTrend);
  }
}
