import 'package:alpha/extensions.dart';
import 'package:alpha/logic/business_logic.dart';
import 'package:alpha/logic/data/board_tiles.dart';
import 'package:alpha/logic/data/business.dart';
import 'package:alpha/logic/hints_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/common/alpha_stat_card.dart';
import 'package:alpha/ui/common/animated_value.dart';
import 'package:alpha/ui/screens/business/dialogs/rnd_dialogs.dart';
import 'package:alpha/ui/screens/business/dialogs/confirm_sell_business.dialog.dart';
import 'package:alpha/ui/screens/business/dialogs/landing_dialog_owned.dart';
import 'package:alpha/ui/screens/business/widgets/owned_business_listing.dart';
import 'package:alpha/ui/screens/investments/widgets/esg_label.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_sector_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BusinessOwnedScreen extends StatefulWidget {
  const BusinessOwnedScreen({super.key});

  @override
  State<BusinessOwnedScreen> createState() => _BusinessOwnedScreenState();
}

class _BusinessOwnedScreenState extends State<BusinessOwnedScreen> {
  BusinessVenture venture = businessManager.getBusinessVenture(activePlayer);
  late Business _selectedBusiness = (venture.ownedBusinesses.isNotEmpty)
      ? venture.ownedBusinesses.first
      : Business(
          name: "",
          sector: BusinessSector.eCommerce,
          esgRating: 0,
          initialCost: 0,
        );

  bool _canPerformRnd() {
    if (_selectedBusiness.lastRndRound == gameManager.round) {
      return false;
    }

    return accountsManager.getAvailableBalance(activePlayer) >=
        businessManager.getRndCost(_selectedBusiness);
  }

  void _handleRndDisabled(BuildContext context) {
    if (_selectedBusiness.lastRndRound == gameManager.round) {
      context.showSnackbar(
          message: "✋🏼 Already attempted R&D this round for this business.");
      return;
    }

    context.showSnackbar(
        message: "✋🏼 Insufficient funds to perform R&D for this business.");
  }

  void _handleSellBusiness(BuildContext context) {
    context.showDialog(
        buildConfirmSellBusinessDialog(context, _selectedBusiness, () {
      businessManager.sellBusiness(activePlayer, _selectedBusiness);

      setState(() {
        if (venture.ownedBusinesses.isNotEmpty) {
          _selectedBusiness = venture.ownedBusinesses.first;
        }
      });

      context.dismissDialog();
      context.showSnackbar(message: "🎉 Successfully sold business.");
    }));
  }

  void _handleRndBusiness(BuildContext context) {
    context.showDialog(
        buildConfirmRndBusinessDialog(context, _selectedBusiness, () {
      /// To rebuild R&D button once attempted
      setState(() {});

      final bool isSuccessful =
          businessManager.attemptRnD(activePlayer, _selectedBusiness);

      context.dismissDialog();

      Future.delayed(Durations.medium1, () {
        if (isSuccessful) {
          context.showDialog(
              buildSuccessRndBusinessDialog(context, _selectedBusiness, () {
            context.dismissDialog();
          }));
        } else {
          context.showDialog(
              buildFailureRndBusinessDialog(context, _selectedBusiness, () {
            context.dismissDialog();
          }));
        }
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: venture,
      builder: (context, _) => AlphaScaffold(
        title: "Owned Businesses",
        onTapBack: () => Navigator.of(context).pop(),
        landingDialog:
            hintsManager.shouldShowHint(activePlayer, Hint.manageBusiness)
                ? AlphaDialogBuilder.dismissable(
                    title: "Manage businesses",
                    dismissText: "Start Managing",
                    width: 400.0,
                    child: const OwnedBusinessesLandingDialog())
                : null,
        children: venture.ownedBusinesses.isNotEmpty
            ? <Widget>[
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildOwnedBusinessesColumn(),
                    _buildBusinessDetailsColumn(context),
                  ],
                ),
              ]
            : [_buildNoBusinessColumn()],
      ),
    );
  }

  Widget _buildNoBusinessColumn() {
    return Column(
      children: [
        const SizedBox(height: 150.0),
        const Text(
            "You don't own any businesses yet. Start one by landing on one of these tiles.",
            style: TextStyles.bold22),
        const SizedBox(height: 30.0),
        Wrap(
          spacing: 20.0,
          children: [
            ...BoardTile.values
                .where((tile) =>
                    tile == BoardTile.businessSocialMediaTile ||
                    tile == BoardTile.businessEcommerceTile ||
                    tile == BoardTile.businessTechnologyTile ||
                    tile == BoardTile.businessFnBTile ||
                    tile == BoardTile.businessPharmaTile)
                .map(
                  (tile) => SizedBox(
                          width: 180.0, child: Image.asset(tile.image.path))
                      .animate()
                      .scale(
                          curve: Curves.elasticOut,
                          begin: const Offset(0.75, 0.75),
                          end: const Offset(1.0, 1.0),
                          delay: const Duration(milliseconds: 100),
                          duration: const Duration(milliseconds: 1150)),
                )
          ],
        )
      ],
    );
  }

  Widget _buildOwnedBusinessesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Owned Businesses",
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
            children: venture.ownedBusinesses
                .asMap()
                .map((index, business) => MapEntry(
                    index,
                    GestureDetector(
                      onTap: () => setState(() => _selectedBusiness = business),
                      child: OwnedBusinessListing(
                              business: business,
                              selected: business == _selectedBusiness)
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

  Widget _buildBusinessDetailsColumn(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: [
            PlayerAccountBalanceStatCard(
                accountsManager.getPlayerAccount(activePlayer)),
            const SizedBox(width: 10.0),
            PlayerDebtStatCard(loanManager.getPlayerDebt(activePlayer),
                businessDebtOnly: true),
          ],
        ),
        const SizedBox(height: 20.0),
        _buildBusinessDetails(),
        const SizedBox(height: 20.0),
        _buildActionControls(context),
      ],
    );
  }

  Widget _buildBusinessDetails() {
    return AlphaContainer(
      width: 600.0,
      height: 310.0,
      padding: const EdgeInsets.only(left: 30.0, top: 20.0, bottom: 20.0),
      child: Row(
        children: [
          SizedBox(
              width: 200.0,
              height: double.infinity,
              child: Image.asset(_selectedBusiness.sector.asset.path,
                  fit: BoxFit.cover)),
          const SizedBox(width: 30.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Business Name",
                    style: TextStyles.bold18.copyWith(color: Colors.black87),
                  ),
                  SizedBox(
                    width: 310.0,
                    height: 40.0,
                    child: AutoSizeText(_selectedBusiness.name,
                        maxLines: 1, style: TextStyles.bold25),
                  )
                ],
              ),
              Row(
                children: [
                  StockSectorCard(_selectedBusiness.sector),
                  const SizedBox(width: 10.0),
                  if (_selectedBusiness.esgRating > 0)
                    ESGLabel(_selectedBusiness.esgRating),
                ],
              ),
              const SizedBox(height: 15.0),
              _GenericTitleValue(
                  title: "Busines Valuation",
                  value: businessManager
                      .calculateBusinessValuation(_selectedBusiness)
                      .prettyCurrency),
              const SizedBox(height: 8.0),
              Builder(
                builder: (context) {
                  final double cashflow = _selectedBusiness.lastRevenue;

                  Color color;
                  if (cashflow > 0) {
                    color = const Color(0xFF45A148);
                  } else if (cashflow == 0.0) {
                    color = Colors.black;
                  } else {
                    color = Colors.red;
                  }

                  return _GenericTitleValue(
                      title: "Business Cashflow",
                      color: color,
                      value:
                          "${cashflow > 0 ? "+" : ""}${cashflow.prettyCurrency}");
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionControls(BuildContext context) {
    return AlphaContainer(
      width: 600.0,
      height: 200.0,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 10 - .0),
            child: Row(
              children: [
                SizedBox(
                  width: 275.0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text("R&D Price", style: TextStyles.bold19),
                        AnimatedValue(
                          businessManager.getRndCost(_selectedBusiness),
                          currency: true,
                          style: TextStyles.bold33,
                        ),
                        const SizedBox(height: 6.0),
                      ]),
                ),
                SizedBox(
                  width: 265.0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text("Sell Price", style: TextStyles.bold19),
                        AnimatedValue(
                          businessManager
                              .calculateBusinessValuation(_selectedBusiness),
                          currency: true,
                          style: TextStyles.bold33,
                        ),
                        const SizedBox(height: 6.0),
                      ]),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) => Row(
              children: [
                AlphaButton(
                  width: 265.0,
                  height: 60.0,
                  disabled: !_canPerformRnd(),
                  onTapDisabled: () => _handleRndDisabled(context),
                  title: "R&D",
                  icon: Icons.science_outlined,
                  color: const Color(0xFF8CB6FD),
                  onTap: () => _handleRndBusiness(context),
                ),
                const SizedBox(width: 15.0),
                AlphaButton(
                  width: 260.0,
                  height: 60.0,
                  title: "Sell",
                  icon: Icons.shopping_cart_outlined,
                  color: AlphaColors.red,
                  onTap: () => _handleSellBusiness(context),
                )
              ],
            ),
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
  final Color? color;

  const _GenericTitleValue({
    required this.title,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyles.bold17.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 2.0),
        SizedBox(
          width: 260.0,
          child: Text(
            value,
            style: TextStyles.bold27.copyWith(color: color ?? Colors.black),
          ),
        )
      ],
    );
  }
}
