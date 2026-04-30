import 'package:alpha/extensions.dart';
import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/services.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_skill_bar.dart';
import 'package:alpha/ui/screens/careers/career_selection_screen.dart';
import 'package:alpha/ui/screens/careers/dialogs/confirm_promote_dialog.dart';
import 'package:alpha/ui/screens/careers/dialogs/promotion_success_dialog.dart';
import 'package:alpha/ui/screens/careers/widgets/career_progression_card.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CareerProgressionScreen extends StatefulWidget {
  const CareerProgressionScreen({super.key});

  @override
  State<CareerProgressionScreen> createState() =>
      _CareerProgressionScreenState();
}

class _CareerProgressionScreenState extends State<CareerProgressionScreen> {
  bool _canPromote(BuildContext context) {
    return careerManager.canPromote(activePlayer);
  }

  void _handlePromote(BuildContext context) {
    context.showDialog(buildConfirmPromoteDialog(context, () {
      careerManager.promote(activePlayer);
      context.dismissDialog();

      Future.delayed(Durations.medium1, () {
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        _handlePromoted(context);
      });
    }));
  }

  void _handlePromoted(BuildContext context) {
    context.showDialog(buildPromotionSuccessDialog(
        context, careerManager.getPlayerJob(activePlayer), () {
      context.navigateAndPopTo(DashboardScreen());
    }));
  }

  void _handleResign(BuildContext context) {
    context.navigateTo(const JobSelectionScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
        title: "Career",
        onTapBack: () => Navigator.pop(context),
        next: Builder(
          builder: (context) => AlphaButton.next(
            onTap: () => context.navigateTo(DashboardScreen()),
          ),
        ),
        children: <Widget>[
          const SizedBox(height: 20.0),
          AlphaSkillBar(skillManager.getPlayerSkill(activePlayer)),
          const SizedBox(height: 20.0),
          CarouselSlider(
              options: CarouselOptions(
                  initialPage: careerManager.getPlayerJob(activePlayer).tier,
                  height: 500.0,
                  viewportFraction: 0.40,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.scale,
                  enlargeFactor: 0.2,
                  enableInfiniteScroll: false),
              items: _buildCareerProgressionCards()),
          const SizedBox(height: 15.0),
          Builder(
            builder: (context) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 10.0),
                AlphaButton(
                  width: 240.0,
                  title: "Resign",
                  icon: Icons.swap_horiz_rounded,
                  color: const Color(0xFF74BDF8),
                  onTap: () => _handleResign(context),
                ),
                const SizedBox(width: 20.0),
                (careerManager.hasNextTierJob(activePlayer))
                    ? AlphaButton(
                        width: 240.0,
                        title: "Promote",
                        color: const Color(0xFF77D1EA),
                        icon: Icons.arrow_upward_rounded,
                        onTapDisabled: () => context.showSnackbar(
                            message:
                                "✋🏼 You are not qualified for a promotion yet"),
                        disabled: !_canPromote(context),
                        onTap: () => _handlePromote(context),
                      )
                    : const SizedBox()
              ],
            ),
          )
        ]);
  }

  List<Widget> _buildCareerProgressionCards() {
    Job playerJob = careerManager.getPlayerJob(activePlayer);

    final List<Job> jobProgression =
        Job.values.where((job) => job.career == playerJob.career).toList();

    return jobProgression
        .map((job) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: CareerProgressionCard(
                job: job,
                disabled: playerJob != job,
              ),
            ))
        .toList();
  }
}
