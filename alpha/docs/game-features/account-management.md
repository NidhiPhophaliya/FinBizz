# 💰 Account Management System

Players manage three distinct account types, each serving specific purposes in the financial ecosystem:

## Account Types & Interest Rates

1. **Savings Account** (2.5% annual interest)
   - **Purpose**: Primary spending account for purchases
   - **Funding**: Manual allocation through budgeting system
   - **Features**: Unbudgeted income tracking, immediate accessibility

2. **Investment Account** (4.5% annual interest)  
   - **Purpose**: Stock trading and investment activities
   - **Funding**: Manual allocation through budgeting system
   - **Features**: Portfolio management, share ownership tracking

3. **CPF Account** (12% annual interest)
   - **Purpose**: Retirement savings (Singapore's Central Provident Fund)
   - **Funding**: Automatic 20% of salary contribution
   - **Restrictions**: Cannot be used for purchases (counts toward final assets)

## Financial Mechanics

**Interest Calculation**: Applied at the end of each round
```dart
newBalance = currentBalance × (1 + interestRate/100)
```

**Purchase Priority**: Funds deducted in order:
1. Savings Account balance
2. Investment Account balance  
3. Unbudgeted savings
4. Transaction fails if insufficient funds

**Initial Balances**:
- Savings: $4,000
- Investment: $1,000
- CPF: $0

---

*Part of the [IIC Cashflow Game 2025](../../README.md) documentation*