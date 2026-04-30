export interface FinanceQuote {
  symbol: string;
  name: string;
  display: string;
  price: number | null;
  change: number | null;
  sparkline?: number[];
}

export interface SectorSnapshot {
  symbol: string;
  name: string;
  change: number | null;
  trailingPE?: number | null;
  forwardPE?: number | null;
}

export interface FinanceMonitorSnapshot {
  source: "worldmonitor" | "finnhub-alpha" | "fallback";
  updatedAt: string;
  rateLimited?: boolean;
  missing?: string[];
  marketQuotes: FinanceQuote[];
  commodityQuotes: FinanceQuote[];
  cryptoQuotes: FinanceQuote[];
  gulfQuotes: FinanceQuote[];
  sectors: SectorSnapshot[];
  fearGreedIndex?: {
    value: number | null;
    label: string;
  };
}
