import 'package:alpha/assets.dart';
import 'package:alpha/extensions.dart';
import 'package:alpha/logic/data/board_tiles.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/real_estate_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/common/animated_value.dart';
import 'package:alpha/ui/screens/assets/dialogs/confirm_sell_real_estate_dialog.dart';
import 'package:alpha/ui/screens/assets/widgets/owned_real_estate_listing.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OwnedRealEstateScreen extends StatefulWidget {
  const OwnedRealEstateScreen({super.key});

  @override
  State<OwnedRealEstateScreen> createState() => _OwnedRealEstateScreenState();
}

class _OwnedRealEstateScreenState extends State<OwnedRealEstateScreen> {
  final List<RealEstate> _ownedRealEstates =
      realEstateManager.getOwnedRealEstates(activePlayer);

  late RealEstate _selectedRealEstate = _ownedRealEstates.isNotEmpty
      ? _ownedRealEstates.first
      : RealEstate(
          name: "",
          type: RealEstateType.condo,
          image: AlphaAsset.realEstateBungalow,
          propertyValue: 0);

  void _handleSellRealEstate(BuildContext context) {
    context.showDialog(
        buildConfirmSellRealEstateDialog(context, _selectedRealEstate, () {
      realEstateManager.sellRealEstate(activePlayer, _selectedRealEstate);
      setState(() {
        _ownedRealEstates.remove(_selectedRealEstate);

        if (_ownedRealEstates.isNotEmpty) {
          _selectedRealEstate = _ownedRealEstates.first;
        }
      });

      context.dismissDialog();
      context.showSnackbar(
          message: "🎉 Congratulations! You sold your property.");
    }));
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      title: "Real Estate",
      onTapBack: () => Navigator.of(context).pop(),
      children: _ownedRealEstates.isNotEmpty
          ? <Widget>[
              const SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildRealEstateListingsColumn(),
                  _buildRealEstateDetailsColumn(context),
                ],
              ),
            ]
          : [_buildNoRealEstateColumn()],
    );
  }

  Widget _buildNoRealEstateColumn() {
    return Column(
      children: [
        const SizedBox(height: 150.0),
        const Text(
            "You don't own any real estate. Buy one by landing on one of this tile.",
            style: TextStyles.bold22),
        const SizedBox(height: 30.0),
        SizedBox(
                width: 180.0,
                child: Image.asset(BoardTile.realEstatesTile.image.path))
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

  Widget _buildRealEstateListingsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Owned Properties",
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
                .getOwnedRealEstates(activePlayer)
                .asMap()
                .map((index, realEstate) => MapEntry(
                    index,
                    GestureDetector(
                      onTap: () =>
                          setState(() => _selectedRealEstate = realEstate),
                      child: OwnedRealEstateListing(
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
        const SizedBox(height: 20.0),
        _buildRealEstateDetails(),
        const SizedBox(height: 20.0),
        _buildPurchaseControls(context),
      ],
    );
  }

  Widget _buildRealEstateDetails() {
    return AlphaContainer(
      width: 650.0,
      height: 310.0,
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
              _GenericTitleValue(
                  title: "Current Value",
                  value: realEstateManager
                      .getCurrentPropertyValue(
                          activePlayer, _selectedRealEstate)
                      .prettyCurrency),
              const SizedBox(height: 8.0),
              _GenericTitleValue(
                  title: "Growth Rate (per round)",
                  value:
                      "${((_selectedRealEstate.growthRate - 1.0) * 100).toStringAsFixed(1)}%"),
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
                    title: "Mortgage Remaining",
                    value: loanManager
                        .getRemainingLoanAmount(activePlayer,
                            reason: LoanReason.mortgage)
                        .prettyCurrency),
                const SizedBox(height: 6.0),
                _GenericTitleValue(
                    width: 190.0,
                    title: "Owned Rounds",
                    value: realEstateManager
                        .getOwnedRounds(activePlayer, _selectedRealEstate)
                        .toString()),
              ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text("Sale Price", style: TextStyles.bold16),
                    AnimatedValue(
                      realEstateManager.getCurrentPropertyValue(
                          activePlayer, _selectedRealEstate),
                      currency: true,
                      style: TextStyles.bold30,
                    ),
                    const SizedBox(height: 6.0),
                    Builder(
                      builder: (context) => AlphaButton(
                        width: 205.0,
                        height: 60.0,
                        title: "Sell",
                        icon: Icons.shopping_cart_outlined,
                        color: AlphaColors.red,
                        onTap: () => _handleSellRealEstate(context),
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
