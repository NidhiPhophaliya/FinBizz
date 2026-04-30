import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:logging/logging.dart';

enum Hint {
  investment,
  opportunity,
  education,
  careerSelection,
  manageBusiness,
  buyBusiness,
  buyCar,
  buyRealEstate,
}

class HintStorage {
  final Map<Hint, bool> _hints = {};

  bool getHint(Hint hint) {
    return _hints[hint] ?? false;
  }

  void setHint(Hint hint, bool value) {
    _hints[hint] = value;
  }
}

class HintsManager implements IManager {
  @override
  final Logger log = Logger("HintsManager");

  final Map<Player, HintStorage> _playerHints = {};

  bool shouldShowHint(Player player, Hint hint) {
    if (!_playerHints.containsKey(player)) {
      _playerHints[player] = HintStorage();
      log.info(
          "Hint storage does not exist yet, created hint storage for player ${player.name}");
    }

    if (_playerHints[player]!.getHint(hint)) {
      return false;
    }

    _playerHints[player]!.setHint(hint, true);
    log.info("Hint $hint is shown to player ${player.name}");
    return true;
  }
}
