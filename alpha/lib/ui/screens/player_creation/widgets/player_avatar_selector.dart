import 'package:alpha/logic/data/player.dart';
import 'package:flutter/material.dart';

class PlayerAvatarSelectorController extends ChangeNotifier {
  final List<PlayerAvatar> avatars;
  PlayerAvatar selectedAvatar;

  PlayerAvatarSelectorController({required this.avatars})
      : selectedAvatar = avatars.first;

  void selectAvatar(PlayerAvatar avatar) {
    selectedAvatar = avatar;
    notifyListeners();
  }
}

class PlayerAvatarSelector extends StatefulWidget {
  final Color backgroundColor;
  final PlayerAvatarSelectorController controller;

  const PlayerAvatarSelector(
      {super.key,
      required this.controller,
      this.backgroundColor = Colors.white});

  @override
  State<PlayerAvatarSelector> createState() => _PlayerAvatarSelectorState();
}

class _PlayerAvatarSelectorState extends State<PlayerAvatarSelector> {
  late final PlayerAvatarSelectorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  void _handleAvatarNext() {
    final nextIndex =
        _controller.avatars.indexOf(_controller.selectedAvatar) + 1;
    final nextAvatar =
        _controller.avatars[nextIndex % _controller.avatars.length];
    _controller.selectAvatar(nextAvatar);
  }

  void _handleAvatarPrevious() {
    final previousIndex =
        _controller.avatars.indexOf(_controller.selectedAvatar) - 1;
    final previousAvatar = _controller.avatars[
        previousIndex < 0 ? _controller.avatars.length - 1 : previousIndex];
    _controller.selectAvatar(previousAvatar);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) => Container(
        width: 315.0,
        height: 315.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor.withAlpha(160),
          border: Border.all(width: 4.5),
          image: DecorationImage(
            image: AssetImage(_controller.selectedAvatar.image.path),
            fit: BoxFit.contain,
          ),
        ),
        child: child!,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: _handleAvatarPrevious,
              child: const Icon(Icons.arrow_back_ios, size: 40.0)),
          GestureDetector(
              onTap: _handleAvatarNext,
              child: const Icon(Icons.arrow_forward_ios, size: 40.0)),
        ],
      ),
    );
  }
}
