import 'package:alpha/extensions.dart';
import 'package:alpha/logic/car_logic.dart';
import 'package:alpha/logic/data/board_tiles.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/common/animated_value.dart';
import 'package:alpha/ui/screens/assets/dialogs/confirm_sell_car_dialog.dart';
import 'package:alpha/ui/screens/assets/widgets/owned_car_listing.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OwnedCarsScreen extends StatefulWidget {
  const OwnedCarsScreen({super.key});

  @override
  State<OwnedCarsScreen> createState() => _OwnedCarsScreenState();
}

class _OwnedCarsScreenState extends State<OwnedCarsScreen> {
  final List<Car> _ownedCars = carManager.getOwnedCars(activePlayer);
  late Car _selectedCar = _ownedCars.isNotEmpty
      ? _ownedCars.first
      : Car(
          name: "",
          price: 0,
          type: CarType.petrol,
          happinessBonus: 0,
          esgBonus: 0);

  void _handleSellCar(BuildContext context) {
    context.showDialog(
        buildConfirmSellCarDialog(context, activePlayer, _selectedCar, () {
      carManager.sellCar(activePlayer, _selectedCar);
      setState(() {
        _ownedCars.remove(_selectedCar);

        if (_ownedCars.isNotEmpty) {
          _selectedCar = _ownedCars.first;
        }
      });

      context.dismissDialog();
      context.showSnackbar(message: "🎉 Car sold successfully.");
    }));
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      title: "Owned Cars",
      onTapBack: () => Navigator.of(context).pop(),
      children: _ownedCars.isNotEmpty
          ? <Widget>[
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildCarListingsColumn(),
                  _buildCarDetailsColumn(context),
                ],
              ),
            ]
          : [_buildNoCarsColumn()],
    );
  }

  Widget _buildCarListingsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Owned Cars",
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
            children: _ownedCars
                .asMap()
                .map((index, car) => MapEntry(
                    index,
                    GestureDetector(
                      onTap: () => setState(() => _selectedCar = car),
                      child: OwnedCarListing(
                              car: car, selected: car == _selectedCar)
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

  Widget _buildNoCarsColumn() {
    return Column(
      children: [
        const SizedBox(height: 150.0),
        const Text(
            "You don't own any cars. Buy one by landing on one of this tile.",
            style: TextStyles.bold22),
        const SizedBox(height: 30.0),
        SizedBox(width: 180.0, child: Image.asset(BoardTile.carTile.image.path))
            .animate()
            .scale(
                curve: Curves.elasticOut,
                begin: const Offset(0.75, 0.75),
                end: const Offset(1.0, 1.0),
                delay: const Duration(milliseconds: 100),
                duration: const Duration(milliseconds: 1150)),
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
      height: 310.0,
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
                        style: TextStyles.bold25,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8.0),
              _GenericTitleValue(
                  title: "Current Value",
                  value: carManager
                      .getCurrentCarValue(activePlayer, _selectedCar)
                      .prettyCurrency),
              const SizedBox(height: 8.0),
              _GenericTitleValue(
                  title: "Value Depreciated",
                  value: (_selectedCar.price -
                          carManager.getCurrentCarValue(
                              activePlayer, _selectedCar))
                      .prettyCurrency),
              const SizedBox(height: 6.0),
              _GenericTitleValue(
                  title: "Depreciation Rate (per round)",
                  value: "${(_selectedCar.depreciationRate * 100)}%"),
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
                    title: "Curent COE Price",
                    value: carManager.calculateCOEPrice().prettyCurrency),
              ]),
              Column(children: <Widget>[
                _GenericTitleValue(
                    width: 190.0,
                    title: "Loan Remaining",
                    value: loanManager
                        .getRemainingLoanAmount(activePlayer,
                            reason: LoanReason.car)
                        .prettyCurrency),
                const SizedBox(height: 8.0),
                _GenericTitleValue(
                    width: 190.0,
                    title: "Rounds Owned",
                    value: carManager
                        .getRoundsOwned(activePlayer, _selectedCar)
                        .toString()),
              ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("Sale Price", style: TextStyles.bold16),
                    AnimatedValue(
                      carManager.getCarSalePrice(activePlayer, _selectedCar),
                      currency: true,
                      style: TextStyles.bold30,
                    ),
                    const SizedBox(height: 6.0),
                    Builder(
                      builder: (context) => AlphaButton(
                        width: 205.0,
                        height: 60.0,
                        disabled: false,
                        title: "Sell",
                        icon: Icons.shopping_cart_outlined,
                        color: AlphaColors.red,
                        onTap: () => _handleSellCar(context),
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
