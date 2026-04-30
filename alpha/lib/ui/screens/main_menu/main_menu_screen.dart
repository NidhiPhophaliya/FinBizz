import 'package:alpha/ui/screens/landing/landing_screen.dart';
import 'package:alpha/ui/screens/player_creation/player_creation_menu_screen.dart';
import 'package:flutter/material.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _page = 0;
  final PageController _pageController = PageController();

  int get page => _page;

  void _incrementPage() {
    setState(() {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 640),
          curve: Curves.easeOutExpo);
      _page++;
    });
  }

  void _decrementPage() {
    setState(() {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 640),
          curve: Curves.easeOutExpo);
      _page--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        LandingScreen(onTapNext: _incrementPage),
        PlayerCreationMenuScreen(
          onTapBack: _decrementPage,
        ),
      ],
    );
  }
}
