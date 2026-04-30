import 'dart:collection';
import 'dart:math';

import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/business.dart';
import 'package:alpha/logic/economy_logic.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/logic/data/world_event.dart';
import 'package:alpha/services.dart';
import 'package:alpha/utils.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class BusinessVenture extends ChangeNotifier {
  final List<Business> _ownedBusinesses = [];

  UnmodifiableListView get ownedBusinesses =>
      UnmodifiableListView(_ownedBusinesses);

  int get numBusinesses => _ownedBusinesses.length;

  void addBusiness(Business business) {
    _ownedBusinesses.add(business);
    notifyListeners();
  }

  void removeBusiness(Business business) {
    _ownedBusinesses.remove(business);
    notifyListeners();
  }
}

class Business {
  final String name;
  final BusinessSector sector;
  final int esgRating;
  final double initialCost;

  double _currentRevenue;
  double get currentRevenue => _currentRevenue;

  double _lastRevenue = 0.0;
  double get lastRevenue => _lastRevenue;

  double _lastValuation = 0.0;
  double get lastValuation => _lastValuation;

  int _lastRndRound = -1;
  int get lastRndRound => _lastRndRound;

  int _growthOpportunities;
  int get growthOpportunities => _growthOpportunities;

  Business({
    required this.name,
    required this.sector,
    required this.esgRating,
    required this.initialCost,
    int growthOpportunities = 4,
  })  : _currentRevenue = sector.baseRevenue,
        _growthOpportunities = growthOpportunities;

  void updateRevenue(int numCompetitors) {
    /// Cap business growth
    if (_growthOpportunities <= 0) {
      _currentRevenue *= 1.02;
      return;
    }

    double growthRate;

    if (numCompetitors <= 1) {
      /// Monopoly
      growthRate = 1.25;
    } else if (numCompetitors <= 3) {
      /// Oligopoly
      growthRate = 1.15;
    } else {
      /// Perfect competition
      growthRate = 1.0;
    }

    _growthOpportunities--;
    _currentRevenue *= growthRate;
  }

  void completeRnD() {
    _currentRevenue *= (1 + BusinessManager.kRndGrowthFactor);
  }

  void updateRndRound(int round) {
    _lastRndRound = round;
  }

  void updateValuation(double value) {
    _lastValuation = value;
  }

  void updateLastRevenue(double value) {
    _lastRevenue = value;
  }
}

class BusinessManager implements IManager {
  static const int kMaxESG = 100;
  static const double kInitialCostFactor = 1.6;
  static const double kPioneerPenalty = 0.1;
  static const double kSaturationDiscount = -0.1;
  static const double kDepressionDiscount = -0.15;
  static const double kESGBonusRevenue = 0.2;
  static const double kESGBonusValuation = 0.3;
  static const double kCompetitorPenaltyValuation = -0.05;
  static const double kRevenueToValuationAdjustment = 1.25;

  /// RnD has a 60% chance of growing the business
  static const double kRndSuccessRate = 0.6;

  /// RnD success grows the business by 30%
  static const double kRndGrowthFactor = 0.3;

  /// RnD costs 65% of the current revenue
  static const double kRndCostFactor = 0.55;

  /// The maximum number of businesses there can be in a sector
  static const int kMaxBusinesses = 10;

  /// Map to store the businesses owned by a player.
  final Map<Player, BusinessVenture> _businessVentures = {};

  /// A list of businesses that have been created for the current turn.
  /// This allows us to always give the same businesses to the player in his turn.
  final List<Business> _cachedBusinesses = [];
  int _cachedTurn = -1;

  final Random _random = Random();

  @override
  final Logger log = Logger('BusinessManager');

  /// Initialise the business ventures for all players.
  void initialisePlayerBusinesses(List<Player> players) {
    for (Player player in players) {
      _businessVentures[player] = BusinessVenture();
    }
  }

  /// Get the business venture of a player.
  BusinessVenture getBusinessVenture(Player player) {
    if (!_businessVentures.containsKey(player)) {
      _businessVentures[player] = BusinessVenture();
    }

    return _businessVentures[player]!;
  }

  /// Gets the list of [Player]s who are competitors in a [BusinessSector],
  /// at most the number of total players in the game.
  /// Each player that owns any number of [Business] in that [BusinessSector]
  /// counts as ONE competitor.
  List<Player> getCompetitors(BusinessSector sector) {
    List<Player> competitors = [];

    for (Player player in _businessVentures.keys) {
      Business? business = _businessVentures[player]!
          .ownedBusinesses
          .firstWhere((business) => business.sector == sector,
              orElse: () => null);

      if (business != null) {
        competitors.add(player);
      }
    }

    return UnmodifiableListView(competitors);
  }

  /// Gets the number of competitors in a [BusinessSector], at most the number
  /// of total players in the game. Each player that owns any number of [Business]
  /// in that [BusinessSector] counts as ONE competitor.
  int getNumCompetitors(BusinessSector sector) {
    return getCompetitors(sector).length;
  }

  /// Gets the total number of [Business] in a given [BusinessSector].
  int getBusinessCount(BusinessSector sector) {
    int numBusinesses = 0;

    for (BusinessVenture venture in _businessVentures.values) {
      numBusinesses += venture.ownedBusinesses
          .where((business) => business.sector == sector)
          .length;
    }

    return numBusinesses;
  }

  void growBusinesses() {
    for (BusinessVenture venture in _businessVentures.values) {
      for (Business business in venture.ownedBusinesses) {
        business.updateRevenue(getNumCompetitors(business.sector));
      }
    }
  }

  /// Gets the cost of Research and Development for a [Business].
  /// Default is 40% of the current revenue.
  double getRndCost(Business business) {
    return business.currentRevenue * kRndCostFactor;
  }

  double getRndSuccessRate(Business business) {
    return kRndSuccessRate;
  }

  bool attemptRnD(Player player, Business business) {
    BusinessVenture venture = _businessVentures[player]!;

    if (!venture.ownedBusinesses.contains(business)) {
      log.warning(
          "Player ${player.name} does not own business ${business.name}");
      return false;
    }

    final double rndCost = getRndCost(business);

    if (accountsManager.getAvailableBalance(player) < rndCost) {
      log.warning(
          "Player ${player.name} does not have enough money to complete R&D for business ${business.name}");
      return false;
    }

    /// Update the round the business attempted R&D to prevent multiple
    /// attempts in the same round
    business.updateRndRound(gameManager.round);

    final double roll = _random.nextDouble();
    final double risk = getRndSuccessRate(business);

    accountsManager.deductAny(player, rndCost);

    if (roll > risk) {
      log.info(
          "Player ${player.name} failed R&D for business ${business.name}, roll: $roll, risk: $risk");
      return false;
    }

    business.completeRnD();

    log.info(
        "Player ${player.name} successfully completed R&D for business ${business.name}");

    return true;
  }

  /// Gets the sector state multiplier for a given [BusinessSector].
  /// The multiplier is used to adjust the earnings of businesses in the sector,
  /// and is affected by the current [WorldEvent].
  double getSectorStateMultiplier(BusinessSector sector) {
    WorldEvent event = worldEventManager.currentEvent;

    if (!event.sectorsAffected.contains(sector)) {
      /// Sector not affected by the current world event
      return 0.0;
    }

    if (event.isPositiveEffect) {
      /// Bearish market
      return -0.2;
    } else {
      /// Bullish market
      return 0.3;
    }
  }

  double getEconomicCycleMultiplier() {
    switch (economyManager.currentCycle) {
      case EconomicCycle.recession:
        return -0.1;
      case EconomicCycle.depression:
        return -0.2;
      case EconomicCycle.recovery:
        return 0.0;
      case EconomicCycle.boom:
        return 0.25;
    }
  }

  /// Calculates the earnings of a business based on all available factors.
  /// Final Revenue = Base Revenue * (1 + Random Factor + ESG Bonus + World Event Multiplier + Economic Multiplier)
  double calculateBusinessEarnings(Business business) {
    /// The base value for the earnings.
    final double currentRevenue = business.currentRevenue;

    /// The ESG factor that boosts earnings by up to 20%.
    final double esgBonus = (business.esgRating / kMaxESG) * kESGBonusRevenue;

    /// The factor due to the world event affecting the [BusinessSector].
    final double worldEventMultiplier =
        getSectorStateMultiplier(business.sector);

    /// The factor due to the current economic cycle.
    final double economicMultiplier = getEconomicCycleMultiplier();

    /// The random factor in the earnings.
    final double randomFactor = 0.1 *
        (generateRandomFactor(
                    business.name, gameManager.round + gameManager.turn) *
                2 -
            1);

    final double revenue = currentRevenue *
        (1 +
            randomFactor +
            esgBonus +
            worldEventMultiplier +
            economicMultiplier);

    return revenue;
  }

  /// Calculate the initial cost of starting a [Business] in a [BusinessSector].
  double calculateBusinessCost(
      String businessName, BusinessSector sector, int esgRating) {
    final double baseCost = sector.baseRevenue * kInitialCostFactor;

    final double pioneerPenalty = getBusinessCount(sector) == 0
        ? kPioneerPenalty
        : (getBusinessCount(sector) >= 3 ? kSaturationDiscount : 0.0);

    final double depressionDiscount =
        economyManager.currentCycle == EconomicCycle.depression
            ? kDepressionDiscount
            : 0.0;

    final double esgBonus = (esgRating / kMaxESG) * kESGBonusValuation;

    /// The random factor in the cost.
    final double randomFactor = 0.1 *
        (generateRandomFactor(
                    businessName, gameManager.round + gameManager.turn) *
                2 -
            1);

    final double cost = baseCost *
        (1 + pioneerPenalty + depressionDiscount + esgBonus + randomFactor);

    return cost;
  }

  double calculateBusinessValuation(Business business) {
    /// The base value to use for the business valuation, adjusted for growth.
    final double currentRevenue =
        business.currentRevenue * kRevenueToValuationAdjustment;

    /// The ESG factor that increases the valuation by up to 30%.
    final double esgBonus = (business.esgRating / kMaxESG) * kESGBonusValuation;

    final double competitorPenalty =
        kCompetitorPenaltyValuation * getNumCompetitors(business.sector);

    /// The factor due to the world event affecting the [BusinessSector].
    final double worldEventMultiplier =
        getSectorStateMultiplier(business.sector);

    /// The factor due to the current economic cycle.
    final double economicMultiplier = getEconomicCycleMultiplier();

    final double revenue = currentRevenue *
        (1 +
            esgBonus +
            competitorPenalty +
            worldEventMultiplier +
            economicMultiplier);

    return revenue;
  }

  /// Creates a [Business] in a [BusinessSector] with a unique name.
  Business createBusiness(BusinessSector sector) {
    /// Generate a unique random business name
    String name;
    do {
      name = BusinessNameGenerator.generateName(sector);
    } while (_cachedBusinesses.any((business) => business.name == name));

    final int esgRating = generateExpDistESGRating();

    // Calculate the ESG scale factor, up to 45% reduction in costs
    final double initialCost = calculateBusinessCost(name, sector, esgRating);

    return Business(
      name: name,
      sector: sector,
      esgRating: esgRating,
      initialCost: initialCost,
    );
  }

  List<Business> generateBusinesses(BusinessSector sector, int count) {
    final int currentTurn =
        gameManager.round * playerManager.getPlayerCount() + gameManager.turn;

    if (_cachedBusinesses.isNotEmpty && _cachedTurn == currentTurn) {
      return _cachedBusinesses;
    }

    _cachedBusinesses.clear();

    for (int i = 0; i < count; i++) {
      _cachedBusinesses.add(createBusiness(sector));
    }

    _cachedTurn = currentTurn;

    return UnmodifiableListView(_cachedBusinesses);
  }

  /// Buy a [Business] in a sector for a [Player].
  void buyBusiness(Player player, Business business) {
    BusinessSector sector = business.sector;

    if (getBusinessCount(sector) >= kMaxBusinesses) {
      log.warning(
          'Player ${player.name} tried to buy a business in sector $sector but the maximum number of businesses has been reached');
      return;
    }

    final double cost = business.initialCost;
    final availableBalance = accountsManager.getAvailableBalance(player);

    if (availableBalance < cost) {
      log.warning(
          'Player ${player.name} tried to buy a business in sector $sector but they do not have enough money');
      return;
    }

    /// Deduct the cost of the business from the player's accounts.
    accountsManager.deductAny(player, cost);

    /// Register the business with the player.
    _businessVentures[player]!.addBusiness(business);

    /// Add the ESG rating of the business to the player's total ESG rating.
    statsManager.addESG(player, business.esgRating);

    log.info(
        "Player ${player.name} bought business ${business.name} in sector $sector, "
        "${getBusinessCount(sector)} businesses in sector");
  }

  /// Sell a [Business] owned by a [Player].
  void sellBusiness(Player player, Business business) {
    /// Calculate the valuation of the business.
    final double businessValuation = calculateBusinessValuation(business);

    /// Repay the business loan first, then credit the net profit to the player.
    final double businessDebtAmount = loanManager.getBusinessDebt(player);
    final double payableAmount = min(businessValuation, businessDebtAmount);

    LoanRepaymentReceipt receipt =
        loanManager.repayBusinessDebt(player, payableAmount);

    final double netProfit = businessValuation - payableAmount;

    /// Credit net profit if any
    if (netProfit > 0) {
      accountsManager.creditToSavingsUnbudgeted(player, netProfit);
    }

    /// Deduct the ESG rating of the business from the player's total ESG rating.
    statsManager.deductESG(player, business.esgRating);

    /// Remove the business from the player's owned business.
    _businessVentures[player]!.removeBusiness(business);

    log.info(
        'Player ${player.name} sold business ${business.name} for a profit of $netProfit, business debt: ${receipt.amountRemaining}');
  }

  /// Credit the earnings of all businesses to the player's savings account.
  /// We first repay the business loan, then credit the net earnings to the player.
  void creditBusinessEarnings() {
    final players = playerManager.players;

    for (Player player in players) {
      BusinessVenture venture = _businessVentures[player]!;

      if (venture.numBusinesses == 0) continue;

      double totalEarnings = 0.0;

      for (Business business in venture.ownedBusinesses) {
        final double earnings = calculateBusinessEarnings(business);

        business.updateLastRevenue(earnings);
        business.updateValuation(calculateBusinessValuation(business));
        totalEarnings += earnings;
      }

      log.info(
          "Total earnings for player ${player.name}, ${venture.numBusinesses} businesses: $totalEarnings");

      /// If the player has a loss, incur more business debt
      if (totalEarnings < 0) {
        loanManager.incurBusinessDebt(player, totalEarnings.abs());
        log.info(
            "Player ${player.name} incurred business debt of $totalEarnings");
        continue;
      }

      double netEarnings = totalEarnings;

      if (loanManager.getBusinessDebt(player) > 0) {
        log.info(
            "Player ${player.name} has business debt, repaying business debt first");

        LoanRepaymentReceipt receipt =
            loanManager.repayBusinessDebt(player, totalEarnings);

        netEarnings = totalEarnings - receipt.amountPaid;
      }

      if (netEarnings > 0) {
        accountsManager.creditToSavingsUnbudgeted(player, netEarnings);
      }

      log.info(
          "Credited business earnings of ${venture.numBusinesses} businesses to player ${player.name}");
    }
  }

  double getTotalBusinessValuation(Player player) {
    return _businessVentures[player]!
        .ownedBusinesses
        .map((business) => calculateBusinessValuation(business))
        .fold(0.0, (a, b) => a + b);
  }

  int generateExpDistESGRating() {
    final List<int> values =
        List.generate(11, (index) => index * 10); // [0, 10, 20, ..., 100]

    // Lambda parameter controls the rate of exponential decay
    const double lambda = 0.02;

    // Calculate weights using exponential distribution: P(x) = λe^(-λx)
    final List<double> weights =
        values.map((x) => lambda * exp(-lambda * x)).toList();

    // Calculate the sum of weights for normalization
    final double totalWeight = weights.reduce((a, b) => a + b);

    // Generate a random value between 0 and the total weight
    double randomValue = _random.nextDouble() * totalWeight;

    // Find the corresponding number based on the random value
    double currentSum = 0;
    for (int i = 0; i < values.length; i++) {
      currentSum += weights[i];
      if (randomValue <= currentSum) {
        return values[i];
      }
    }

    // Fallback
    return values.last;
  }
}

class BusinessNameGenerator {
  static final Logger log = Logger('Business Name Generator');

  static const Map<BusinessSector, List<String>> names = {
    BusinessSector.technology: [
      "TechNova Solutions",
      "InnovateX Systems",
      "QuantumLeap Technologies",
      "CyberWave Innovations",
      "ByteCrafters",
      "NextGen Tech",
      "AlphaByte",
      "FutureLink",
      "NexusSoft",
      "PixelPulse",
      "FusionCode",
      "DataSphere",
      "CloudMatrix",
      "VertexTech",
      "OptiTech",
      "CodeCrafters",
      "TechFusion",
      "SparkWare",
      "ZenithTech",
      "AeroByte"
    ],
    BusinessSector.eCommerce: [
      "ShopEase Store",
      "UrbanMart",
      "RetailHub",
      "FashionFrenzy",
      "MarketPlace",
      "TrendSetters",
      "StyleSphere",
      "GlamourGroove",
      "BargainBarn",
      "PrimePicks",
      "EcoMart",
      "LuxuryLane",
      "ValueVault",
      "UrbanEdge",
      "ChicChoice",
      "SelectShop",
      "MetroMart",
      "SavvyStore",
      "EliteEmporium",
      "DailyDeals"
    ],
    BusinessSector.foodAndBeverage: [
      "TasteBuds Café",
      "FlavorFusion Bistro",
      "GourmetGlow",
      "SavorySprings",
      "DelishDelights",
      "EpicureanEats",
      "PalatePleasures",
      "CraveCrafters",
      "SizzleStation",
      "HarvestHaven",
      "BrewBerry",
      "Fork&Flavor",
      "NourishNest",
      "SpiceSphere",
      "VitalVittles",
      "CulinaryCanvas",
      "PurePlate",
      "FusionFlavors",
      "DelightDine",
      "FreshFusion"
    ],
    BusinessSector.pharmaceutical: [
      "MedSpectrum",
      "PharmaPulse",
      "HealthCure Labs",
      "VitaPharma",
      "NovaMedica",
      "CureQuest Pharmaceuticals",
      "BioVantage Pharma",
      "PureHealth Labs",
      "ZenithPharma",
      "OptiLife Pharmaceuticals",
      "LifeLine Meds",
      "PrimeCure Pharmaceuticals",
      "QuantumBio Pharma",
      "ApexMedical",
      "UnityPharma",
      "InnovoPharma",
      "GlobalCure Labs",
      "VitalEdge Pharmaceuticals",
      "FusionMeds",
      "BioSphere Pharma"
    ],
    BusinessSector.socialMedia: [
      "ConnectSphere",
      "BuzzBlend",
      "ShareStream",
      "LinkLounge",
      "VibeVault",
      "EchoEngage",
      "PulsePoint",
      "TrendTribe",
      "SocialSync",
      "MediaMingle",
      "SnapShift",
      "ChatChamber",
      "InfluenceInk",
      "ViralVista",
      "EchoEra",
      "FlickFusion",
      "StreamSync",
      "ConnectCraze",
      "BuzzBridge",
      "LinkLuminary"
    ]
  };

  static String generateName(BusinessSector sector) {
    List<String> sectorNames;

    if (names.containsKey(sector)) {
      sectorNames = names[sector]!;
    } else {
      sectorNames = names[BusinessSector.technology]!;
      log.warning(
          "No predefined names for sector $sector. Using technology names");
    }

    final int index = Random().nextInt(sectorNames.length);
    final String selectedName = sectorNames[index];

    return selectedName;
  }
}
