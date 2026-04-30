import type { FinanceMonitorSnapshot, FinanceQuote, SectorSnapshot } from "@/types/financeMonitor";

const WORLD_MONITOR_BOOTSTRAP_URL = "https://api.worldmonitor.app/api/bootstrap";
const WORLD_MONITOR_KEYS = [
  "marketQuotes",
  "commodityQuotes",
  "sectors",
  "cryptoQuotes",
  "gulfQuotes",
  "fearGreedIndex",
] as const;

const INDEX_SYMBOLS = [
  { symbol: "SPY", name: "S&P 500 ETF", display: "S&P 500" },
  { symbol: "QQQ", name: "Nasdaq 100 ETF", display: "NASDAQ" },
  { symbol: "DIA", name: "Dow Jones ETF", display: "Dow" },
  { symbol: "EWU", name: "United Kingdom ETF", display: "UK" },
  { symbol: "EWJ", name: "Japan ETF", display: "Japan" },
  { symbol: "INDA", name: "India ETF", display: "India" },
  { symbol: "MCHI", name: "China ETF", display: "China" },
] as const;

const FALLBACK: FinanceMonitorSnapshot = {
  source: "fallback",
  updatedAt: new Date(0).toISOString(),
  missing: [],
  marketQuotes: [
    { symbol: "SPY", name: "S&P 500 ETF", display: "S&P 500", price: 522.41, change: 0.34 },
    { symbol: "QQQ", name: "Nasdaq 100 ETF", display: "NASDAQ", price: 452.9, change: 0.57 },
    { symbol: "DIA", name: "Dow Jones ETF", display: "Dow", price: 393.12, change: -0.08 },
    { symbol: "INDA", name: "India ETF", display: "India", price: 51.8, change: 0.41 },
  ],
  commodityQuotes: [
    { symbol: "GC=F", name: "Gold Futures", display: "Gold", price: 2325.4, change: 0.18 },
    { symbol: "SI=F", name: "Silver Futures", display: "Silver", price: 28.14, change: -0.22 },
    { symbol: "CL=F", name: "WTI Crude", display: "WTI", price: 83.6, change: 0.28 },
    { symbol: "NG=F", name: "Natural Gas", display: "Natural Gas", price: 2.2, change: -0.44 },
  ],
  cryptoQuotes: [
    { symbol: "BTC", name: "Bitcoin", display: "BTC", price: 68400, change: 1.1 },
    { symbol: "ETH", name: "Ethereum", display: "ETH", price: 3520, change: 0.8 },
  ],
  gulfQuotes: [
    { symbol: "TASI", name: "Tadawul All Share", display: "Tadawul", price: 12400, change: 0.24 },
    { symbol: "DFMGI", name: "Dubai Financial Market", display: "Dubai", price: 4300, change: 0.13 },
  ],
  sectors: [
    { symbol: "XLK", name: "Technology", change: 0.57 },
    { symbol: "XLF", name: "Financials", change: 0.22 },
    { symbol: "XLE", name: "Energy", change: -0.14 },
    { symbol: "XLV", name: "Healthcare", change: 0.08 },
  ],
  fearGreedIndex: { value: 50, label: "Neutral" },
};

interface UnknownRecord {
  [key: string]: unknown;
}

interface WorldMonitorBootstrapResponse {
  data?: UnknownRecord;
  missing?: string[];
}

function isRecord(value: unknown): value is UnknownRecord {
  return typeof value === "object" && value !== null;
}

function asNumber(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function asString(value: unknown, fallback: string) {
  return typeof value === "string" && value.trim() ? value : fallback;
}

function asSparkline(value: unknown) {
  return Array.isArray(value)
    ? value.map(asNumber).filter((item): item is number => item !== null)
    : undefined;
}

function normalizeQuote(value: unknown): FinanceQuote | null {
  if (!isRecord(value)) {
    return null;
  }
  const symbol = asString(value.symbol, "");
  if (!symbol) {
    return null;
  }
  return {
    symbol,
    name: asString(value.name, symbol),
    display: asString(value.display, symbol),
    price: asNumber(value.price),
    change: asNumber(value.change),
    sparkline: asSparkline(value.sparkline),
  };
}

function normalizeQuoteList(value: unknown): FinanceQuote[] {
  const list = isRecord(value) && Array.isArray(value.quotes) ? value.quotes : Array.isArray(value) ? value : [];
  return list.map(normalizeQuote).filter((quote): quote is FinanceQuote => quote !== null);
}

function normalizeSectors(value: unknown): SectorSnapshot[] {
  const sectors = isRecord(value) && Array.isArray(value.sectors) ? value.sectors : [];
  const valuations = isRecord(value) && isRecord(value.valuations) ? value.valuations : {};
  return sectors.filter(isRecord).map((sector) => {
    const symbol = asString(sector.symbol, asString(sector.name, "Sector"));
    const valuation = isRecord(valuations[symbol]) ? valuations[symbol] : {};
    return {
      symbol,
      name: asString(sector.name, symbol),
      change: asNumber(sector.change),
      trailingPE: asNumber(valuation.trailingPE),
      forwardPE: asNumber(valuation.forwardPE),
    };
  });
}

function normalizeFearGreed(value: unknown): FinanceMonitorSnapshot["fearGreedIndex"] {
  if (!isRecord(value)) {
    return undefined;
  }
  return {
    value: asNumber(value.value ?? value.score ?? value.index),
    label: asString(value.label ?? value.rating ?? value.classification, "Unknown"),
  };
}

async function fetchWorldMonitorSnapshot(): Promise<FinanceMonitorSnapshot | null> {
  const url = new URL(WORLD_MONITOR_BOOTSTRAP_URL);
  url.searchParams.set("keys", WORLD_MONITOR_KEYS.join(","));

  const headers: HeadersInit = {};
  const apiKey = process.env.WORLD_MONITOR_API_KEY;
  if (apiKey) {
    headers["X-WorldMonitor-Key"] = apiKey;
  }

  const res = await fetch(url, {
    headers,
    next: { revalidate: 30 },
  });

  if (!res.ok) {
    return null;
  }

  const payload = (await res.json()) as WorldMonitorBootstrapResponse;
  const data = payload.data ?? {};

  return {
    source: "worldmonitor",
    updatedAt: new Date().toISOString(),
    missing: payload.missing ?? [],
    marketQuotes: normalizeQuoteList(data.marketQuotes),
    commodityQuotes: normalizeQuoteList(data.commodityQuotes),
    cryptoQuotes: normalizeQuoteList(data.cryptoQuotes),
    gulfQuotes: normalizeQuoteList(data.gulfQuotes),
    sectors: normalizeSectors(data.sectors),
    fearGreedIndex: normalizeFearGreed(data.fearGreedIndex),
  };
}

async function fetchFinnhubQuote(symbol: string, token: string): Promise<FinanceQuote | null> {
  const res = await fetch(`https://finnhub.io/api/v1/quote?symbol=${encodeURIComponent(symbol)}&token=${token}`, {
    next: { revalidate: 30 },
  });
  if (!res.ok) {
    return null;
  }
  const data = (await res.json()) as UnknownRecord;
  const price = asNumber(data.c);
  if (price === null) {
    return null;
  }
  const meta = INDEX_SYMBOLS.find((item) => item.symbol === symbol);
  return {
    symbol,
    name: meta?.name ?? symbol,
    display: meta?.display ?? symbol,
    price,
    change: asNumber(data.dp),
  };
}

async function fetchFallbackLiveSnapshot(): Promise<FinanceMonitorSnapshot> {
  const token = process.env.FINNHUB_API_KEY;
  if (!token) {
    return { ...FALLBACK, updatedAt: new Date().toISOString() };
  }

  const quotes = await Promise.all(INDEX_SYMBOLS.map((item) => fetchFinnhubQuote(item.symbol, token)));
  const liveQuotes = quotes.filter((quote): quote is FinanceQuote => quote !== null);
  return {
    ...FALLBACK,
    source: "finnhub-alpha",
    updatedAt: new Date().toISOString(),
    marketQuotes: liveQuotes.length ? liveQuotes : FALLBACK.marketQuotes,
  };
}

function isUseful(snapshot: FinanceMonitorSnapshot) {
  return (
    snapshot.marketQuotes.length > 0 ||
    snapshot.commodityQuotes.length > 0 ||
    snapshot.cryptoQuotes.length > 0 ||
    snapshot.sectors.length > 0
  );
}

export async function getFinanceMonitorSnapshot(): Promise<FinanceMonitorSnapshot> {
  try {
    const worldMonitor = await fetchWorldMonitorSnapshot();
    if (worldMonitor && isUseful(worldMonitor)) {
      return worldMonitor;
    }
  } catch {
    // Fall through to local live providers.
  }

  return fetchFallbackLiveSnapshot();
}
