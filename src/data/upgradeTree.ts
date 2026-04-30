export type UpgradeKey =
  | "savings_account"
  | "fixed_deposit"
  | "dividend_stock"
  | "real_estate"
  | "index_fund"
  | "compound_boost"
  | "tax_advantage"
  | "hedge_fund";

export interface Upgrade {
  key: UpgradeKey;
  name: string;
  cost: number;
  description: string;
  rateBoost?: number;
  passiveIncome?: number;
  speedMultiplier?: number;
}

export const upgrades: Upgrade[] = [
  { key: "savings_account", name: "Open Savings Account", cost: 100, description: "+0.5% interest rate", rateBoost: 0.005 },
  { key: "fixed_deposit", name: "Fixed Deposit", cost: 500, description: "+1% interest rate", rateBoost: 0.01 },
  { key: "dividend_stock", name: "Buy Dividend Stocks", cost: 2000, description: "+$50 passive per tick", passiveIncome: 50 },
  { key: "real_estate", name: "Real Estate", cost: 10000, description: "+3% interest rate", rateBoost: 0.03 },
  { key: "index_fund", name: "Index Fund", cost: 5000, description: "Doubles tick speed", speedMultiplier: 2 },
  { key: "compound_boost", name: "Compound Boost", cost: 1000, description: "+0.75% reinvestment boost", rateBoost: 0.0075 },
  { key: "tax_advantage", name: "Tax Advantage Account", cost: 3000, description: "+1.25% effective return", rateBoost: 0.0125 },
  { key: "hedge_fund", name: "Hedge Fund", cost: 50000, description: "+5% interest rate", rateBoost: 0.05 },
];
