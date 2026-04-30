import 'package:alpha/extensions.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/screens/player_creation/player_creation_screen.dart';
import 'package:alpha/ui/screens/player_creation/widgets/player_creation_card.dart';
import 'package:alpha/ui/screens/next_turn/next_turn_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';

class PlayerCreationMenuScreen extends StatefulWidget {
  final void Function()? onTapBack;

  const PlayerCreationMenuScreen({super.key, this.onTapBack});

  @override
  State<PlayerCreationMenuScreen> createState() => _PlayerCreationMenuScreen();
}

class _PlayerCreationMenuScreen extends State<PlayerCreationMenuScreen> {
  /// Event Handlers
  void _handleAddPlayerBtn() {
    context.navigateTo(const PlayerCreationScreen());
  }

  void _handleNotEnoughPlayers(BuildContext context) {
    AlphaScaffold.of(context).showSnackbar(
        message: "✋🏼 There are not enough players to start the game.");
  }

  void _handleStartBtn() {
    gameManager.startGame();
    context.navigateAndPopTo(const PlayersMenuScreen());
  }

  /// Widget Builders
  Widget _nextBtnBuilder(BuildContext context, Widget? child) => AlphaButton(
        width: 290.0,
        height: 70.0,
        title: "Start Game",
        onTap: _handleStartBtn,
        disabled: playerManager.getPlayerCount() < 1,
        onTapDisabled: () => _handleNotEnoughPlayers(context),
      );

  List<Widget> _buildPlayerCards() {
    final List<Widget> cards = [];
    final players = playerManager.getAllPlayers();

    for (final player in players) {
      cards.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: PlayerCreationCard(
          player: player,
          onRemove: () => playerManager.removePlayer(player.name),
        ),
      ));
    }

    if (players.length < PlayerManager.kMaxPlayers) {
      cards.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: PlayerAddCard(onTap: _handleAddPlayerBtn)));
    }

    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      title: "Players",
      onTapBack: widget.onTapBack,
      landingMessage:
          "👥 Add players by tapping the '+' button to start the game.",
      next: ListenableBuilder(
          listenable: playerManager.playersList, builder: _nextBtnBuilder),
      children: <Widget>[
        const SizedBox(height: 80.0),
        ListenableBuilder(
            listenable: playerManager.playersList,
            builder: (context, child) => CarouselSlider(
                  options: CarouselOptions(
                    height: 450.0,
                    viewportFraction: 0.40,
                    enableInfiniteScroll: false,
                    enlargeCenterPage: true,
                  ),
                  items: _buildPlayerCards(),
                )),
      ],
    );
  }
}
