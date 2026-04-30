import 'package:alpha/logic/game_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/screens/next_turn/widgets/player_avatar.dart';
import 'package:flutter/material.dart';

class GameEndPlayerTile extends StatelessWidget {
  final int index;
  final GameLeaderboard leaderboard;

  const GameEndPlayerTile(this.index, this.leaderboard, {super.key});

  @override
  Widget build(BuildContext context) {
    return AlphaContainer(
      width: 500.0,
      height: 135.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(index.toString(), style: TextStyles.bold25),
          const SizedBox(width: 15.0),
          PlayerAvatarWidget(player: leaderboard.player, radius: 50.0),
          const SizedBox(width: 25.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(leaderboard.player.name, style: TextStyles.bold25),
              const SizedBox(height: 2.0),
              const Text("Total Points", style: TextStyles.bold18),
              const SizedBox(height: 2.0),
              Text(leaderboard.points.round().toString(),
                  style: TextStyles.bold22),
            ],
          )
        ],
      ),
    );
  }
}
