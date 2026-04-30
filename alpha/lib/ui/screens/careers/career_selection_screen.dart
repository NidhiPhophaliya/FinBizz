import 'package:alpha/extensions.dart';
import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_scrollbar.dart';
import 'package:alpha/ui/screens/careers/dialogs/confirm_job_dialog.dart';
import 'package:alpha/ui/screens/careers/dialogs/job_success_dialog.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:alpha/ui/screens/careers/widgets/job_selection_card.dart';
import 'package:flutter/material.dart';

class JobSelectionScreen extends StatefulWidget {
  final bool chooseStartingJob;

  const JobSelectionScreen({super.key, this.chooseStartingJob = false});

  @override
  State<JobSelectionScreen> createState() => _JobSelectionScreenState();
}

class _JobSelectionScreenState extends State<JobSelectionScreen> {
  late final List<CareerSector> careers;

  Job _selectedJob = Job.unemployed;

  final ScrollController _scrollController = ScrollController();

  /// Event Handlers
  void _handleOnTapCard(JobSelectionCard card, BuildContext context) {
    // This function is called when a job card is pressed
    if (card.disabled && card.eligible) {
      _showCareerProgressionMessage(context);
      return;
    }

    if (card.disabled && !card.eligible) {
      _showIneligibleMessage(context);
      return;
    }

    setState(() {
      _selectedJob = card.job;
    });
  }

  void _handleConfirmJobSelection(BuildContext context) {
    /// This function maps to the action of the CONFIRM button of the screen
    if (_selectedJob == Job.unemployed) {
      context.showSnackbar(message: "✋🏼 Please select a job to continue");
      return;
    }

    if (widget.chooseStartingJob) {
      Navigator.pop(context, _selectedJob);
      return;
    }

    final AlphaDialogBuilder dialog = buildJobConfirmDialog(
        context, _selectedJob, () => _handleDialogConfirmation(context));
    context.showDialog(dialog);
  }

  void _handleDialogConfirmation(BuildContext context) {
    /// This function is called when the user confirms the job selection in the dialog
    careerManager.employ(activePlayer, _selectedJob, gameManager.round);

    AlphaDialogBuilder successDialog =
        buildJobSuccessDialog(context, _selectedJob, () {
      context.dismissDialog();
      context.navigateAndPopTo(DashboardScreen());
    });

    context.showDialog(successDialog);
  }

  void _showIneligibleMessage(BuildContext context) {
    /// This function is called when an ineligible card is pressed
    context.showSnackbar(
        message: "✋🏼 Your education level is not qualified for that job.");
  }

  void _showCareerProgressionMessage(BuildContext context) {
    /// This function is called when a disabled card is pressed.
    context.showSnackbar(
        message: "✋🏼 You have to progress through that career for the job.");
  }

  @override
  void initState() {
    careers = _getSortedCareers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
        title: "Choose a Career",
        onTapBack: () => Navigator.of(context).pop(),
        landingMessage: "🎯 Choose a career you would like to pursue",
        next: Builder(
            builder: (BuildContext context) => AlphaButton(
                width: 230.0,
                title: "Confirm",
                onTap: () => _handleConfirmJobSelection(context))),
        children: <Widget>[
          const SizedBox(height: 10),
          // This is the list of job cards of the jobs from career type
          Expanded(
            child: AlphaScrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: _buildJobCards(),
                ),
              ),
            ),
          )
        ]);
  }

  /// Widget Builders
  List<JobSelectionCard> _buildCareerJobCards(CareerSector career) {
    return Job.values
        .where((job) => job.career == career)
        .map((job) => JobSelectionCard(
            job: job,
            selected: job == _selectedJob,
            disabled: !_isQualified(job) || job.tier != 0,
            eligible: _isQualified(job) || job.tier != 0))
        .toList()
      ..sort((JobSelectionCard a, JobSelectionCard b) {
        // sort by tier ascending
        return a.job.tier.compareTo(b.job.tier);
      });
  }

  List<Widget> _buildJobCards() {
    /// This function builds all of the job cards for each career sector
    return careers
        .map((CareerSector career) => Container(
              decoration: const BoxDecoration(
                  border: Border.symmetric(
                      horizontal: BorderSide(color: Colors.black, width: 2.5))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(left: 25.0, right: 20.0),
                      width: 240.0,
                      // display the title of the career in bold and some brief description of the career
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(career.title, style: TextStyles.bold25),
                          const SizedBox(height: 2.0),
                          Text(career.description, style: TextStyles.medium15),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 440.0,
                        width: double.infinity,
                        child: ListView(
                          clipBehavior: Clip.hardEdge,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(
                              left: 10.0, top: 35.0, bottom: 10.0),
                          children: _buildCareerJobCards(career)
                              .map((JobSelectionCard card) => Builder(
                                    builder: (BuildContext context) =>
                                        GestureDetector(
                                      onTap: () =>
                                          _handleOnTapCard(card, context),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 28.0),
                                        child: AspectRatio(
                                          aspectRatio: 0.85,
                                          child: card,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ))
        .toList();
  }

  /// Utility Methods
  bool _isQualified(Job job) {
    if (widget.chooseStartingJob) {
      return job.tier == 0;
    }
    return careerManager.isQualified(activePlayer, job);
  }

  List<CareerSector> _getSortedCareers() {
    List<CareerSector> careerSectors = List.from(CareerSector.values)
      ..remove(CareerSector.unemployed);

    return careerSectors
      ..sort((CareerSector a, CareerSector b) {
        final Job jobA = Job.values
            .firstWhere((Job job) => job.career == a && job.tier == 0);
        final Job jobB = Job.values
            .firstWhere((Job job) => job.career == b && job.tier == 0);

        if (_isQualified(jobA) && !_isQualified(jobB)) {
          return -1;
        } else if (!_isQualified(jobA) && _isQualified(jobB)) {
          return 1;
        } else {
          return jobA.salary.compareTo(jobB.salary);
        }
      });
  }
}
