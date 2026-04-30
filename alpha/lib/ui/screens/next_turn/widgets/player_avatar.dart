import 'package:alpha/logic/players_logic.dart';
import 'package:flutter/material.dart';

class PlayerAvatarWidget extends StatelessWidget {
  final double radius;
  final Player player;

  const PlayerAvatarWidget(
      {super.key, required this.player, this.radius = 150.0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(width: (4.5 / 200.0) * radius),
          ),
        ),
        Container(
          width: radius * 2,
          height: radius * 2,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: player.playerColor.color.withAlpha(160),
            border: Border.all(width: (4.5 / 200.0) * radius),
            image: DecorationImage(
              image: AssetImage(player.playerAvatar.image.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
