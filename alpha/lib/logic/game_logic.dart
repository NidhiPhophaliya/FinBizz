import 'dart:collection';
import 'dart:math';

import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/logic/board_logic.dart';
import 'package:alpha/logic/budget_logic.dart';
import 'package:alpha/logic/car_logic.dart';
import 'package:alpha/logic/career_logic.dart';
import 'package:alpha/logic/data/player.dart';
import 'package:alpha/logic/education_logic.dart';
import 'package:alpha/logic/hints_logic.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/opportunity_logic.dart';
import 'package:alpha/logic/personal_life_logic.dart';
import 'package:alpha/logic/real_estate_logic.dart';
import 'package:alpha/logic/business_logic.dart';
import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/economy_logic.dart';
import 'package:alpha/logic/financial_market_logic.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/logic/skills_logic.dart';
import 'package:alpha/logic/stats_logic.dart';
import 'package:alpha/logic/world_event_logic.dart';
import 'package:alpha/services.dart';
import 'package:logging/logging.dart';

class GameManager implements IManager {
  @override
  final Logger log = Logger("GameManager");

  final Random _random = Random.secure();

  /// The current round of the game
  int _round = 0;
  int get round => _round;

  /// The current turn in the round, indexed at 0
  /// Each turn corresponds to one player in the game
  int _turn = -1;
  int get turn => _turn;

  /// The cached result of the last dice roll
  /// Used to prevent multiple dice rolls in a single turn
  DiceRollResult lastDiceRoll = DiceRollResult(0, 0, -1);

  /// Leaderboard for the game, generated when the game ends
  final List<GameLeaderboard> _leaderboard = [];
  List<GameLeaderboard> get leaderboard => UnmodifiableListView(_leaderboard);

  /// Instantiate all game logic controllers
  /// Game-Level logic controllers
  BoardManager boardManager = BoardManager();

  EconomyManager economyManager = EconomyManager();
  FinancialMarketManager marketManager = FinancialMarketManager();
  WorldEventManager worldEventManager = WorldEventManager();

  PlayerManager playerManager = PlayerManager();
  OpportunityManager opportunityManager = OpportunityManager();

  /// Player-Level logic controllers
  AccountsManager accountsManager = AccountsManager();
  BudgetManager budgetManager = BudgetManager();

  CareerManager careerManager = CareerManager();

  SkillManager skillManager = SkillManager();
  StatsManager statsManager = StatsManager();
  EducationManager educationManager = EducationManager();

  PersonalLifeManager personalLifeManager = PersonalLifeManager();

  RealEstateManager realEstateManager = RealEstateManager();
  CarManager carManager = CarManager();
  BusinessManager businessManager = BusinessManager();

  LoanManager loanManager = LoanManager();

  /// Utility-level logic controllers
  HintsManager hintsManager = HintsManager();

  void startGame() {
    final List<Player> players = playerManager.players;

    /// Initialise all player locations to the STARTING tile
    boardManager.initialisePlayerLocations(players);

    /// Initialise all player accounts with initial balances
    accountsManager.initialisePlayerAccounts(players);

    /// Initialise all player XP levels to defaults
    skillManager.initialisePlayerSkills(players);

    businessManager.initialisePlayerBusinesses(players);
    educationManager.initialisePlayerEducations(players);
    loanManager.initialisePlayerDebts(players);
    personalLifeManager.initialisePlayerPersonalLife(players);
    statsManager.initialisePlayerStats(players);
    careerManager.initialisePlayerCareers(players);

    log.info("All game logic controllers have been initialised");
    log.info("Game has started with ${playerManager.getPlayerCount()} players");

    /// Increment the turn to the first player
    nextTurn();
  }

  void endGame() {
    int numPlayers = playerManager.players.length;

    for (Player player in playerManager.players) {
      double points = 0.0;

      final int happiness = statsManager.getPlayerStats(player).happiness;

      /// Calculate total cash
      final double totalCash = accountsManager.getAvailableBalance(player) +
          accountsManager.getPlayerAccount(player).cpf.balance;

      /// Calculate investment portfolio value
      final double totalInvestmentValue =
          accountsManager.getInvestmentAccount(player).getPortfolioValue();

      /// Calculate total business valuation
      final double totalBusinessValuation =
          businessManager.getTotalBusinessValuation(player);

      /// Calculate total real estate value and cancel any remaining mortgage
      double totalRealEstateValue =
          realEstateManager.getTotalAssetValue(player);

      final double remainingMortgage = loanManager
          .getRemainingLoanAmount(player, reason: LoanReason.mortgage);
      loanManager.cancelLoan(player, reason: LoanReason.mortgage);
      totalRealEstateValue -= remainingMortgage;

      /// Calculate total car value
      final double totalCarValue = carManager.getTotalAssetValue(player);

      /// Calculate total assets
      final double totalAssets = totalCash +
          totalInvestmentValue +
          totalBusinessValuation +
          totalRealEstateValue +
          totalCarValue;

      /// Calculate happiness multiplier
      final int happinessFactor =
          max(1, happiness - PlayerStats.kBaseHappiness + 1);

      /// Add the assets contribution to the player's points
      points += totalAssets * happinessFactor;

      /// Calculate ESG point bonus (15% bonus if cumulative ESG score > 80 per player)
      final int cumulativeEsgScore = playerManager.players.fold(
          0, (prev, player) => prev + statsManager.getPlayerStats(player).esg);

      if (cumulativeEsgScore > numPlayers * 80) {
        points *= 1.10;
      }

      /// Check if player achieved life goal, 30% bonus if achieved
      final PlayerSkill playerSkill = skillManager.getPlayerSkill(player);
      final PlayerStats playerStats = statsManager.getPlayerStats(player);

      if (player.goal.fulfilledChecker(totalAssets, playerSkill, playerStats)) {
        points *= 1.20;
      }

      /// Calculate debt penalty
      final double remainingDebt = loanManager.getTotalDebt(player);
      final debtToAssetRatio = remainingDebt / totalAssets;

      /// DAR <= 10%: No penalty
      if (debtToAssetRatio <= 0.10) {
        points = points;

        /// 11% <= DAR <= 25%: 5% penalty
      } else if (debtToAssetRatio <= 0.25) {
        points *= 0.95;

        /// 26% DAR <= 50%: 15% penalty
      } else if (debtToAssetRatio <= 0.50) {
        points *= 0.85;

        /// 51% DAR <= 75%: 25% penalty
      } else if (debtToAssetRatio <= 0.75) {
        points *= 0.75;

        /// 76% DAR <= 90%: 50% penalty
      } else if (debtToAssetRatio <= 0.90) {
        points *= 0.50;

        /// DAR >= 90%: 80% penalty
      } else {
        points *= 0.20;
      }

      _leaderboard.add(GameLeaderboard(player, points,
          totalAssets: totalAssets,
          totalDebt: remainingDebt,
          playerGoal: player.goal,
          happinessFactor: happinessFactor,
          cumulativeEsgScore: cumulativeEsgScore));

      /// Sort in descending order of points
      _leaderboard.sort((a, b) => b.points.compareTo(a.points));

      for (GameLeaderboard entry in _leaderboard) {
        log.info(
            "[Leaderboard] Player: ${entry.player.name}, Points: ${entry.points}, Total Assets: ${entry.totalAssets}, Total Debt: ${entry.totalDebt}, Goal: ${entry.playerGoal}, Happiness Factor: ${entry.happinessFactor}, Cumulative ESG Score: ${entry.cumulativeEsgScore}");
      }
    }
  }

  /// This method is called at the end of each turn.
  /// It is used to trigger any turn specific events.
  void onNextTurn() {
    // TODO implement persistence and analytics
  }

  /// This method is called at the end of each round.
  /// It is used to trigger any round specific events.
  void onNextRound() {
    /// Increment the economic cycle
    economyManager.updateCycle();

    /// Increment the world event
    worldEventManager.incrementWorldEvent();

    /// Update the market state ie incrementing stock prices state
    marketManager.updateMarket();

    /// Reset cashflow for all players to track cashflow for new round
    accountsManager.resetPlayerCashflow();

    /// Credit interest for all player accounts
    accountsManager.creditInterest();

    /// Credit salary for all employed players
    careerManager.creditSalary();

    /// Credit passive XP gains for all players
    skillManager.creditPassiveXPGain();

    /// Credit business earnings for all player businesses
    businessManager.creditBusinessEarnings();

    /// Update each businesses current revenue based on the number of competitors
    businessManager.growBusinesses();

    /// Auto repay loans for all players after crediting all earnings
    loanManager.autoRepayLoans();
  }

  /// This method updates all relavant systems and increments the game turn.
  void nextTurn() {
    log.info(
        "------------------------------- Next Turn -------------------------------");
    _turn = (_turn + 1) % playerManager.getPlayerCount();

    if (_turn == 0) {
      /// Run all round triggered events, skip the starting round
      if (round != 0) onNextRound();

      /// Next round
      _round++;
    }

    playerManager.setActivePlayer(_turn);

    /// Run all turn triggered events
    onNextTurn();

    log.info(
        "Current round: $round, Current Turn: $_turn, Active Player: ${playerManager.getActivePlayer().name}");
  }

  void changeTurn(Player player) {
    _turn = playerManager.players.indexOf(player);
    playerManager.setActivePlayer(_turn);

    log.info(
        "Current round: $round, Current Turn: $_turn, Active Player: ${playerManager.getActivePlayer().name}");
  }

  int rollDice() {
    if (turn == lastDiceRoll.turn && round == lastDiceRoll.round) {
      log.warning("Player has already rolled the dice this turn");
      return lastDiceRoll.roll;
    }

    int roll = _random.nextInt(6) + 1;
    lastDiceRoll = DiceRollResult(roll, round, turn);

    log.info("Dice rolled with result: $roll");

    boardManager.movePlayer(activePlayer, roll);
    return roll;
  }

  int getLastDiceRoll() {
    return lastDiceRoll.roll;
  }
}

class DiceRollResult {
  final int roll;
  final int round;
  final int turn;

  DiceRollResult(this.roll, this.round, this.turn);
}

class GameLeaderboard {
  final Player player;
  final double points;
  final double totalAssets;
  final double totalDebt;
  final PlayerGoals playerGoal;
  final int cumulativeEsgScore;
  final int happinessFactor;

  GameLeaderboard(
    this.player,
    this.points, {
    required this.totalAssets,
    required this.totalDebt,
    required this.playerGoal,
    required this.cumulativeEsgScore,
    required this.happinessFactor,
  });
}
