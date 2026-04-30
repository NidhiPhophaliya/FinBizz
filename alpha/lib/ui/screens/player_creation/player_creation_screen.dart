import 'package:alpha/assets.dart';
import 'package:alpha/extensions.dart';
import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/logic/data/player.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_scrollbar.dart';
import 'package:alpha/ui/screens/careers/career_selection_screen.dart';
import 'package:alpha/ui/screens/player_creation/widgets/life_goal_selector.dart';
import 'package:alpha/ui/screens/player_creation/widgets/player_avatar_selector.dart';
import 'package:alpha/ui/screens/player_creation/widgets/player_color_selector.dart';
import 'package:flutter/material.dart';

class PlayerCreationScreen extends StatefulWidget {
  const PlayerCreationScreen({super.key});

  @override
  State<PlayerCreationScreen> createState() => _PlayerCreationScreenState();
}

class _PlayerCreationScreenState extends State<PlayerCreationScreen> {
  String _playerName = "";
  PlayerGoals _selectedGoal = PlayerGoals.marriage;

  late final PlayerAvatarSelectorController _avatarController;
  PlayerColor _selectedColor = playerManager.getAvailableColors().first;

  Job _selectedStartingJob = Job.unemployed;

  final ScrollController _scrollController = ScrollController();

  void _handlePlayerNameEditingComplete(String name) {
    _playerName = name.trim();
  }

  void _handleColorSelection(PlayerColor color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _handleGoalSelection(PlayerGoals goal) {
    setState(() {
      _selectedGoal = goal;
    });
  }

  void _handleSelectStartingCareer(BuildContext context) async {
    final Job? selectedJob = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const JobSelectionScreen(chooseStartingJob: true)));

    if (selectedJob == null) return;

    setState(() {
      _selectedStartingJob = selectedJob;
    });
  }

  void _handleAddPlayer(BuildContext context) {
    if (_playerName.trim().isEmpty) {
      context.showSnackbar(message: "✋🏼 Please enter a valid player name.");
      return;
    }

    if (_playerName.trim().length > 15) {
      context.showSnackbar(
          message: "✋🏼 Please keep your name under 15 characters.");
      return;
    }

    if (_selectedStartingJob == Job.unemployed) {
      context.showSnackbar(message: "✋🏼 Please select a starting career.");
      return;
    }

    playerManager.createPlayer(
        _playerName.trim(),
        _avatarController.selectedAvatar,
        _selectedColor,
        _selectedGoal,
        _selectedStartingJob);

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _avatarController = PlayerAvatarSelectorController(
        avatars: playerManager.getAvailableAvatars());
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
        title: "Create Player",
        onTapBack: () => Navigator.pop(context),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlayerAvatarSelector(
                controller: _avatarController,
                backgroundColor: _selectedColor.color,
              ),
              const SizedBox(width: 35.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AlphaContainer(
                    height: 570.0,
                    width: 650.0,
                    padding: const EdgeInsets.only(
                        top: 20.0, bottom: 5.0, left: 20.0, right: 10.0),
                    child: SizedBox(
                      width: 650.0,
                      child: AlphaScrollbar(
                        controller: _scrollController,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 10.0, bottom: 10.0),
                                child: Text(
                                  "Player Name",
                                  style: TextStyles.bold24,
                                ),
                              ),
                              AlphaContainer(
                                  width: 480.0,
                                  padding: const EdgeInsets.only(
                                      left: 20.0, right: 20.0, top: 4.0),
                                  child: TextField(
                                    style: TextStyles.medium20,
                                    onChanged: (name) =>
                                        _handlePlayerNameEditingComplete(name),
                                    decoration: const InputDecoration(
                                        hintText: "Enter player name",
                                        hintStyle: TextStyles.medium18,
                                        border: InputBorder.none),
                                  )),
                              const SizedBox(height: 25.0),
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 10.0, bottom: 10.0),
                                child: Text(
                                  "Colour",
                                  style: TextStyles.bold24,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Wrap(
                                  spacing: 10.0,
                                  children: playerManager
                                      .getAvailableColors()
                                      .map((color) =>
                                          _buildPlayerColorSelector(color))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 10.0, bottom: 10.0),
                                child: Text(
                                  "Starting Career",
                                  style: TextStyles.bold24,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    _handleSelectStartingCareer(context),
                                child: AlphaContainer(
                                  width: 420.0,
                                  height: 60.0,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 15.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40.0,
                                        height: 40.0,
                                        child: Image.asset(
                                          AlphaAsset.goalCareer.path,
                                        ),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Text.rich(
                                        TextSpan(
                                          text: _selectedStartingJob.title,
                                          style: TextStyles.bold20
                                              .copyWith(height: 2.2),
                                          children: [
                                            TextSpan(
                                                text:
                                                    "  (\$${_selectedStartingJob.salary.toInt()})",
                                                style: TextStyles.bold20
                                                    .copyWith(
                                                        color: const Color(
                                                            0xFF3D8544)))
                                          ],
                                        ),
                                      ),
                                      const Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                            Icons.arrow_forward_ios_rounded),
                                      ))
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 10.0, bottom: 10.0),
                                child: Text(
                                  "Life Goal",
                                  style: TextStyles.bold24,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Wrap(
                                  spacing: 18.0,
                                  children: PlayerGoals.values.map((goal) {
                                    return _buildLifeGoalSelector(goal);
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 25.0)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  Builder(
                    builder: (context) => AlphaButton(
                      width: 640.0,
                      title: "Add Player",
                      onTap: () => _handleAddPlayer(context),
                      color: AlphaColors.green,
                    ),
                  )
                ],
              ),
            ],
          ),
        ]);
  }

  Widget _buildPlayerColorSelector(PlayerColor color) {
    return GestureDetector(
      onTap: () => _handleColorSelection(color),
      child: PlayerColorSelector(
        color: color.color,
        selected: _selectedColor == color,
      ),
    );
  }

  Widget _buildLifeGoalSelector(PlayerGoals goal) {
    return GestureDetector(
      onTap: () => _handleGoalSelection(goal),
      child: LifeGoalSelector(
        goal: goal,
        selected: _selectedGoal == goal,
      ),
    );
  }
}
