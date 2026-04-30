# 🔄 Economic Cycles

The game simulates realistic economic fluctuations through a 4-phase economic cycle that affects all financial systems.

## Economic Phases

| Phase | Description | Duration | Market Effect | Business Impact |
|-------|-------------|----------|---------------|-----------------|
| **Recession** | Economic downturn | Variable | Neutral sentiment | -10% earnings |
| **Depression** | Severe contraction | Variable | -50% sentiment | -20% earnings |
| **Recovery** | Economic improvement | Variable | +50% sentiment | No change |
| **Boom** | Economic prosperity | Variable | +100% sentiment | +25% earnings |

## Economic Cycle Effects

**Stock Market Impact**:
```dart
// Market sentiment multiplier applied to all stocks
depression: -0.5    // Severe bear market
recession: 0.0      // Neutral market  
recovery: +0.5      // Moderate bull market
boom: +1.0          // Strong bull market
```

**Business Revenue Multipliers**:
```dart
// Applied to all business earnings calculations
depression: -0.20   // Severe business contraction
recession: -0.10    // Mild business decline
recovery: 0.00      // Neutral business conditions  
boom: +0.25         // Strong business growth
```

**Asset Pricing**:
- **Real Estate**: Prices affected by economic cycle multipliers
- **Vehicles**: Depression provides discount opportunities
- **Business Costs**: Depression offers 15% business acquisition discounts

## Economic Strategy

**Recession/Depression Strategy**:
- **Defensive Positioning**: Focus on stable investments and cash reserves
- **Opportunity Identification**: Acquire undervalued assets and businesses
- **Risk Management**: Reduce leverage and maintain liquidity

**Recovery/Boom Strategy**:
- **Growth Investments**: Increase stock market and business exposure
- **Leverage Utilization**: Strategic use of loans for asset acquisition
- **Expansion Focus**: Scale business operations and investment portfolios

---

*Part of the [IIC Cashflow Game 2025](../../README.md) documentation*