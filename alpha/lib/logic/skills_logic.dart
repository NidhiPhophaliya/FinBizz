import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class PlayerSkill extends ChangeNotifier {
  static int xpPerLevel = 1000;

  int _value = 0;

  PlayerSkill();

  int get totalExp => _value;
  int get levelExp => _value % xpPerLevel;
  double get levelPercent => levelExp / xpPerLevel;
  int get level => (_value ~/ xpPerLevel) + 1;

  void add(int delta) {
    assert(delta > 0);
    _value += delta;
    notifyListeners();
  }
}

class SkillManager implements IManager {
  static const int kPassiveExpPerRound = 500;

  @override
  final Logger log = Logger("SkillManager");

  final Map<Player, PlayerSkill> _skills = {};

  void initialisePlayerSkills(List<Player> players) {
    for (Player player in players) {
      _skills[player] = PlayerSkill();
    }
  }

  void creditPassiveXPGain() {
    for (Player player in _skills.keys) {
      addExp(player, kPassiveExpPerRound);
    }
  }

  PlayerSkill getPlayerSkill(Player player) {
    return _skills[player]!;
  }

  void addExp(Player player, int exp) {
    _skills[player]!.add(exp);
    log.info("Player ${player.name} gained $exp exp");
  }
}
