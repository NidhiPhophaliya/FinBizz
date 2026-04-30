# 🏆 Scoring Formula

The game employs a comprehensive scoring system that balances multiple financial and life success factors.

## Final Score Calculation

```
Final Score = (Total Assets × Happiness Factor) - Debt Penalty + Life Goal Bonus + ESG Team Bonus
```

## Scoring Components

**Total Assets** = Accounts + Portfolio + Business Valuation + Real Estate + Vehicles
```dart
totalAssets = savingsBalance + cpfBalance + investmentBalance + 
              portfolioValue + businessValuation + realEstateValue + vehicleValue
```

**Happiness Factor** = `max(1, happiness - 100 + 1)`
- Base happiness: 100
- Each happiness point above 100 adds to multiplier
- Minimum multiplier: 1 (no penalty below base happiness)

**Debt Penalty** (Applied to final score):
- **0-10% DAR**: No penalty (×1.00)
- **11-25% DAR**: 5% penalty (×0.95)
- **26-50% DAR**: 15% penalty (×0.85)
- **51-75% DAR**: 25% penalty (×0.75)
- **76-90% DAR**: 50% penalty (×0.50)
- **90%+ DAR**: 80% penalty (×0.20)

**Life Goal Bonus**: 20% bonus (×1.20) if achieved
- **Wealth Goal**: ≥$300k total assets
- **Career Goal**: Skill Level 12
- **Family Goal**: Achieve Family life stage

**ESG Team Bonus**: 10% bonus (×1.10) if team average ESG > 80 per player

## Winning Strategy

**Balanced Approach**:
1. **Asset Accumulation**: Focus on appreciating investments
2. **Happiness Maintenance**: Balance wealth with life satisfaction  
3. **Debt Management**: Keep debt-to-asset ratio below 10%
4. **Life Goal Achievement**: Target specific goal for 20% bonus
5. **ESG Contribution**: Contribute to team ESG for 10% bonus

**Optimal Score Formula Example**:
```
Example: $400k assets × 1.5 happiness × 1.0 debt × 1.2 life goal × 1.1 ESG
Final Score = 400,000 × 1.5 × 1.2 × 1.1 = 792,000 points
```

---

*Part of the [IIC Cashflow Game 2025](../../README.md) documentation*