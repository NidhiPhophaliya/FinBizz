import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

interface CommodityQuote {
  symbol: string;
  price: number;
  change: number;
}

let cache: { data: CommodityQuote[]; ts: number } | null = null;

const fallback: CommodityQuote[] = [
  { symbol: "Gold", price: 2325.4, change: 0.18 },
  { symbol: "Silver", price: 28.14, change: -0.22 },
  { symbol: "Crude Oil", price: 83.6, change: 0.28 },
  { symbol: "Natural Gas", price: 2.2, change: -0.44 },
];

export async function GET() {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  if (cache && Date.now() - cache.ts < 300000) {
    return NextResponse.json(cache.data);
  }
  cache = { data: fallback, ts: Date.now() };
  return NextResponse.json(fallback);
}
