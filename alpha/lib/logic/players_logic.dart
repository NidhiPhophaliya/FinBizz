import 'dart:collection';

import 'package:alpha/logic/budget_logic.dart';
import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/logic/data/player.dart';
import 'package:alpha/services.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// The managing class for all [Player] related functionality.
class PlayerManager implements IManager {
  static const int kMaxPlayers = 5;

  final playersList = PlayersList();
  late Player _active;

  @override
  final Logger log = Logger("PlayerManager");

  UnmodifiableListView<Player> getAllPlayers() => playersList.players;
  List<Player> get players => playersList.players;

  int getPlayerCount() => playersList.numPlayers;

  Player getActivePlayer() => _active;

  void setActivePlayer(int? turn) {
    turn = turn ?? gameManager.turn;

    if (turn != gameManager.turn) {
      log.warning(
          "setActivePlayer called for an inactive player! Expected: ${gameManager.turn}; Actual: $turn");
    }

    _active = playersList.get(turn);
  }

  List<PlayerColor> getAvailableColors() {
    final takenColors = playersList.players.map((player) => player.playerColor);
    return PlayerColor.values
        .where((color) => !takenColors.contains(color))
        .toList();
  }

  List<PlayerAvatar> getAvailableAvatars() {
    final takenAvatars =
        playersList.players.map((player) => player.playerAvatar);
    return PlayerAvatar.values
        .where((avatar) => !takenAvatars.contains(avatar))
        .toList();
  }

  void createPlayer(String name, PlayerAvatar avatar, PlayerColor color,
      PlayerGoals goal, Job startingCareer) {
    final newPlayer = Player(
        name: name,
        playerAvatar: avatar,
        playerColor: color,
        goal: goal,
        startingCareer: startingCareer);
    playersList.addPlayer(newPlayer);

    log.info("New player $name added to PlayerList");
  }

  void removePlayer(String name) {
    /// Remove the fist occurrence of [Player] from the [PlayerList] with the given name
    playersList.removePlayerByName(name);

    log.info("Player $name removed from PlayerList");
  }
}

/// This class manages the collection of currently active [Player]s of the game.
class PlayersList extends ChangeNotifier {
  final List<Player> _players = [];
  int _numPlayers = 0;

  int get numPlayers => _numPlayers;
  UnmodifiableListView<Player> get players => UnmodifiableListView(_players);

  Player get(int index) => _players[index];

  void addPlayer(Player player) {
    _numPlayers++;
    _players.add(player);
    notifyListeners();
  }

  void removePlayerByName(String name) {
    _players.remove(_players.firstWhere((player) => player.name == name));
    notifyListeners();
  }
}

class Player extends Equatable {
  final String name;
  final PlayerColor playerColor;
  final PlayerAvatar playerAvatar;
  final PlayerGoals goal;
  final Job startingCareer;

  Player(
      {required this.name,
      required this.playerColor,
      required this.playerAvatar,
      required this.goal,
      required this.startingCareer});

  @override
  List<Object?> get props => [name, playerColor, playerAvatar];

  final budgets = BudgetAllocation(budgets: {
    Budget.dailyExpenses: 2,
    Budget.selfImprovement: 2,
    Budget.recreational: 2,
    Budget.investments: 2,
    Budget.savings: 2
  });
}
