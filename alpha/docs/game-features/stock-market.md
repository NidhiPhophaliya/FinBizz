# 📈 Stock Market Simulation

The game features a sophisticated stock market simulation using **Geometric Brownian Motion (GBM)** to model realistic price movements.

## Stock Market Mechanics

**Available Stocks**: 10 stocks across 5 business sectors

| Sector | Stocks | Risk Levels | ESG Ratings |
|--------|--------|-------------|-------------|
| Technology | Quantum Tech (QTS), V Robotics (VRX) | High, Medium | 30, 15 |
| E-commerce | GlobalCart (GCT), ShopGo (SGI) | High, High | 5, 5 |
| F&B | FreshFeast (FST), FastFoods (FFF) | Medium, Medium | 35, 0 |
| Pharmaceutical | BioNova (BNA), Mystica (MYS) | Medium, Medium | 25, 10 |
| Social Media | SocialSphere (SOC), AlphaMedia (AMG) | Low, High | 10, 0 |

## Price Simulation Algorithm

**Base Geometric Brownian Motion Formula**:
```
S_new = S_current × exp(totalMovement)
```

**Total Movement Calculation**:
```
totalMovement = baseMovement + sectorTrendEffect + marketSentimentEffect
```

**Component Formulas**:
1. **Base Movement (Standard GBM)**:
   ```
   baseMovement = (μ - 0.5 × σ²) × dt + σ × dW
   ```
   Where: `dW = √dt × Z` (Wiener process increment)

2. **Sector Trend Effect**:
   ```
   sectorTrendEffect = sectorTrend × 0.8 × dt
   ```

3. **Market Sentiment Effect**:
   ```
   marketSentimentEffect = marketSentiment × 0.6 × dt
   ```

**Parameters**:
- `S_current`: Current stock price
- `μ`: Stock's drift rate (percent expected return)
- `σ`: Stock's volatility (percent)
- `dt`: Time step = T/N = 15.0/140 ≈ 0.107 per round
- `Z`: Gaussian random variable N(0,1) using Box-Muller transform
- `sectorTrend`: ±1.0 based on world events
- `marketSentiment`: Economic cycle influence

**Market Influences**:
- **Economic Cycle Impact**: 
  - Depression: -0.5 market sentiment
  - Recession: 0.0 market sentiment  
  - Recovery: +0.5 market sentiment
  - Boom: +1.0 market sentiment

- **World Event Impact**: ±1.0 sector trend for affected sectors
- **Sector Trend Drift Constant**: 0.8 (kSectorTrendDrift)
- **Market Sentiment Drift Constant**: 0.6 (kMarketSentimentDrift)

## Investment Mechanics

**ESG Stock Benefits**:
- First-time purchase of ESG stocks (rating > 0) awards ESG points
- Selling all shares of ESG stock removes ESG points
- Higher ESG ratings provide better long-term stability

**Portfolio Tracking**:
- FIFO (First In, First Out) selling methodology
- Real-time profit/loss calculations
- Historical performance tracking
- Percentage and absolute return metrics

---

*Part of the [IIC Cashflow Game 2025](../../README.md) documentation*