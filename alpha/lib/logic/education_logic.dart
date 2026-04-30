import 'dart:math';

import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/education.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class PlayerEducation extends ChangeNotifier {
  EducationDegree _level;

  PlayerEducation({required EducationDegree initial}) : _level = initial;

  EducationDegree get level => _level;

  EducationDegree getNext() {
    return EducationDegree
        .values[min(_level.index + 1, EducationDegree.values.length - 1)];
  }

  /// Advance the player's [EducationDegree] to the next
  void pursueNext() {
    _level = getNext();
    notifyListeners();
  }
}

class EducationManager implements IManager {
  static const double kOnlineCoursePrice = 1000.0;
  static const int kOnlineCourseXP = 500;
  static const EducationDegree kStartingDegree = EducationDegree.uneducated;

  @override
  final Logger log = Logger("EducationManager");

  final Map<Player, PlayerEducation> _educations = {};

  void initialisePlayerEducations(List<Player> players) {
    for (final player in players) {
      _educations[player] = PlayerEducation(initial: kStartingDegree);
    }
  }

  PlayerEducation getEducation(Player player) {
    if (!_educations.containsKey(player)) {
      return PlayerEducation(initial: kStartingDegree);
    }

    return _educations[player]!;
  }

  void pursueNext(Player player) {
    EducationDegree current = _educations[player]!.level;
    EducationDegree next = _educations[player]!.getNext();

    if (current == next) {
      log.warning(
          "Called pursueNext on Player ${player.name} who has already reached the highest education level, ignoring");
      return;
    }

    final double availableBalance = accountsManager.getAvailableBalance(player);

    if (availableBalance < next.cost) {
      log.warning(
          "Player ${player.name} does not have enough balance to pursue ${next.name}, ignoring");
      return;
    }

    /// Pay tuition fees and advance the player's education level
    /// Also add skill points
    accountsManager.deductAny(player, next.cost);
    skillManager.addExp(player, next.xp);
    _educations[player]!.pursueNext();

    log.info(
        "Player ${player.name} pursued to ${next.name}, new XP: ${skillManager.getPlayerSkill(player).totalExp}");
  }

  void pursueOnlineCourse(Player player) {
    final double availableBalance = accountsManager.getAvailableBalance(player);

    if (availableBalance < kOnlineCoursePrice) {
      log.warning(
          "Player ${player.name} does not have enough balance to pursue online course, ignoring");
      return;
    }

    /// Pay tuition fees and add skill points
    accountsManager.deductAny(player, kOnlineCoursePrice);
    skillManager.addExp(player, kOnlineCourseXP);

    log.info(
        "Pursued online course, new XP: ${skillManager.getPlayerSkill(player).totalExp}");
  }
}
