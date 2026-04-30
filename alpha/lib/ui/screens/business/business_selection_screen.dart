import 'dart:async';

import 'package:alpha/extensions.dart';
import 'package:alpha/logic/business_logic.dart';
import 'package:alpha/logic/data/business.dart';
import 'package:alpha/logic/hints_logic.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/players_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/screens/business/dialogs/additional_landing_dialogs.dart';
import 'package:alpha/ui/screens/business/dialogs/confirm_loan_dialog.dart';
import 'package:alpha/ui/screens/business/dialogs/confirm_purchase_business_dialog.dart';
import 'package:alpha/ui/screens/business/dialogs/landing_dialog_selection.dart';
import 'package:alpha/ui/screens/business/widgets/business_selection_card.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:alpha/ui/screens/next_turn/widgets/player_avatar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;

class BusinessSelectionScren extends StatefulWidget {
  final BusinessSector sector;

  const BusinessSelectionScren(
      {super.key, this.sector = BusinessSector.technology});

  @override
  State<BusinessSelectionScren> createState() => _BusinessSelectionScrenState();
}

class _BusinessSelectionScrenState extends State<BusinessSelectionScren> {
  final GlobalKey scaffoldKey = GlobalKey();

  late final List<Business> _businesses =
      businessManager.generateBusinesses(widget.sector, 5);

  final CarouselSliderController _controller = CarouselSliderController();

  late Business _selectedBusiness = _businesses[0];

  final ValueNotifier<bool> hasPurchasedBusiness = ValueNotifier(false);

  get width => null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Durations.medium1, _showBusinessDialogs);
    });
  }

  void _showBusinessDialogs() {
    final AlphaScaffoldState scaffoldState =
        scaffoldKey.currentState as AlphaScaffoldState;

    /// If should show hint, show the hint first then show the additional dialog
    if (hintsManager.shouldShowHint(activePlayer, Hint.buyBusiness)) {
      scaffoldState.showDialog(AlphaDialogBuilder(
          title: "Welcome",
          child: const BusinessesLandingDialog(),
          next: DialogButtonData.confirm(onTap: () {
            scaffoldState.dismissDialog();

            Future.delayed(Durations.medium1,
                () => {scaffoldState.showDialog(_buildAdditionalDialog())});
          })));

      return;
    }

    /// Else show the additional dialog
    scaffoldState.showDialog(_buildAdditionalDialog());
  }

  AlphaDialogBuilder _buildAdditionalDialog() {
    final List<Player> competitors =
        businessManager.getCompetitors(widget.sector);

    final int numCompetitors = competitors.length;
    final int numBusinesses = businessManager.getBusinessCount(widget.sector);

    if (numCompetitors == 0 && numBusinesses == 0) {
      return AlphaDialogBuilder(
          title: "Congratulations",
          child: const BusinessPioneerDialog(),
          next: DialogButtonData.confirm(
            onTap: () => (scaffoldKey.currentState as AlphaScaffoldState)
                .dismissDialog(),
          ));
    }

    if (numCompetitors == 1 && competitors.contains(activePlayer)) {
      return AlphaDialogBuilder(
          title: "Good News",
          child: const BusinessMonopolyDialog(),
          next: DialogButtonData.confirm(
            onTap: () => (scaffoldKey.currentState as AlphaScaffoldState)
                .dismissDialog(),
          ));
    }

    if (numCompetitors >= 2) {
      return AlphaDialogBuilder(
          title: "Be Cautious",
          child: const BusinessOligopolyDialog(),
          next: DialogButtonData.confirm(
            onTap: () => (scaffoldKey.currentState as AlphaScaffoldState)
                .dismissDialog(),
          ));
    }

    return AlphaDialogBuilder(
        title: "Bad News",
        child: const BusinessSaturatedDialog(),
        next: DialogButtonData.confirm(
          onTap: () =>
              (scaffoldKey.currentState as AlphaScaffoldState).dismissDialog(),
        ));
  }

  void _handlePageChanged(int index) {
    setState(() {
      _selectedBusiness = _businesses[index];
    });
  }

  bool _canPurchase() {
    final double balance = accountsManager.getAvailableBalance(activePlayer);

    return balance + LoanManager.kBusinessLoanAmount >=
        _selectedBusiness.initialCost;
  }

  void _handlePurchase(BuildContext context) async {
    if (!_canPurchase()) {
      context.showSnackbar(
          message: "✋🏼 Insufficients funds to start this business");
      return;
    }

    final double balance = accountsManager.getAvailableBalance(activePlayer);

    if (balance < _selectedBusiness.initialCost) {
      await _showLoanDialog(context);
    }

    context.showDialog(
        buildConfirmBuyBusinessDialog(context, _selectedBusiness, () {
      businessManager.buyBusiness(activePlayer, _selectedBusiness);
      context.dismissDialog();
      hasPurchasedBusiness.value = true;
      context.showSnackbar(
          message:
              "🎉 Business purchased successfully. Press Next to continue.");
    }));
  }

  Future<void> _showLoanDialog(BuildContext context) {
    final completer = Completer();

    context.showDialog(buildConfirmBusinessLoanDialog(context, () {
      loanManager.applyBusinessLoan(activePlayer);
      context.dismissDialog();
      context.showSnackbar(
          message: "🎉 Loan success. You can now purchase a business.");

      Future.delayed(Durations.medium1, () => completer.complete());
    }));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      key: scaffoldKey,
      title: "Choose A Business",
      onTapBack: () => Navigator.pop(context),
      next:
          AlphaButton.next(onTap: () => context.navigateTo(DashboardScreen())),
      children: [
        const SizedBox(height: 25.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PlayerAccountBalanceStatCard(
                accountsManager.getPlayerAccount(activePlayer)),
            const SizedBox(width: 20.0),
            PlayerDebtStatCard(loanManager.getPlayerDebt(activePlayer)),
          ],
        ),
        const SizedBox(height: 20.0),
        AlphaContainer(
            width: 480.0,
            height: 130.0,
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Row(
              children: [
                Image.asset(_selectedBusiness.sector.asset.path),
                const SizedBox(width: 15.0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedBusiness.sector.name,
                        style: TextStyles.bold23),
                    Text("Competitors",
                        style:
                            TextStyles.bold16.copyWith(color: Colors.black87)),
                    const SizedBox(height: 5.0),
                    SizedBox(
                      height: 38.0,
                      child: ListenableBuilder(
                          listenable:
                              businessManager.getBusinessVenture(activePlayer),
                          builder: (context, _) {
                            final List<Player> competitors = businessManager
                                .getCompetitors(_selectedBusiness.sector);

                            if (competitors.isEmpty) {
                              return const Text("No competitors yet.",
                                  style: TextStyles.medium15);
                            }

                            return Wrap(
                              spacing: 10.0,
                              children: competitors
                                  .map((Player competitor) => Tooltip(
                                        triggerMode: TooltipTriggerMode.tap,
                                        message: competitor.name,
                                        verticalOffset: 20.0,
                                        child: PlayerAvatarWidget(
                                          player: competitor,
                                          radius: 18.0,
                                        ),
                                      ))
                                  .toList(),
                            );
                          }),
                    )
                  ],
                )
              ],
            )),
        const SizedBox(height: 15.0),
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: _businesses.length,
          itemBuilder: (context, index, _) {
            final business = _businesses[index];

            return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: BusinessSelectionCard(business));
          },
          options: CarouselOptions(
              onPageChanged: (index, _) => _handlePageChanged(index),
              height: 360.0,
              enlargeFactor: 0.15,
              enlargeCenterPage: true,
              viewportFraction: 0.4),
        ),
        const SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ValueListenableBuilder(
              valueListenable: hasPurchasedBusiness,
              builder: (context, purchased, _) => !purchased
                  ? ListenableBuilder(
                      listenable:
                          accountsManager.getPlayerAccount(activePlayer),
                      builder: (context, _) => AlphaButton(
                          width: 330.0,
                          title: "Start Business",
                          disabled: !_canPurchase(),
                          color: AlphaColors.green,
                          onTapDisabled: () => _handlePurchase(context),
                          onTap: () => _handlePurchase(context)),
                    )
                  : const SizedBox(height: 70.0)),
        ),
      ],
    );
  }
}
