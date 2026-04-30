import 'package:alpha/assets.dart';
import 'package:alpha/logic/skills_logic.dart';
import 'package:alpha/logic/stats_logic.dart';
import 'package:flutter/material.dart';

/// The function signature for the [PlayerGoals] fulfilled checker.
typedef FulfilledChecker = bool Function(
    double totalAssets, PlayerSkill skill, PlayerStats stats);

/// The enum representing the different goals a player can choose from.
enum PlayerGoals {
  marriage(
      "Happiness", "Have 150 points of happiness", AlphaAsset.goalHappiness,
      fulfilledChecker: _happinessFulfilledChecker),
  career("Career", "Reach Level 12 in skill level", AlphaAsset.goalCareer,
      fulfilledChecker: _careerFulfilledChecker),
  wealth("Wealth", "Have \$300k in total assets", AlphaAsset.goalWealth,
      fulfilledChecker: _wealthFulfilledChecker);

  final String title;
  final String description;
  final AlphaAsset image;
  final FulfilledChecker fulfilledChecker;

  const PlayerGoals(this.title, this.description, this.image,
      {this.fulfilledChecker = _defaultFulfilledChecker});
}

bool _defaultFulfilledChecker(
    double totalAssets, PlayerSkill skill, PlayerStats stats) {
  return true;
}

bool _happinessFulfilledChecker(
    double totalAssets, PlayerSkill skill, PlayerStats stats) {
  return stats.happiness >= 150;
}

bool _careerFulfilledChecker(
    double totalAssets, PlayerSkill skill, PlayerStats stats) {
  return skill.level >= 12;
}

bool _wealthFulfilledChecker(
    double totalAssets, PlayerSkill skill, PlayerStats stats) {
  return totalAssets >= 300000;
}

/// The enum representing the different avatars a player can choose from.
/// Each avatar is associated with its corresponding [AlphaAsset] asset
enum PlayerAvatar {
  avatar1(AlphaAsset.avatarGreenBuns),
  avatar2(AlphaAsset.avatarOrangePonytail),
  avatar3(AlphaAsset.avatarBrownHair),
  avatar4(AlphaAsset.avatarBlackGuy),
  avatar5(AlphaAsset.avatarBlueTShirt),
  avatar6(AlphaAsset.avatarOrangeHoodie),
  avatar7(AlphaAsset.avatarBlueEarphones),
  avatar8(AlphaAsset.avatarBlueHairWhiteBlouse);

  const PlayerAvatar(this.image);

  final AlphaAsset image;
}

/// The enum representing the different colors a player can choose from.
enum PlayerColor {
  red(Color(0xFFF75C5C)),
  green(Color(0xFF7FC36A)),
  blue(Color(0xFF6DBDFA)),
  yellow(Color(0xFFF7F091)),
  white(Color(0xFFFCFCFC)),
  black(Color(0xFF3E3E3E));

  const PlayerColor(this.color);

  final Color color;
}
