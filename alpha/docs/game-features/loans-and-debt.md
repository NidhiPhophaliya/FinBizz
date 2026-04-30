# 💸 Loans and Debt

The loan system provides financing options for major purchases while introducing realistic debt management challenges.

## Loan Types

**Asset Loans**:
- **Purpose**: Real estate and vehicle purchases
- **Requirement**: Debt service ratio ≤ 70% of salary
- **Repayment**: Automatic from Savings Account
- **Interest**: Applied according to loan terms
- **Default**: Delayed payment if insufficient funds

**Business Loans**:
- **Purpose**: Business acquisition and operations
- **Requirement**: None (high accessibility)
- **Repayment**: Profit-first from business earnings
- **Loss Handling**: Losses added to principal debt
- **Interest**: No interest charges

## Debt Management Mechanics

**Asset Loan Calculation**:
```dart
maxMonthlyPayment = salary × 0.70
availableLoanCapacity = maxMonthlyPayment - currentLoanPayments
```

**Business Debt Dynamics**:
```dart
// Profitable business
netEarnings = businessEarnings - debtRepayment

// Unprofitable business  
totalDebt = previousDebt + businessLosses
```

## Debt Impact on Scoring

**Debt Penalty Structure**:
- **≤10% Debt-to-Asset Ratio**: No penalty
- **11-25% DAR**: 5% score penalty
- **26-50% DAR**: 15% score penalty
- **51-75% DAR**: 25% score penalty
- **76-90% DAR**: 50% score penalty
- **≥90% DAR**: 80% score penalty

**Strategic Debt Management**:
- Maintain debt-to-asset ratio below 10% for optimal scoring
- Use business loans strategically (no interest charges)
- Consider debt payoff timing before game end
- Balance leverage benefits against penalty risks

---

*Part of the [IIC Cashflow Game 2025](../../README.md) documentation*