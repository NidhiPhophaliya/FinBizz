import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:flutter/material.dart';

class PlayerCreationCard extends StatelessWidget {
  final Player player;
  final void Function()? onRemove;
  final void Function()? onEdit;

  const PlayerCreationCard(
      {super.key, required this.player, this.onEdit, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: AlphaAnimatedContainer(
          width: 400.0,
          child: Column(
            children: <Widget>[
              Container(
                width: 400.0,
                height: 280.0,
                padding: const EdgeInsets.only(right: 10.0, top: 10.0),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(player.playerAvatar.image.path),
                        fit: BoxFit.cover),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                    color: player.playerColor.color.withAlpha(160)),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                      onTap: onRemove,
                      child: const Icon(Icons.close,
                          color: Colors.black, size: 38.0)),
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                player.name,
                style: TextStyles.bold30,
              ),
              const SizedBox(height: 15.0),
            ],
          ),
        ));
  }
}

class PlayerAddCard extends StatelessWidget {
  final void Function()? onTap;

  const PlayerAddCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: AlphaAnimatedContainer(
          width: 400.0,
          child: Center(
              child: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color.fromARGB(255, 182, 182, 182),
                    width: 3.0)),
            child: const Icon(
              Icons.add,
              size: 40.0,
              color: Color.fromARGB(255, 182, 182, 182),
            ),
          )),
        ));
  }
}
