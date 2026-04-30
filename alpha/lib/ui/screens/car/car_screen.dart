import 'package:alpha/extensions.dart';
import 'package:alpha/logic/car_logic.dart';
import 'package:alpha/logic/hints_logic.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/common/animated_value.dart';
import 'package:alpha/ui/screens/car/dialogs/confirm_buy_dialog.dart';
import 'package:alpha/ui/screens/car/dialogs/confirm_buy_no_debt_dialog.dart';
import 'package:alpha/ui/screens/car/dialogs/landing_dialog.dart';
import 'package:alpha/ui/screens/car/dialogs/purchase_success_dialog.dart';
import 'package:alpha/ui/screens/car/widgets/car_listing.dart';
import 'package:alpha/ui/screens/dashboard/dashboard_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  Car _selectedCar = carManager.getAvailableCars(activePlayer).first;

  bool _canAffordCar(BuildContext context) {
    final double availableBalance =
        accountsManager.getAvailableBalance(activePlayer);

    if (availableBalance >= carManager.getCarPriceWithCOE(_selectedCar)) {
      return true;
    }

    if (availableBalance < carManager.getUpfrontPaymentWithCOE(_selectedCar)) {
      return false;
    }

    return loanManager
        .canPlayerTakeLoan(activePlayer,
            newLoanRepaymentPerRound: _selectedCar.repaymentPerRound,
            reason: LoanReason.car)
        .isApproved;
  }

  void _handleBuyCar(BuildContext context, Car car) {
    if (accountsManager.getAvailableBalance(activePlayer) >=
        carManager.getCarPriceWithCOE(_selectedCar)) {
      context
          .showDialog(buildBuyCarWithoutDebtDialog(context, onTapConfirm: () {
        carManager.buyCar(activePlayer, car, takeLoan: false);
        context.dismissDialog();

        Future.delayed(Durations.medium1, () {
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          context.showDialog(buildPurchaseCarSuccessDialog(context, () {
            context.navigateAndPopTo(DashboardScreen());
          }));
        });
      }, onTapCancel: () {
        context.dismissDialog();

        Future.delayed(Durations.medium1, () {
          if (!mounted) return;
          // ignore: use_build_context_synchronously
          _handleBuyCarWithLoan(context, car);
        });
      }));
    } else {
      _handleBuyCarWithLoan(context, car);
    }
  }

  void _handleBuyCarWithLoan(BuildContext context, Car car) {
    context.showDialog(buildConfirmBuyCarDialog(context, car, () {
      carManager.buyCar(activePlayer, car);
      context.dismissDialog();

      Future.delayed(Durations.medium1, () {
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        context.showDialog(buildPurchaseCarSuccessDialog(context, () {
          context.navigateAndPopTo(DashboardScreen());
        }));
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      title: "Purchase Car",
      onTapBack: () => Navigator.of(context).pop(),
      landingDialog: hintsManager.shouldShowHint(activePlayer, Hint.buyCar)
          ? AlphaDialogBuilder.dismissable(
              title: "Welcome",
              dismissText: "Confirm",
              child: const CarSelectionLandingdialog())
          : null,
      next: AlphaButton.next(
          onTap: () => context.navigateAndPopTo(DashboardScreen())),
      children: <Widget>[
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCarListingsColumn(),
            _buildCarDetailsColumn(context),
          ],
        ),
      ],
    );
  }

  Widget _buildCarListingsColumn() {
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
            children: carManager
                .getAvailableCars(activePlayer)
                .asMap()
                .map((index, car) => MapEntry(
                    index,
                    GestureDetector(
                      onTap: () => setState(() => _selectedCar = car),
                      child: CarListing(car: car, selected: car == _selectedCar)
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

  Widget _buildCarDetailsColumn(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            PlayerAccountBalanceStatCard(
                accountsManager.getPlayerAccount(activePlayer)),
            const SizedBox(width: 10.0),
            PlayerDebtStatCard(loanManager.getPlayerDebt(activePlayer)),
          ],
        ),
        const SizedBox(height: 20.0),
        _buildCarDetails(),
        const SizedBox(height: 20.0),
        _buildPurchaseControls(context),
      ],
    );
  }

  Widget _buildCarDetails() {
    return AlphaContainer(
      width: 650.0,
      height: 250.0,
      padding: const EdgeInsets.all(25.0),
      child: Row(
        children: [
          SizedBox(
              width: 280.0,
              height: double.infinity,
              child:
                  Image.asset(_selectedCar.type.image.path, fit: BoxFit.cover)),
          const SizedBox(width: 25.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Car Name",
                    style: TextStyles.bold18.copyWith(color: Colors.black87),
                  ),
                  SizedBox(
                    width: 260.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxHeight: 35.0, maxWidth: 260.0),
                      child: AutoSizeText(
                        _selectedCar.name,
                        style: TextStyles.bold24,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  _GenericTitleValue(
                      width: 170.0,
                      title: "Price",
                      value: _selectedCar.price.prettyCurrency),
                  _GenericTitleValue(
                      width: 100.0,
                      title: "Happiness",
                      value: "${_selectedCar.happinessBonus} ❤️"),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  _GenericTitleValue(
                      width: 170.0,
                      title: "Depreciation Rate",
                      value: "${_selectedCar.depreciationRate * 100}% 🔻"),
                  _GenericTitleValue(
                      width: 100.0,
                      title: "ESG Bonus",
                      value: "${_selectedCar.esgBonus} 🌎"),
                ],
              )
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
                    value: _selectedCar.loanAmount.prettyCurrency),
                const SizedBox(height: 6.0),
                _GenericTitleValue(
                    width: 200.0,
                    title: "COE Price",
                    value: carManager.calculateCOEPrice().prettyCurrency),
              ]),
              Column(children: <Widget>[
                _GenericTitleValue(
                    width: 190.0,
                    title: "Payment Per Round",
                    value: _selectedCar.repaymentPerRound.prettyCurrency),
                const SizedBox(height: 6.0),
                _GenericTitleValue(
                    width: 190.0,
                    title: "Repayment Period",
                    value: "${_selectedCar.repaymentPeriod} rounds"),
              ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("Upfront Payment", style: TextStyles.bold16),
                    AnimatedValue(
                      carManager.getUpfrontPaymentWithCOE(_selectedCar),
                      currency: true,
                      style: TextStyles.bold30,
                    ),
                    const SizedBox(height: 6.0),
                    Builder(
                      builder: (context) => AlphaButton(
                        width: 205.0,
                        height: 60.0,
                        disabled: !_canAffordCar(context),
                        onTapDisabled: () => context.showSnackbar(
                            message:
                                "✋🏼 Insufficient funds for downpayment or ineligible for loan."),
                        title: "Buy",
                        icon: Icons.shopping_cart_outlined,
                        color: const Color(0xff96DE9D),
                        onTap: () => _handleBuyCar(context, _selectedCar),
                      ),
                    ),
                  ]),
            ],
          ),
          // AlphaButton(title: "Purchase", width: 260.0, onTap: () {}),
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
