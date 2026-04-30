"use client";

import useSWR from "swr";
import type { FinanceMonitorSnapshot, FinanceQuote } from "@/types/financeMonitor";

async function fetchMarkets(url: string): Promise<FinanceMonitorSnapshot> {
  const res = await fetch(url);
  if (!res.ok) throw new Error("Unable to load markets");
  return res.json() as Promise<FinanceMonitorSnapshot>;
}

function fmt(price: number | null) {
  if (price == null) return "—";
  if (price >= 10000) return price.toLocaleString("en-US", { maximumFractionDigits: 0 });
  if (price >= 1000) return price.toLocaleString("en-US", { maximumFractionDigits: 1 });
  return price.toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function TickerItem({ quote }: { quote: FinanceQuote }) {
  const change = quote.change ?? 0;
  const isPos = change >= 0;
  return (
    <div className="flex shrink-0 items-center gap-2 border-r border-[#36384a] px-4 py-1">
      <span className="text-[11px] font-bold text-[#a7b1c1]">{quote.display}</span>
      <span className="font-mono text-[12px] font-bold text-white">{fmt(quote.price)}</span>
      <span
        className={`flex items-center gap-0.5 text-[11px] font-bold ${
          isPos ? "text-[#99ff88]" : "text-[#ff5050]"
        }`}
      >
        {isPos ? "▲" : "▼"}
        {Math.abs(change).toFixed(2)}%
      </span>
    </div>
  );
}

function SkeletonItem() {
  return (
    <div className="flex shrink-0 items-center gap-3 border-r border-[#36384a] px-4 py-1">
      <div className="h-3 w-12 animate-pulse rounded bg-[#36384a]" />
      <div className="h-3 w-16 animate-pulse rounded bg-[#36384a]" />
      <div className="h-3 w-10 animate-pulse rounded bg-[#36384a]" />
    </div>
  );
}

export default function MarketCardsStrip() {
  const { data, isLoading } = useSWR("/api/finance-monitor", fetchMarkets, {
    refreshInterval: 30_000,
  });

  const allQuotes: FinanceQuote[] = [
    ...(data?.marketQuotes ?? []),
    ...(data?.commodityQuotes ?? []),
    ...(data?.cryptoQuotes ?? []),
    ...(data?.gulfQuotes ?? []),
  ];

  return (
    <footer className="z-40 flex h-9 w-full shrink-0 items-center overflow-hidden border-t border-[#36384a] bg-[#0d0f17]">
      {/* Left label */}
      <div className="flex h-full shrink-0 items-center gap-2 border-r border-[#36384a] bg-[#0f111a] px-3">
        <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-[#99ff88]" />
        <span className="text-[9px] font-bold uppercase tracking-widest text-[#a7b1c1]">Live</span>
      </div>

      {/* Scrolling ticker */}
      <div className="ticker-scroll flex h-full min-w-0 flex-1 items-center overflow-hidden">
        <div className="ticker-inner flex h-full animate-marquee items-center">
          {isLoading
            ? Array.from({ length: 10 }).map((_, i) => <SkeletonItem key={i} />)
            : [...allQuotes, ...allQuotes].map((q, i) => (
                <TickerItem key={`${q.symbol}-${i}`} quote={q} />
              ))}
        </div>
      </div>
    </footer>
  );
}
