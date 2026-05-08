import { NextResponse } from "next/server";

const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

interface YahooChartResponse {
  chart?: {
    result?: {
      timestamp?: number[];
      indicators?: {
        quote?: {
          open?: Array<number | null>;
          high?: Array<number | null>;
          low?: Array<number | null>;
          close?: Array<number | null>;
          volume?: Array<number | null>;
        }[];
      };
    }[];
  };
}

function sanitizeSymbol(value: string | null) {
  return (value || "AAPL").replace(/[^A-Z0-9.=^-]/gi, "") || "AAPL";
}

function sanitizeWindow(value: string | null, fallback: string) {
  return (value || fallback).replace(/[^a-zA-Z0-9]/g, "") || fallback;
}

export async function GET(req: Request) {
  const url = new URL(req.url);
  const symbol = sanitizeSymbol(url.searchParams.get("symbol"));
  const range = sanitizeWindow(url.searchParams.get("range"), "1mo");
  const interval = sanitizeWindow(url.searchParams.get("interval"), "1d");

  const yahooUrl = `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}?range=${range}&interval=${interval}&includePrePost=false`;
  const res = await fetch(yahooUrl, {
    headers: { "User-Agent": USER_AGENT },
    next: { revalidate: 120 },
  });

  if (!res.ok) {
    return NextResponse.json({ error: `Yahoo Finance ${res.status}` }, { status: 502 });
  }

  const json = (await res.json()) as YahooChartResponse;
  const result = json.chart?.result?.[0];
  const timestamps = result?.timestamp ?? [];
  const quote = result?.indicators?.quote?.[0] ?? {};

  const points = timestamps
    .map((timestamp, index) => ({
      date: new Date(timestamp * 1000).toISOString().slice(0, 10),
      open: quote.open?.[index],
      high: quote.high?.[index],
      low: quote.low?.[index],
      close: quote.close?.[index],
      volume: quote.volume?.[index],
    }))
    .filter((point) => point.close != null);

  return NextResponse.json({ symbol, points });
}
