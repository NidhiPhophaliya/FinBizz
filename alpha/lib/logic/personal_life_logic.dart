import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/personal_life.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class PersonalLife extends ChangeNotifier {
  PersonalLifeStatus _status;

  PersonalLife({required PersonalLifeStatus initial}) : _status = initial;

  PersonalLifeStatus get status => _status;

  bool get isSingle => _status == PersonalLifeStatus.single;
  bool get isDating => _status == PersonalLifeStatus.dating;
  bool get isMarried => _status == PersonalLifeStatus.marriage;
  bool get isFamily => _status == PersonalLifeStatus.family;

  /// Advance the player's [PersonalLifeStatus] to the next
  void pursue(PersonalLifeStatus next) {
    _status = next;
    notifyListeners();
  }
}

class PersonalLifeManager implements IManager {
  static const PersonalLifeStatus initialStatus = PersonalLifeStatus.single;

  @override
  Logger log = Logger("PersonalLifeManager");

  final Map<Player, PersonalLife> _personalLife = {};

  void initialisePlayerPersonalLife(List<Player> players) {
    for (final player in players) {
      _personalLife[player] = PersonalLife(initial: initialStatus);
    }
  }

  PersonalLife getPersonalLife(Player player) {
    return _personalLife[player]!;
  }

  bool canAffordNextStage(Player player) {
    final double availableBalance = accountsManager.getAvailableBalance(player);
    final next = getNextLifeStage(player);

    return availableBalance >= next.cost;
  }

  void nextLifeStage(Player player) {
    final personalLife = _personalLife[player]!;
    final PersonalLifeStatus next = getNextLifeStage(player);

    if (!canAffordNextStage(player)) {
      log.warning("Player ${player.name} cannot afford next life stage");
      return;
    }

    accountsManager.deductAny(player, next.cost);
    statsManager.addHappiness(player, next.happinessBonus);
    personalLife.pursue(next);
  }

  PersonalLifeStatus getNextLifeStage(Player player) {
    final personalLife = _personalLife[player]!;

    switch (personalLife.status) {
      case PersonalLifeStatus.single:
        return PersonalLifeStatus.dating;
      case PersonalLifeStatus.dating:
        return PersonalLifeStatus.marriage;
      case PersonalLifeStatus.marriage:
        return PersonalLifeStatus.family;
      case PersonalLifeStatus.family:
        return PersonalLifeStatus.family;
    }
  }
}
