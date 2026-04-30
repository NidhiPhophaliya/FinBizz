import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class PlayerStats extends ChangeNotifier {
  static const int kBaseHappiness = 100;
  static const int kBaseESG = 0;

  int _happiness = kBaseHappiness;
  int _esg = kBaseESG;

  PlayerStats({int? happiness, int? esg}) {
    _happiness = happiness ?? kBaseHappiness;
    _esg = esg ?? kBaseESG;
  }

  int get happiness => _happiness;
  int get esg => _esg;

  void updateHappiness(int delta) {
    _happiness += delta;
    notifyListeners();
  }

  void updateESG(int delta) {
    _esg += delta;
    notifyListeners();
  }
}

class StatsManager implements IManager {
  @override
  final Logger log = Logger('StatsManager');

  final Map<Player, PlayerStats> _stats = {};

  void initialisePlayerStats(List<Player> players) {
    for (Player player in players) {
      _stats[player] = PlayerStats();
    }
  }

  PlayerStats getPlayerStats(Player player) {
    if (!_stats.containsKey(player)) {
      _stats[player] = PlayerStats();
    }

    return _stats[player]!;
  }

  void addHappiness(Player player, int delta) {
    _stats[player]!.updateHappiness(delta);

    log.info(
        "Player $player has gained $delta happiness, total: ${_stats[player]!.happiness}");
  }

  void deductHappiness(Player player, int delta) {
    _stats[player]!.updateHappiness(-delta);

    log.info(
        "Player $player has lost $delta happiness, total: ${_stats[player]!.happiness}");
  }

  void addESG(Player player, int delta) {
    _stats[player]!.updateESG(delta);

    log.info(
        "Player $player has gained $delta ESG, total: ${_stats[player]!.esg}");
  }

  void deductESG(Player player, int delta) {
    _stats[player]!.updateESG(-delta);

    log.info(
        "Player $player has lost $delta ESG, total: ${_stats[player]!.esg}");
  }
}
