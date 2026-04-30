import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/logic/board_logic.dart';
import 'package:alpha/logic/budget_logic.dart';
import 'package:alpha/logic/car_logic.dart';
import 'package:alpha/logic/career_logic.dart';
import 'package:alpha/logic/education_logic.dart';
import 'package:alpha/logic/hints_logic.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/opportunity_logic.dart';
import 'package:alpha/logic/personal_life_logic.dart';
import 'package:alpha/logic/real_estate_logic.dart';
import 'package:alpha/logic/business_logic.dart';
import 'package:alpha/logic/economy_logic.dart';
import 'package:alpha/logic/financial_market_logic.dart';
import 'package:alpha/logic/game_logic.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/logic/skills_logic.dart';
import 'package:alpha/logic/stats_logic.dart';
import 'package:alpha/logic/world_event_logic.dart';
import 'package:get_it/get_it.dart';

/// This file contains all the service locators for the commonly used systems in the game.
/// The only singleton used throughout the game is the [GameManager], where
/// it instantiates all relavant managers
///
/// Referencing any manager must be done through the only instance of [GameManager],
/// and should not be instantiated by its own.

/// Service locator for the global singleton of [GameManager]
GameManager get gameManager => GetIt.I.get<GameManager>();

/// Service locator for the [PlayerManager], held by the [GameManager]
PlayerManager get playerManager => GetIt.I.get<GameManager>().playerManager;

/// Service locator for the [activePlayer] instance, held by the [PlayerManager]
Player get activePlayer =>
    GetIt.I.get<GameManager>().playerManager.getActivePlayer();

/// Service locator for the [FinancialMarketManager], held by the [GameManager]
FinancialMarketManager get marketManager =>
    GetIt.I.get<GameManager>().marketManager;

/// Service locator for the [EconomyManager], held by the [GameManager]
EconomyManager get economyManager => GetIt.I.get<GameManager>().economyManager;

/// Service locator for the [BusinessManager], held by the [GameManager]
BusinessManager get businessManager =>
    GetIt.I.get<GameManager>().businessManager;

RealEstateManager get realEstateManager =>
    GetIt.I.get<GameManager>().realEstateManager;

CarManager get carManager => GetIt.I.get<GameManager>().carManager;

CareerManager get careerManager => GetIt.I.get<GameManager>().careerManager;

HintsManager get hintsManager => GetIt.I.get<GameManager>().hintsManager;

OpportunityManager get opportunityManager =>
    GetIt.I.get<GameManager>().opportunityManager;

BoardManager get boardManager => GetIt.I.get<GameManager>().boardManager;

AccountsManager get accountsManager =>
    GetIt.I.get<GameManager>().accountsManager;

LoanManager get loanManager => GetIt.I.get<GameManager>().loanManager;

SkillManager get skillManager => GetIt.I.get<GameManager>().skillManager;

StatsManager get statsManager => GetIt.I.get<GameManager>().statsManager;

EducationManager get educationManager =>
    GetIt.I.get<GameManager>().educationManager;

BudgetManager get budgetManager => GetIt.I.get<GameManager>().budgetManager;

PersonalLifeManager get personalLifeManager =>
    GetIt.I.get<GameManager>().personalLifeManager;

WorldEventManager get worldEventManager =>
    GetIt.I.get<GameManager>().worldEventManager;
