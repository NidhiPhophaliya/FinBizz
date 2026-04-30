import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

interface CacheEntry {
  data: unknown;
  ts: number;
}

const cache = new Map<string, CacheEntry>();
const CACHE_TTL = 60 * 1000;

const fallbackArticles = [
  { title: "Global markets digest: investors weigh rates, earnings, and growth", url: "https://example.com/markets", source: { name: "FinLit Brief" }, publishedAt: new Date().toISOString() },
  { title: "Why inflation and interest rates move stock and bond prices", url: "https://example.com/inflation", source: { name: "FinLit Brief" }, publishedAt: new Date().toISOString() },
  { title: "Energy and commodities stay in focus as trade routes shift", url: "https://example.com/commodities", source: { name: "FinLit Brief" }, publishedAt: new Date().toISOString() },
];

export async function GET(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const url = new URL(req.url);
  const category = url.searchParams.get("category") ?? "general";
  const cacheKey = `news:${category}`;
  const cached = cache.get(cacheKey);
  if (cached && Date.now() - cached.ts < CACHE_TTL) {
    return NextResponse.json(cached.data);
  }

  const apiKey = process.env.NEWS_API_KEY;
  if (!apiKey) {
    return NextResponse.json(fallbackArticles);
  }

  try {
    const q =
      category === "markets"
        ? "stock market"
        : category === "economics"
          ? "economy inflation GDP"
          : category === "commodities"
            ? "oil gold commodities"
            : "finance";
    const res = await fetch(
      `https://newsapi.org/v2/everything?q=${encodeURIComponent(q)}&sortBy=publishedAt&pageSize=15&language=en`,
      { headers: { "X-Api-Key": apiKey } },
    );
    const data = (await res.json()) as { articles?: unknown[] };
    const articles = data.articles ?? fallbackArticles;
    cache.set(cacheKey, { data: articles, ts: Date.now() });
    return NextResponse.json(articles);
  } catch {
    return NextResponse.json(fallbackArticles);
  }
}
