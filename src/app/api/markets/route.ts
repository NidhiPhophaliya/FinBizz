import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

interface MarketQuote {
  symbol: string;
  price: number;
  change: number;
}

let cache: { data: MarketQuote[]; ts: number } | null = null;
const symbols = ["SPY", "QQQ", "DIA", "NIFTY"];

const fallback: MarketQuote[] = [
  { symbol: "SPY", price: 522.41, change: 0.34 },
  { symbol: "QQQ", price: 452.9, change: 0.57 },
  { symbol: "DIA", price: 393.12, change: -0.08 },
  { symbol: "NIFTY", price: 22580.2, change: 0.41 },
  { symbol: "Gold", price: 2325.4, change: 0.18 },
  { symbol: "Silver", price: 28.14, change: -0.22 },
  { symbol: "Copper", price: 4.47, change: 0.31 },
  { symbol: "Iron Ore", price: 107.8, change: -0.15 },
  { symbol: "Brent", price: 88.2, change: 0.2 },
  { symbol: "WTI", price: 83.6, change: 0.28 },
  { symbol: "Natural Gas", price: 2.2, change: -0.44 },
  { symbol: "Coal", price: 132.5, change: 0.04 },
];

export async function GET() {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  if (cache && Date.now() - cache.ts < 60000) {
    return NextResponse.json(cache.data);
  }

  const key = process.env.FINNHUB_API_KEY;
  if (!key) {
    return NextResponse.json(fallback);
  }

  try {
    const live = await Promise.all(
      symbols.map(async (symbol) => {
        const res = await fetch(`https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${key}`);
        const data = (await res.json()) as { c?: number; dp?: number };
        return { symbol, price: data.c ?? 0, change: data.dp ?? 0 };
      }),
    );
    const data = [...live, ...fallback.filter((item) => !symbols.includes(item.symbol))];
    cache = { data, ts: Date.now() };
    return NextResponse.json(data);
  } catch {
    return NextResponse.json(fallback);
  }
}
