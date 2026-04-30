import 'package:alpha/extensions.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class PlayerCard extends StatelessWidget {
  final Player player;
  final bool active;

  const PlayerCard({super.key, required this.player, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 430.0,
      height: 190.0,
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: !active
              ? Border.all(color: Colors.black, width: 4.0)
              : Border.all(color: const Color(0xFFC92E2E), width: 5.0),
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: <BoxShadow>[
            !active
                ? const BoxShadow(color: Colors.black, offset: Offset(2.0, 2.0))
                : const BoxShadow(
                    color: Color(0xFFC92E2E), offset: Offset(2.0, 2.0))
          ]),
      child: Row(
        children: <Widget>[
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              SizedBox(
                width: 125.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100.0),
                  child: Image.asset(
                    "assets/images/player_default.png",
                  ),
                ),
              ),
              Container(
                width: 80.0,
                height: 32.0,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 2.0, right: 1.0),
                transform: Matrix4.translation(Vector3(-1.0, 5.0, 0)),
                decoration: BoxDecoration(
                    color: const Color(0xffBFF3FF),
                    border: Border.all(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(50.0)),
                child: Text(
                  skillManager.getPlayerSkill(player).level.toString(),
                  style: TextStyles.bold20,
                ),
              )
            ],
          ),
          const SizedBox(width: 30.0),
          Column(
            children: <Widget>[
              Container(
                width: 200.0,
                height: 40.0,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 3.0),
                decoration: BoxDecoration(
                    color: const Color(0xffBFF3FF),
                    border: Border.all(color: Colors.black, width: 2.0),
                    borderRadius: BorderRadius.circular(50.0)),
                child: Text(
                  player.name,
                  style: TextStyles.bold20,
                ),
              ),
              const SizedBox(height: 15.0),
              Text(
                "💵 ${accountsManager.getAvailableBalance(player).prettyCurrency}",
                style: TextStyles.medium20,
              ),
              const SizedBox(height: 5.0),
              Text(
                "❤️ ${statsManager.getPlayerStats(player).happiness}",
                style: TextStyles.medium20,
              )
            ],
          )
        ],
      ),
    );
  }
}
