# 📊 Budgeting System

The budgeting system requires players to allocate income across five essential categories, simulating real-world financial planning.

## Budget Categories

| Category | Priority | Minimum | Effect | Calculation |
|----------|----------|---------|--------|-------------|
| **Daily Expenses** | 5 (Highest) | >0% | Survival requirement | Must be allocated |
| **Self Improvement** | 4 | 0% | Skill XP gain | 300 XP per $1K spent |
| **Recreational** | 3 | 0% | Happiness boost | 2 happiness per 10% |
| **Investment** | 2 | 0% | Investment account | Direct transfer |
| **Savings** | 1 (Lowest) | 0% | Savings account | Direct transfer |

## Budgeting Mechanics

**Allocation Rules**:
- Total allocation must equal 100% (10 units)
- Daily Expenses must be > 0% (survival requirement)
- System auto-adjusts lower priority categories when limits exceeded

**Budget Application**:
```dart
// Self-improvement to skill XP
int exp = (totalBudget × selfImprovementPercent / 10) / 1000 × 300

// Recreation to happiness  
int happiness = recreationalPercent × 2

// Financial transfers
savingsTransfer = totalBudget × savingsPercent / 10
investmentTransfer = totalBudget × investmentPercent / 10
```

**Strategic Considerations**:
- **Early Game**: Focus on self-improvement and savings accumulation
- **Mid Game**: Balance investment allocation with happiness maintenance  
- **Late Game**: Maximize investment allocation for compound growth

---

*Part of the [IIC Cashflow Game 2025](../../README.md) documentation*