import 'package:alpha/logic/game_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_scrollbar.dart';
import 'package:alpha/ui/screens/game_end/widgets/game_end_player_tile.dart';
import 'package:flutter/material.dart';

class GameEndScreen extends StatelessWidget {
  final ScrollController _controller = ScrollController();

  final List<GameLeaderboard> leaderboard = gameManager.leaderboard;

  GameEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      title: "Game Over",
      children: [
        const SizedBox(height: 10.0),
        const Text(
          "Please do not close out of this screen.",
          style: TextStyles.medium20,
        ),
        const SizedBox(height: 10.0),
        Text("Rounds Played: ${gameManager.round}", style: TextStyles.bold22),
        const SizedBox(height: 5.0),
        Text(
            "Total Points: ${gameManager.leaderboard.fold(0.0, (value, ld) => value + ld.points).round()}",
            style: TextStyles.bold28),
        const SizedBox(height: 5.0),
        const Text("Leaderboard", style: TextStyles.bold32),
        const SizedBox(height: 5.0),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: SizedBox(
            width: 540.0,
            height: MediaQuery.sizeOf(context).height - 270.0,
            child: AlphaScrollbar(
              controller: _controller,
              child: SingleChildScrollView(
                controller: _controller,
                scrollDirection: Axis.vertical,
                child: Wrap(
                    direction: Axis.vertical,
                    spacing: 5.0,
                    children: gameManager.leaderboard
                        .map((ld) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: GameEndPlayerTile(1, ld)))
                        .toList()),
              ),
            ),
          ),
        )
      ],
    );
  }
}
