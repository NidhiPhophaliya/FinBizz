import 'package:alpha/extensions.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_skill_bar.dart';
import 'package:alpha/ui/screens/dice_roll/dice_roll_screen.dart';
import 'package:alpha/ui/screens/game_end/game_end_screen.dart';
import 'package:alpha/ui/screens/next_turn/widgets/player_avatar.dart';
import 'package:flutter/material.dart';

class PlayersMenuScreen extends StatelessWidget {
  const PlayersMenuScreen({super.key});

  void _handleEndGame(BuildContext context) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('End Game'),
          content: TextField(
            obscureText: true,
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: "Enter the password to end the game."),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Change Turn'),
              onPressed: () {
                if (controller.text == "alpha0502") {
                  _handleChangeTurn(context);
                }
              },
            ),
            TextButton(
              child: const Text('End Game'),
              onPressed: () {
                if (controller.text == "alpha0502") {
                  gameManager.endGame();
                  context.navigateAndPopTo(GameEndScreen());
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _handleChangeTurn(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const Text("Change Turn"),
              children: playerManager.playersList.players.map((player) {
                return SimpleDialogOption(
                  onPressed: () {
                    gameManager.changeTurn(player);
                    context.navigateAndPopTo(const PlayersMenuScreen());
                  },
                  child: Text(player.name),
                );
              }).toList(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      title: "It's ${activePlayer.name}'s turn",
      onTapBack: () => _handleEndGame(context),
      next: Builder(
        builder: (context) => AlphaButton(
          width: 270.0,
          title: "Start Turn",
          onTap: () => context.navigateAndPopTo(const DiceRollScreen()),
        ),
      ),
      children: [
        const SizedBox(height: 80.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayerAvatarWidget(player: activePlayer),
            const SizedBox(width: 40.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(activePlayer.name, style: TextStyles.bold28)),
                const SizedBox(height: 10.0),
                AlphaSkillBarMedium(skillManager.getPlayerSkill(activePlayer)),
                const SizedBox(height: 20.0),
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Text(
                    "Game State",
                    style: TextStyles.bold18,
                  ),
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    AlphaContainer(
                      width: 190.0,
                      height: 50.0,
                      child: Center(
                          child: Text(
                        "🎮 Round ${gameManager.round}",
                        style: TextStyles.bold18.copyWith(height: 1.9),
                      )),
                    ),
                    const SizedBox(width: 10.0),
                    AlphaContainer(
                      width: 250.0,
                      height: 50.0,
                      child: Center(
                          child: Text(
                        "📊 ${economyManager.currentCycle.description}",
                        style: TextStyles.bold16,
                      )),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 40.0),
        const Text("Players", style: TextStyles.bold20),
        const SizedBox(height: 20.0),
        Wrap(
          spacing: 15.0,
          children: playerManager.playersList.players.map((player) {
            final child = Column(
              children: [
                PlayerAvatarWidget(
                  player: player,
                  radius: 60.0,
                ),
                const SizedBox(height: 10.0),
                Text(
                  player.name,
                  style: TextStyles.medium16,
                )
              ],
            );

            return (activePlayer != player)
                ? ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      // Standard grayscale matrix
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: child,
                  )
                : child;
          }).toList(),
        ),
      ],
    );
  }
}
