import 'package:alpha/extensions.dart';
import 'package:alpha/logic/hints_logic.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/real_estate_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/common/animated_value.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:alpha/ui/screens/real_estate/dialogs/confirm_buy_realestate_dialog.dart';
import 'package:alpha/ui/screens/real_estate/dialogs/landing_dialog.dart';
import 'package:alpha/ui/screens/real_estate/dialogs/purchase_success_dialog.dart';
import 'package:alpha/ui/screens/real_estate/widgets/real_estate_listing.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  RealEstate _selectedRealEstate =
      realEstateManager.getAvailableRealEstates(activePlayer).first;

  void _handleBuyRealEstate(BuildContext context) {
    context.showDialog(
        buildConfirmBuyRealEstateDialog(context, _selectedRealEstate, () {
      realEstateManager.buyRealEstate(activePlayer, _selectedRealEstate);

      context.dismissDialog();
      Future.delayed(Durations.medium1, () {
        context.showDialog(buildBoughtRealEstateDialog(
            context,
            _selectedRealEstate,
            () => context.navigateAndPopTo(DashboardScreen())));
      });
    }));
  }

  void _handleBuyDisabled(BuildContext context) {
    if (accountsManager.getAvailableBalance(activePlayer) <
        _selectedRealEstate.downPayment) {
      context.showSnackbar(
          message: "✋🏼 Insufficient balance to afford the downpayment.");
      return;
    }

    final LoanApplicationOutcome outcome = loanManager.canPlayerTakeLoan(
        activePlayer,
        newLoanRepaymentPerRound: _selectedRealEstate.repaymentPerRound,
        reason: LoanReason.mortgage);

    if (outcome.isApproved) {
      return;
    }

    if (outcome.rejectReason == LoanRejectReason.insufficientIncome) {
      context.showSnackbar(
          message: "✋🏼 Insufficient income to take a loan for this property.");
      return;
    }

    if (outcome.rejectReason == LoanRejectReason.existingLoan) {
      context.showSnackbar(
          message:
              "✋🏼 You already have an existing mortgage loan. Repay it first.");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      title: "Real Estate",
      onTapBack: () => Navigator.of(context).pop(),
      landingDialog:
          hintsManager.shouldShowHint(activePlayer, Hint.buyRealEstate)
              ? AlphaDialogBuilder.dismissable(
                  title: "Welcome",
                  dismissText: "Confirm",
                  child: const RealEstateSelectionLandingdialog())
              : null,
      next: AlphaButton.next(
          onTap: () => context.navigateAndPopTo(DashboardScreen())),
      children: <Widget>[
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildRealEstateListingsColumn(),
            _buildRealEstateDetailsColumn(context),
          ],
        ),
      ],
    );
  }

  Widget _buildRealEstateListingsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Market Listings",
            style: TextStyles.bold22,
          ),
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          height: 640.0,
          width: 380.0,
          child: SingleChildScrollView(
              child: Wrap(
            runSpacing: 15.0,
            children: realEstateManager
                .getAvailableRealEstates(activePlayer)
                .asMap()
                .map((index, realEstate) => MapEntry(
                    index,
                    GestureDetector(
                      onTap: () =>
                          setState(() => _selectedRealEstate = realEstate),
                      child: RealEstateListing(
                              realEstate: realEstate,
                              selected: realEstate == _selectedRealEstate)
                          .animate()
                          .slideX(
                              curve: Curves.easeOut,
                              duration: Durations.medium2,
                              delay: Duration(milliseconds: 100 * index + 100)),
                    )))
                .values
                .toList(),
          )),
        ),
      ],
    );
  }

  Widget _buildRealEstateDetailsColumn(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            PlayerAccountBalanceStatCard(
                accountsManager.getPlayerAccount(activePlayer)),
            const SizedBox(width: 20.0),
            PlayerDebtStatCard(loanManager.getPlayerDebt(activePlayer)),
          ],
        ),
        const SizedBox(height: 15.0),
        _buildRealEstateDetails(),
        const SizedBox(height: 20.0),
        _buildPurchaseControls(context),
      ],
    );
  }

  Widget _buildRealEstateDetails() {
    return AlphaContainer(
      width: 650.0,
      height: 280.0,
      padding: const EdgeInsets.all(25.0),
      child: Row(
        children: [
          SizedBox(
            width: 280.0,
            height: double.infinity,
            child: Image.asset(
              _selectedRealEstate.image.path,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 25.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Property Name",
                    style: TextStyles.bold18.copyWith(color: Colors.black87),
                  ),
                  SizedBox(
                    width: 260.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxHeight: 35.0, maxWidth: 260.0),
                      child: AutoSizeText(
                        _selectedRealEstate.name,
                        style: TextStyles.bold25,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  _GenericTitleValue(
                      width: 185.0,
                      title: "Property Value",
                      value: _selectedRealEstate.propertyValue.prettyCurrency),
                  _GenericTitleValue(
                      width: 100.0,
                      title: "Growth Rate",
                      value:
                          "${((_selectedRealEstate.growthRate - 1.0) * 100).toStringAsFixed(1)}%"),
                ],
              ),
              const SizedBox(height: 8.0),
              const SizedBox(height: 6.0),
              _GenericTitleValue(
                  title: "Mortgage Amount",
                  value: _selectedRealEstate.mortgage.prettyCurrency),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPurchaseControls(BuildContext context) {
    return AlphaContainer(
      width: 650.0,
      height: 185.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Column(children: <Widget>[
                _GenericTitleValue(
                    width: 200.0,
                    title: "Total Loan Amount",
                    value: _selectedRealEstate.loanAmount.prettyCurrency),
                const SizedBox(height: 6.0),
                _GenericTitleValue(
                    width: 200.0,
                    title: "Interest Rate",
                    value: "${_selectedRealEstate.interestRate.toString()}%"),
              ]),
              Column(children: <Widget>[
                _GenericTitleValue(
                    width: 190.0,
                    title: "Payment Per Round",
                    value:
                        _selectedRealEstate.repaymentPerRound.prettyCurrency),
                const SizedBox(height: 6.0),
                _GenericTitleValue(
                    width: 190.0,
                    title: "Repayment Period",
                    value: "${_selectedRealEstate.repaymentPeriod} rounds"),
              ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("Downpayment", style: TextStyles.bold16),
                    AnimatedValue(
                      _selectedRealEstate.downPayment,
                      currency: true,
                      style: TextStyles.bold30,
                    ),
                    const SizedBox(height: 6.0),
                    Builder(
                      builder: (context) => AlphaButton(
                        width: 205.0,
                        height: 60.0,
                        disabled: !realEstateManager.canPlayerBuyRealEstate(
                            activePlayer, _selectedRealEstate),
                        onTapDisabled: () => _handleBuyDisabled(context),
                        title: "Buy",
                        icon: Icons.shopping_cart_outlined,
                        color: const Color(0xff96DE9D),
                        onTap: () => _handleBuyRealEstate(context),
                      ),
                    ),
                  ]),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenericTitleValue extends StatelessWidget {
  final String title;
  final String value;
  final double width;

  const _GenericTitleValue(
      {required this.title, required this.value, this.width = 260.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyles.bold16.copyWith(color: Colors.black87),
        ),
        SizedBox(
          width: width,
          child: Text(
            value,
            style: TextStyles.bold23,
          ),
        )
      ],
    );
  }
}
