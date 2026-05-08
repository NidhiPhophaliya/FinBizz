import { NextResponse } from "next/server";

const DEFAULT_SYMBOLS = "^GSPC,^DJI,^IXIC,^RUT,^FTSE,^GDAXI,^N225,^HSI";
const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

interface YahooQuotePoint {
  open?: number[];
  high?: number[];
  low?: number[];
  close?: number[];
  volume?: number[];
}

interface YahooChartResult {
  meta?: {
    symbol?: string;
    shortName?: string;
    longName?: string;
    regularMarketPrice?: number;
    chartPreviousClose?: number;
    previousClose?: number;
    regularMarketVolume?: number;
    regularMarketDayHigh?: number;
    regularMarketDayLow?: number;
    regularMarketOpen?: number;
  };
  timestamp?: number[];
  indicators?: {
    quote?: YahooQuotePoint[];
  };
}

interface YahooChartResponse {
  chart?: {
    result?: YahooChartResult[];
  };
}

function sanitizeSymbols(value: string) {
  return value
    .split(",")
    .map((symbol) => symbol.trim().replace(/[^A-Z0-9.=^-]/gi, ""))
    .filter(Boolean)
    .slice(0, 20);
}

async function getYahooQuote(symbol: string) {
  const url = `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}?range=5d&interval=1d&includePrePost=false`;
  const res = await fetch(url, {
    headers: { "User-Agent": USER_AGENT },
    next: { revalidate: 120 },
  });
  if (!res.ok) {
    return null;
  }

  const json = (await res.json()) as YahooChartResponse;
  const result = json.chart?.result?.[0];
  if (!result) {
    return null;
  }

  const meta = result.meta ?? {};
  const quote = result.indicators?.quote?.[0] ?? {};
  const timestamps = result.timestamp ?? [];
  const lastIndex = timestamps.length - 1;
  const price = meta.regularMarketPrice ?? quote.close?.[lastIndex] ?? 0;
  const previousClose =
    meta.chartPreviousClose ?? meta.previousClose ?? quote.close?.[Math.max(0, lastIndex - 1)] ?? price;
  const change = price - previousClose;
  const changePercent = previousClose ? (change / previousClose) * 100 : 0;

  return {
    symbol: meta.symbol ?? symbol,
    name: meta.shortName ?? meta.longName ?? meta.symbol ?? symbol,
    price,
    change,
    changePercent,
    volume: meta.regularMarketVolume ?? quote.volume?.[lastIndex] ?? 0,
    marketCap: 0,
    high: meta.regularMarketDayHigh ?? quote.high?.[lastIndex] ?? 0,
    low: meta.regularMarketDayLow ?? quote.low?.[lastIndex] ?? 0,
    open: meta.regularMarketOpen ?? quote.open?.[lastIndex] ?? 0,
    prevClose: previousClose,
  };
}

export async function GET(req: Request) {
  const url = new URL(req.url);
  const symbols = sanitizeSymbols(url.searchParams.get("symbols") ?? DEFAULT_SYMBOLS);
  const results = await Promise.allSettled(symbols.map((symbol) => getYahooQuote(symbol)));
  const quotes = results
    .map((result) => (result.status === "fulfilled" ? result.value : null))
    .filter(Boolean);

  return NextResponse.json(quotes);
}
