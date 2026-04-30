import 'package:alpha/logic/common/interfaces.dart';
import 'package:logging/logging.dart';

enum EconomicCycle {
  recession(
    name: "Recession",
    description: "Economy is in recession",
    longDescription:
        "Economic downturn causing businesses to struggle, stock and asset prices are slighly reduced.",
  ),
  depression(
    name: "Depression",
    description: "Economy is in depression",
    longDescription:
        "The economy is experiencing widespread business failure and falling stock prices, stock and asset prices are heavily reduced.",
  ),
  recovery(
    name: "Recovery",
    description: "Economy is recovering",
    longDescription:
        "The economy is starting to recover from the downturn, businesses are starting to grow, stock and asset prices are slightly increased.",
  ),
  boom(
    name: "Booming",
    description: "Economy is booming",
    longDescription:
        "Economic prosperity is driving great returns on businesses and the stock market, stock and asset prices are sky high.",
  );

  final String name;
  final String description;
  final String longDescription;

  const EconomicCycle({
    required this.name,
    required this.description,
    required this.longDescription,
  });
}

class EconomyManager implements IManager {
  @override
  final Logger log = Logger("Economy Manager");

  /// The CONSTANT rate of inflation in percent
  static const double inflationRate = 2.5;

  /// The multipler to use for inflation
  double _inflation = 1 + (inflationRate / 100);

  /// The current [EconomicCycle], which also acts as a multiplier for prices
  /// Starts at [EconomicCycle.recession]
  EconomicCycle _current = EconomicCycle.recession;
  EconomicCycle get currentCycle => _current;
  EconomicCycle get next =>
      EconomicCycle.values[(_current.index + 1) % EconomicCycle.values.length];

  double get inflation => _inflation;

  /// Updates the economic cycle, which does two things:
  void updateCycle() {
    /// 1. Increments the economic cycle
    _current = EconomicCycle
        .values[(currentCycle.index + 1) % EconomicCycle.values.length];

    /// 2. Increases the inflation by the [inflationRate]
    _inflation = _inflation * (1 + (inflationRate / 100));
    log.info(
        "Incremented economic cycle, current cycle: ${currentCycle.name}, inflation multiplier: $inflation");
  }
}
