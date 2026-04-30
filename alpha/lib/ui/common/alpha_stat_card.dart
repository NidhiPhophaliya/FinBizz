import 'package:alpha/logic/accounts_logic.dart';
import 'package:alpha/logic/data/careers.dart';
import 'package:alpha/logic/loan_logic.dart';
import 'package:alpha/logic/stats_logic.dart';
import 'package:alpha/styles.dart';
import 'package:alpha/ui/common/alpha_animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AlphaStatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final num value;
  final Color? color;
  final double width;
  final bool isCurrency;

  const AlphaStatCard(
      {super.key,
      required this.emoji,
      required this.title,
      this.color,
      required this.value,
      this.width = 135.0,
      this.isCurrency = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
          border: Border.all(color: Colors.black, width: 3.0),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5))
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(emoji, style: TextStyles.black18),
          const SizedBox(width: 5.0),
          Text(title, style: TextStyles.bold16),
          const SizedBox(width: 6.0),
          Expanded(
              child: Transform.translate(
                  offset: const Offset(0.0, 1.7),
                  child: value is double
                      ? AnimatedNumber<double>(
                          value.toDouble(),
                          formatCurrency: isCurrency,
                          duration: Durations.long1,
                          delay: Durations.medium2,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color ?? const Color(0xff00734A),
                              fontSize: 18.0),
                          textAlign: TextAlign.right,
                        )
                      : AnimatedNumber(
                          value.toInt(),
                          formatCurrency: isCurrency,
                          duration: Durations.long1,
                          delay: Durations.medium2,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color ?? const Color(0xff00734A),
                              fontSize: 18.0),
                          textAlign: TextAlign.right,
                        ))),
          const SizedBox(width: 4.0),
        ],
      ),
    );
  }
}

class AlphaStatusCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final Color? color;
  final double width;

  const AlphaStatusCard(
      {super.key,
      required this.emoji,
      required this.title,
      required this.value,
      this.color,
      this.width = 135.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
          border: Border.all(color: Colors.black, width: 3.0),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5))
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Transform.translate(
              offset: const Offset(0.0, -3.5),
              child: Text(emoji, style: TextStyles.black18)),
          const SizedBox(width: 5.0),
          Text(title, style: TextStyles.bold16),
          const SizedBox(width: 6.0),
          Expanded(
              child: AutoSizeText(value,
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  style: TextStyles.bold16
                      .copyWith(color: color ?? Colors.black))),
          const SizedBox(width: 4.0),
        ],
      ),
    );
  }
}

class PlayerAccountBalanceStatCard extends StatelessWidget {
  final PlayerAccount accounts;

  const PlayerAccountBalanceStatCard(this.accounts, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: accounts,
      builder: (context, _) => AlphaStatCard(
        width: 270.0,
        emoji: "💵",
        title: "Balance",
        value: accounts.availableBalance,
        isCurrency: true,
      ),
    );
  }
}

class PlayerSavingsStatCard extends StatelessWidget {
  final PlayerAccount accounts;

  const PlayerSavingsStatCard(this.accounts, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: accounts,
      builder: (context, _) => AlphaStatCard(
        width: 270.0,
        emoji: "💵",
        title: "Savings",
        value: accounts.savings.balance,
        isCurrency: true,
      ),
    );
  }
}

class PlayerInvestmentsStatCard extends StatelessWidget {
  final PlayerAccount accounts;

  const PlayerInvestmentsStatCard(this.accounts, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: accounts,
      builder: (context, _) => AlphaStatCard(
        width: 290.0,
        emoji: "💰",
        title: "Investments",
        value: accounts.investments.balance,
        isCurrency: true,
      ),
    );
  }
}

class PlayerDebtStatCard extends StatelessWidget {
  final PlayerDebt debt;
  final bool businessDebtOnly;

  const PlayerDebtStatCard(this.debt,
      {super.key, this.businessDebtOnly = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: debt,
      builder: (context, _) => AlphaStatCard(
        width: businessDebtOnly ? 310.0 : 240.0,
        emoji: "💵",
        title: businessDebtOnly ? "Business Debt" : "Debt",
        color: const Color(0xFFB52F26),
        value: businessDebtOnly ? debt.businessDebt : debt.totalDebt,
        isCurrency: true,
      ),
    );
  }
}

class PlayerHappinessStatCard extends StatelessWidget {
  final PlayerStats stats;

  const PlayerHappinessStatCard(this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stats,
      builder: (context, child) => AlphaStatCard(
        width: 190.0,
        emoji: "❤️",
        title: "Happiness",
        value: stats.happiness,
      ),
    );
  }
}

class PlayerESGStatCard extends StatelessWidget {
  final PlayerStats stats;

  const PlayerESGStatCard(this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stats,
      builder: (context, child) => AlphaStatCard(
        width: 140.0,
        emoji: "🌏",
        title: "ESG",
        value: stats.esg,
      ),
    );
  }
}

class PlayerCareerStatCard extends StatelessWidget {
  final Job job;

  static const String emoji = "💼";

  const PlayerCareerStatCard(this.job, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 440.0,
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
          border: Border.all(color: Colors.black, width: 3.0),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5))
          ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Transform.translate(
              offset: const Offset(0.0, -3.5),
              child: const Text(emoji, style: TextStyles.black18)),
          const SizedBox(width: 5.0),
          const Text("Career", style: TextStyles.bold16),
          const SizedBox(width: 6.0),
          Expanded(
              child: AutoSizeText.rich(
                  textAlign: TextAlign.end,
                  TextSpan(children: <TextSpan>[
                    TextSpan(text: job.title, style: TextStyles.bold16),
                    TextSpan(
                        text: " (\$${job.salary.toInt()} per round)",
                        style: TextStyles.bold16.copyWith(
                            color: const Color.fromARGB(255, 42, 99, 44))),
                  ]))),
          const SizedBox(width: 4.0),
        ],
      ),
    );
  }
}
