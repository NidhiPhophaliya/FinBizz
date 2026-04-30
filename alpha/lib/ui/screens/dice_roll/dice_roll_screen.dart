import 'package:alpha/extensions.dart';
import 'package:alpha/services.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/screens/dice_roll/widgets/dice_roll_anim.dart';
import 'package:alpha/ui/screens/game_tile/game_tile_screen.dart';
import 'package:flutter/material.dart';

class DiceRollScreen extends StatefulWidget {
  const DiceRollScreen({super.key});

  @override
  State<DiceRollScreen> createState() => _DiceRollScreenState();
}

class _DiceRollScreenState extends State<DiceRollScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  bool _hasRolledDice = false;

  @override
  void initState() {
    // initialize [AnimationController] and put dice at end of animation
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 0));
    _animController.forward();
    _animController.duration = const Duration(milliseconds: 2500);
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _diceRollInProgress(BuildContext context) {
    AlphaScaffold.of(context)
        .showSnackbar(message: "✋🏼 The dice is already rolling");
  }

  void _handleRollDice(BuildContext context) {
    gameManager.rollDice();

    setState(() {
      _hasRolledDice = true;
      _animController.reset();
      _animController.forward();

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        context.navigateTo(GameTileScreen());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(title: "Dice Roll", children: <Widget>[
      Transform.translate(
          offset: const Offset(0, -40.0),
          child: DiceRollAnimation(controller: _animController)),
      const SizedBox(height: 30.0),
      Builder(
          builder: (BuildContext context) => AlphaButton(
                width: 240.0,
                height: 70.0,
                title: "ROLL DICE",
                icon: Icons.arrow_upward_rounded,
                onTap: () => _handleRollDice(context),
                disabled: _hasRolledDice,
                onTapDisabled: () => _diceRollInProgress(context),
              ))
    ]);
  }
}
