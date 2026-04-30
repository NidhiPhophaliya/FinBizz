import 'package:alpha/services.dart';
import 'package:alpha/ui/screens/careers/career_progression_screen.dart';
import 'package:alpha/ui/screens/careers/career_selection_screen.dart';
import 'package:flutter/material.dart';

class CareerScreen extends StatelessWidget {
  const CareerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (careerManager.isEmployed(activePlayer)) {
      return const CareerProgressionScreen();
    }

    return const JobSelectionScreen();
  }
}
