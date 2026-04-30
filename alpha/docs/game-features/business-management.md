# 🏪 Business Management

The business management system allows players to create and manage businesses across 5 sectors, with realistic competition dynamics and growth mechanics.

## Business Sectors

| Sector | Base Revenue | Initial Cost Factor | ESG Potential |
|--------|--------------|---------------------|---------------|
| **Social Media** | $5,000 | 1.6× | 0-10 |
| **F&B** | $8,000 | 1.6× | 0-35 |
| **E-commerce** | $10,000 | 1.6× | 0-5 |
| **Technology** | $13,000 | 1.6× | 15-30 |
| **Pharmaceutical** | $18,000 | 1.6× | 10-25 |

## Business Economics

**Initial Cost Calculation**:
```
Cost = Base Revenue × 1.6 × (1 + Pioneer Penalty + ESG Bonus + Economic Factors + Random Factor)
```

**Cost Modifiers**:
- **Pioneer Penalty**: +10% for first business in sector
- **Saturation Discount**: -10% when 3+ businesses exist
- **Depression Discount**: -15% during economic depression
- **ESG Bonus**: Up to +30% for high sustainability ratings
- **Random Factor**: ±10% variation

## Revenue & Growth Dynamics

**Revenue Calculation**:
```
Revenue = Base Revenue × Growth Multiplier × (1 + ESG Bonus + World Event + Economic Cycle + Random)
```

**Competition Effects (Growth Multiplier)**:
- **Monopoly** (1 business): 25% growth per round
- **Oligopoly** (2-3 businesses): 15% growth per round  
- **Perfect Competition** (4+ businesses): 0% growth per round
- **Market Saturation** (no growth opportunities): 2% growth per round

**Growth Opportunities**: Each business has 4 growth opportunities before reaching market maturity

## Research & Development (R&D)

**R&D Mechanics**:
- **Cost**: 55% of current revenue
- **Success Rate**: 60%
- **Growth Benefit**: 30% permanent revenue increase
- **Limitation**: Once per round per business
- **Failure**: Investment lost, no revenue growth

**R&D Decision Matrix**:
```
Expected Value = (Success Rate × Growth Benefit) - Cost
Expected Value = (0.6 × 0.3 × Revenue) - (0.55 × Revenue)
Expected Value = -0.37 × Revenue (slightly negative)
```

*Strategic Note: R&D becomes profitable when considering long-term compounding effects*

## Business Valuation

**Valuation Formula**:
```
Valuation = Revenue × 1.25 × (1 + ESG Bonus + World Event + Economic Cycle - Competitor Penalty)
```

**Valuation Factors**:
- **ESG Bonus**: Up to +30% for sustainable practices
- **Competitor Penalty**: -5% per competitor in sector
- **Revenue Multiplier**: 1.25× base adjustment for future earnings potential

## Business Financing

**Business Loans**:
- **No upfront requirements**: Unlike asset loans
- **Profit-First Repayment**: Business profits automatically repay debt
- **Loss Accumulation**: Business losses add to debt principal
- **No Interest**: Business loans don't accrue interest

---

*Part of the [IIC Cashflow Game 2025](../../README.md) documentation*