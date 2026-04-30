import 'package:alpha/assets.dart';
import 'package:alpha/logic/common/interfaces.dart';
import 'package:alpha/logic/data/opportunity.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/utils.dart';
import 'package:logging/logging.dart';

class Opportunity {
  final String title;
  final String description;
  final AlphaAsset image;
  final int happinessBonus;
  final double cashBonus;
  final double cashPenaltyPercentage;

  Opportunity(
      {required this.title,
      required this.description,
      required this.image,
      required this.happinessBonus,
      required this.cashBonus,
      required this.cashPenaltyPercentage});
}

class OpportunityManager implements IManager {
  @override
  Logger log = Logger("OpportunityManager");

  Opportunity getCurrentOpportunity() {
    String extraSeed = "";

    if (playerManager.players.length > 1) {
      extraSeed = playerManager
          .players[(gameManager.turn + 1) % playerManager.players.length].name;
    }

    final double randomFactor = generateRandomFactor(
        activePlayer.name + extraSeed, gameManager.round + gameManager.turn);

    final int index =
        (randomFactor * (Opportunities.opportunityList.length - 1)).round();

    return Opportunities.opportunityList[index];
  }

  void applyOpportunity(Player player) {
    final opportunity = getCurrentOpportunity();

    statsManager.addHappiness(player, opportunity.happinessBonus);
    accountsManager.creditToSavingsUnbudgeted(player, opportunity.cashBonus);

    accountsManager.deductFromSavings(
        player,
        ((opportunity.cashPenaltyPercentage / 100) *
                accountsManager.getSavingsAccount(player).balance)
            .abs());

    log.info("Player ${player.name} has received ${opportunity.title}");
  }
}
