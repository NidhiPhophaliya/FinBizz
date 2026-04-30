import 'package:alpha/assets.dart';
import 'package:alpha/logic/opportunity_logic.dart';

final class Opportunities {
  static final List<Opportunity> opportunityList = [
    Opportunity(
        title: "Lawsuit",
        description: "You've been sued!",
        image: AlphaAsset.opportunityLawsuit,
        happinessBonus: -5,
        cashBonus: 0,
        cashPenaltyPercentage: -8.0),
    Opportunity(
        title: "Audited",
        description: "You've been audited!",
        image: AlphaAsset.opportunityAudited,
        happinessBonus: -5,
        cashBonus: 0,
        cashPenaltyPercentage: -4.0),
    Opportunity(
        title: "Angel Investor",
        description: "You've met an angel investor!",
        image: AlphaAsset.opportunityAngelInvestor,
        happinessBonus: 5,
        cashBonus: 10000,
        cashPenaltyPercentage: 0.0),
    Opportunity(
        title: "Charity",
        description: "You've donated to charity!",
        image: AlphaAsset.opportunityCharity,
        happinessBonus: 15,
        cashBonus: 0,
        cashPenaltyPercentage: -5.0),
    Opportunity(
        title: "Lottery",
        description: "You've won the lottery",
        image: AlphaAsset.opportunityLottery,
        happinessBonus: 10,
        cashBonus: 5000,
        cashPenaltyPercentage: 0.0),
  ];
}
