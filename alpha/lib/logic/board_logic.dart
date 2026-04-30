import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/board_tiles.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:logging/logging.dart';

class PlayerLocation {
  final Player player;
  int _location = 0;

  int get location => _location;

  PlayerLocation(this.player);

  void updateLocation(int newIndex) {
    _location = newIndex;
  }
}

class BoardManager implements IManager {
  @override
  final Logger log = Logger("BoardManager");

  final Map<BoardTile, List<int>> _boardTiles = {
    BoardTile.startTile: [0],
    BoardTile.careerTile: [9, 13, 16, 20],
    BoardTile.educationTile: [3, 8, 14],
    BoardTile.opportunityTile: [1, 12],
    BoardTile.personalLifeTile: [5, 17],
    BoardTile.worldEventTile: [6, 18],
    BoardTile.realEstatesTile: [11, 22],
    BoardTile.carTile: [7, 19],
    BoardTile.businessEcommerceTile: [4],
    BoardTile.businessTechnologyTile: [15],
    BoardTile.businessFnBTile: [10],
    BoardTile.businessPharmaTile: [21],
    BoardTile.businessSocialMediaTile: [2],
  };

  final List<PlayerLocation> _playerLocations = [];

  void initialisePlayerLocations(List<Player> players) {
    for (final player in players) {
      _playerLocations.add(PlayerLocation(player));
    }
  }

  void movePlayer(Player player, int steps) {
    final playerLocation = _playerLocations.firstWhere(
      (playerLocation) => playerLocation.player == player,
    );

    final int currentLocation = playerLocation.location;
    final int newLocation = (currentLocation + steps) % 23;

    playerLocation.updateLocation(newLocation);

    log.info(
        "Player ${player.name} moved from $currentLocation to $newLocation, ${getTile(player)}");
  }

  BoardTile getTile(Player player) {
    PlayerLocation activePlayerLocation = _playerLocations.firstWhere(
      (playerLocation) => playerLocation.player == player,
    );

    for (BoardTile tile in _boardTiles.keys) {
      if (_boardTiles[tile]!.contains(activePlayerLocation.location)) {
        return tile;
      }
    }

    /// Fallback
    return BoardTile.educationTile;
  }

  BoardTile getActivePlayerTile() {
    BoardTile activeTile = getTile(activePlayer);

    if (activeTile == BoardTile.startTile) {
      accountsManager.creditToSavingsUnbudgeted(activePlayer, 2000.0);
    }

    return activeTile;
  }
}
