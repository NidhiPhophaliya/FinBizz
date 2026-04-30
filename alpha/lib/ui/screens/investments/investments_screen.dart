import 'package:alpha/extensions.dart';
import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/logic/financial_market_logic.dart';
import 'package:alpha/logic/hints_logic.dart';
import 'package:alpha/services.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_alert_dialog.dart';
import 'package:alpha/ui/common/alpha_animations.dart';
import 'package:alpha/ui/common/alpha_button.dart';
import 'package:alpha/ui/common/alpha_container.dart';
import 'package:alpha/ui/common/alpha_scaffold.dart';
import 'package:alpha/ui/screens/investments/dialogs/confirm_buy_stock_dialog.dart';
import 'package:alpha/ui/screens/investments/dialogs/investments_landing_dialog.dart';
import 'package:alpha/ui/screens/investments/dialogs/stock_units_input_dialog.dart';
import 'package:alpha/ui/screens/investments/widgets/esg_label.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_listing.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_graph.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_price_change.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_risk_label.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_sector_card.dart';
import 'package:alpha/ui/screens/investments/widgets/stock_unit_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key});

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  Stock _selectedStock = marketManager.stocks.first;

  final StockUnitController _controller = StockUnitController();

  final InvestmentAccount investments =
      accountsManager.getInvestmentAccount(activePlayer);

  void _handleAdjustUnits(BuildContext context) {
    context.showDialog(buildStockUnitsInputDialog(context, _controller, () {
      context.dismissDialog();
    }));
  }

  void _handleBuyShare(BuildContext context) {
    if (_controller.units <= 0) {
      context.showSnackbar(
          message: "✋🏼 Please select a valid number of units");
      return;
    }

    final double totalValue = _selectedStock.price * _controller.units;

    if (investments.balance < totalValue) {
      context.showSnackbar(
          message: "✋🏼 Insufficient funds to purchase this share");
      return;
    }

    context.showDialog(buildConfirmBuyStockDialog(
        context, _selectedStock, _controller.units, () {
      accountsManager.purchaseShare(
          activePlayer, _selectedStock, _controller.units);
      context.dismissDialog();
    }));
  }

  void _handleSellShare(BuildContext context) {
    if (_controller.units <= 0) {
      context.showSnackbar(
          message: "✋🏼 Please select a valid number of units");
      return;
    }

    final int units = investments.getStockUnits(_selectedStock.item);

    if (units < _controller.units) {
      context.showSnackbar(message: "✋🏼 Insufficient shares to sell");
      return;
    }

    final AlphaDialogBuilder dialog = _buildConfirmSellDialog(context, () {
      accountsManager.sellShare(
          activePlayer, _selectedStock, _controller.units);
      context.dismissDialog();
    });

    context.showDialog(dialog);
  }

  @override
  Widget build(BuildContext context) {
    return AlphaScaffold(
      title: "Investments",
      landingDialog:
          (hintsManager.shouldShowHint(activePlayer, Hint.investment))
              ? AlphaDialogBuilder.dismissable(
                  title: "Welcome",
                  dismissText: "Start Investing",
                  width: 350.0,
                  child: const InvestmentsLandingDialog())
              : null,
      onTapBack: () => Navigator.of(context).pop(),
      children: <Widget>[
        const SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildStockMarketColumn(),
            _buildInvestmentDetailsColumn(context),
          ],
        ),
      ],
    );
  }

  Widget _buildStockMarketColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Stock Market",
            style: TextStyles.bold22,
          ),
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          height: 640.0,
          width: 358.0,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: marketManager.stocks
                  .map((stock) => Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedStock = stock),
                          child: StockListing(
                            stock: stock,
                            selected: _selectedStock == stock,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentDetailsColumn(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _buildStockDetailsContainer(),
            const SizedBox(width: 10.0),
            _buildInvestmentAccountContainer(),
          ],
        ),
        const SizedBox(height: 25.0),
        _buildTransactionControls(context),
      ],
    );
  }

  Widget _buildStockDetailsContainer() {
    return AlphaContainer(
      width: 370.0,
      height: 450.0,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 190.0),
                child: AutoSizeText(
                  _selectedStock.name,
                  maxLines: 1,
                  style: TextStyles.bold22,
                ),
              ),
              const SizedBox(width: 10.0),
              Transform.translate(
                offset: const Offset(0, -0.2),
                child: StockPriceChangeIndicator(
                  change: _selectedStock.percentPriceChange(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              StockRiskLabel(risk: _selectedStock.risk),
              const SizedBox(width: 5.0),
              if (_selectedStock.esgRating > 0)
                ESGLabel(_selectedStock.esgRating),
              StockSectorCard(_selectedStock.item.sector),
            ],
          ),
          const SizedBox(height: 15.0),
          Row(
            children: <Widget>[
              _GenericTitleValue(
                title: "Share Price",
                value: _selectedStock.price.prettyCurrency,
                width: 120.0,
              ),
              ListenableBuilder(
                listenable: investments,
                builder: (context, _) => _GenericTitleValue(
                  title: "Shares Owned",
                  value: (() {
                    final owned =
                        investments.getStockUnits(_selectedStock.item);

                    return "${(owned * _selectedStock.price).prettyCurrency} ($owned)";
                  })(),
                  width: 200.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 45.0),
          Center(
            child: LargeStockGraph(
              width: 310.0,
              height: 200.0,
              stock: _selectedStock,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentAccountContainer() {
    return AlphaContainer(
      width: 290.0,
      height: 450.0,
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "Investment Account",
            style: TextStyles.bold20,
          ),
          ListenableBuilder(
            listenable: investments,
            builder: (context, child) => AnimatedNumber(
              investments.balance,
              style: TextStyles.bold30,
              formatCurrency: true,
            ),
          ),
          const SizedBox(height: 10.0),
          const Text(
            "Portfolio Value",
            style: TextStyles.bold20,
          ),
          const SizedBox(height: 2.0),
          ListenableBuilder(
              listenable: investments,
              builder: (builder, _) => AnimatedNumber(
                    investments.getPortfolioValue(),
                    style: TextStyles.bold30,
                    formatCurrency: true,
                  )),
          Builder(
            builder: (context) {
              final double profitChange = investments.getPortfolioProfit();
              final double percentChange =
                  investments.getPortfolioValueChangePercent();

              Widget icon;
              Color color;

              if (profitChange > 0) {
                icon = const Icon(
                  Icons.arrow_upward_rounded,
                  color: Color(0xff3AB59E),
                  size: 24.0,
                );

                color = const Color(0xff3AB59E);
              } else if (profitChange < 0) {
                icon = const Icon(
                  Icons.arrow_downward_rounded,
                  color: Color(0xffE15353),
                  size: 24.0,
                );

                color = const Color(0xffE15353);
              } else {
                icon = Container(
                  width: 8.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                      color: const Color(0xFF626262),
                      borderRadius: BorderRadius.circular(30.0)),
                );

                color = const Color(0xFF626262);
              }

              return Row(
                children: <Widget>[
                  Transform.translate(
                    offset: const Offset(0.0, -2.5),
                    child: icon,
                  ),
                  const SizedBox(width: 2.0),
                  Text(
                    profitChange.prettyCurrency,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Transform.translate(
                    offset: const Offset(0.0, -1.6),
                    child: Text(
                      "($percentChange%)",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10.0),
          Expanded(
              child: ListenableBuilder(
                  listenable: investments,
                  builder: (context, _) => _PortfolioTable(investments))),
        ],
      ),
    );
  }

  Widget _buildTransactionControls(BuildContext context) {
    return AlphaContainer(
      width: 665.0,
      height: 200.0,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 15.0),
              const Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Text(
                  "Units",
                  style: TextStyles.bold20,
                ),
              ),
              const SizedBox(height: 5.0),
              Builder(
                builder: (context) => StockUnitSelector(
                    controller: _controller,
                    onTapEdit: () => _handleAdjustUnits(context)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                "Total Value",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) => AnimatedNumber(
                    _selectedStock.price * _controller.units,
                    formatCurrency: true,
                    style: TextStyles.bold40,
                  ),
                ),
              ),
              const SizedBox(height: 2.0),
              Builder(
                builder: (context) => Row(
                  children: <Widget>[
                    AlphaButton(
                      width: 165.0,
                      height: 60.0,
                      title: "Buy",
                      icon: Icons.shopping_cart_outlined,
                      color: const Color(0xff96DE9D),
                      onTap: () => _handleBuyShare(context),
                    ),
                    const SizedBox(width: 20.0),
                    AlphaButton(
                      width: 165.0,
                      height: 60.0,
                      title: "Sell",
                      icon: Icons.close,
                      color: const Color(0xffFF6B6B),
                      onTap: () => _handleSellShare(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AlphaDialogBuilder _buildConfirmSellDialog(
      BuildContext context, void Function() onTapConfirm) {
    return AlphaDialogBuilder(
      title: "Confirm Sell",
      child: Column(
        children: <Widget>[
          const Text(
            "Are you sure you want to sell?",
            style: TextStyles.bold24,
          ),
          const SizedBox(height: 10.0),
          Text(
            "${_controller.units.toString()} units of ${_selectedStock.name} stock for",
            style: TextStyles.bold22,
          ),
          const SizedBox(height: 10.0),
          Text(
            (_controller.units * _selectedStock.price).prettyCurrency,
            style: const TextStyle(
              color: Color.fromARGB(255, 59, 182, 43),
              fontSize: 48.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
      cancel: DialogButtonData.cancel(context),
      next: DialogButtonData.confirm(onTap: onTapConfirm),
    );
  }
}

class _GenericTitleValue extends StatelessWidget {
  final String title;
  final String value;
  final double width;

  const _GenericTitleValue(
      {required this.title, required this.value, this.width = 120.0});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyles.bold16,
        ),
        SizedBox(
          width: width,
          child: Text(
            value,
            style: TextStyles.bold22,
          ),
        )
      ],
    );
  }
}

// A table that displays the player's portfolio, listing each stock on the market,
//and the number of shares owned, with the total value.
class _PortfolioTable extends StatelessWidget {
  final InvestmentAccount investments;

  const _PortfolioTable(this.investments);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(color: Colors.black, width: 2.0),
        columnWidths: const {
          0: FixedColumnWidth(48.0),
          1: FixedColumnWidth(81.0),
          2: FixedColumnWidth(48.0),
          3: FixedColumnWidth(69.0),
        },
        children: <TableRow>[
          _buildTableHeader(),
          ...marketManager.stocks.map((stock) {
            final int units = investments.getStockUnits(stock.item);

            final double totalValue = stock.price * units;

            return _buildTableRow(
                stock.code,
                totalValue.prettyCurrency,
                units.toString(),
                investments.getStockProfitPercent(stock.item,
                    endNth: gameManager.round - 1));
          })
        ],
      ),
    );
  }
}

TableRow _buildTableHeader() {
  return const TableRow(
      decoration: BoxDecoration(color: Color(0xffE0E0E0)),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 3.0),
          child: Text(
            "Code",
            textAlign: TextAlign.center,
            style: TextStyles.bold13,
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 3.0, left: 5.0, right: 5.0),
            child: Text(
              "Total Value",
              style: TextStyles.bold12,
            )),
        Padding(
            padding: EdgeInsets.only(top: 3.0, left: 5.0, right: 5.0),
            child: Text(
              "Units",
              style: TextStyles.bold13,
            )),
        Padding(
            padding: EdgeInsets.only(top: 3.0, left: 5.0, right: 5.0),
            child: Text(
              "Change",
              style: TextStyles.bold13,
            ))
      ]);
}

TableRow _buildTableRow(
    String code, String value, String units, double percentChange) {
  return TableRow(children: <Widget>[
    Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Text(
        code,
        textAlign: TextAlign.center,
        style: TextStyles.bold15,
      ),
    ),
    Padding(
        padding:
            const EdgeInsets.only(top: 3.0, bottom: 2.0, left: 5.0, right: 5.0),
        child: AutoSizeText(value, maxLines: 1, style: TextStyles.medium15)),
    Padding(
        padding:
            const EdgeInsets.only(top: 3.0, bottom: 2.0, left: 5.0, right: 5.0),
        child: AutoSizeText(units, maxLines: 1, style: TextStyles.medium15)),
    Padding(
        padding:
            const EdgeInsets.only(top: 3.0, bottom: 2.0, left: 5.0, right: 5.0),
        child: Text(
          "$percentChange%",
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
              color: percentChange == 0
                  ? const Color(0xFF5B5B5B)
                  : (percentChange < 0
                      ? const Color(0xffE15353)
                      : const Color(0xff3AB59E))),
        ))
  ]);
}
