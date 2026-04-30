# 🏠 Asset Management

Players can invest in appreciating assets that provide utility benefits and contribute to final wealth calculation.

## Real Estate Investment

**Property Types**:

| Property | Base Cost | Marriage Requirement | Appreciation |
|----------|-----------|---------------------|--------------|
| **HDB Flat** | Variable | Yes | Market-based |
| **Condominium** | Variable | No | Market-based |
| **Bungalow** | Variable | No | Market-based |

**Real Estate Mechanics**:
- **Appreciation**: All properties appreciate in value each round
- **Mortgage Options**: Available through asset loan system
- **Selling**: Properties can be sold during player's turn
- **Utility**: Provides happiness and ESG benefits

## Vehicle Investment

**Car Types**:

| Vehicle Type | ESG Rating | Happiness Bonus | Price Range |
|--------------|------------|-----------------|-------------|
| **Petrol Car** | Low | Standard | Budget-friendly |
| **Hybrid Car** | Medium | Enhanced | Mid-range |
| **Electric Car** | High | Maximum | Premium |

**Vehicle Mechanics**:
- **Certificate of Entitlement (COE)**: Required for all vehicles
- **COE Price Inflation**: Increases with each vehicle purchase by any player
- **Depreciation**: Cars lose value each round
- **Loan Options**: Available through asset loan system
- **Environmental Impact**: Electric vehicles provide maximum ESG benefits

## Asset Loan System

**Loan Requirements**:
- **Debt Service Ratio**: Total loan repayments cannot exceed 70% of salary
- **Repayment Source**: Automatic deduction from Savings Account
- **Default Handling**: Delayed to next round if insufficient funds

**Loan Calculation**:
```
maxMonthlyPayment = salary × 0.70
maxLoanAmount = maxMonthlyPayment × loanTerm × interestAdjustment
```

---

*Part of the [IIC Cashflow Game 2025](../../README.md) documentation*