"use client";

import useSWR from "swr";
import { CircleAlert, Radio } from "lucide-react";
import { Skeleton } from "@/components/ui/Skeleton";
import type { FinanceMonitorSnapshot, FinanceQuote } from "@/types/financeMonitor";

async function fetchSnapshot(url: string): Promise<FinanceMonitorSnapshot> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error("Unable to load finance monitor");
  }
  return res.json() as Promise<FinanceMonitorSnapshot>;
}

function Change({ value }: { value: number | null }) {
  if (value === null) {
    return <span className="text-text-muted">--</span>;
  }
  return (
    <span className={value >= 0 ? "text-accent-green" : "text-red-400"}>
      {value >= 0 ? "+" : ""}
      {value.toFixed(2)}%
    </span>
  );
}

function QuoteRow({ quote }: { quote: FinanceQuote }) {
  return (
    <div className="grid grid-cols-[1fr_80px_64px] items-center gap-2 rounded-lg bg-bg-tertiary px-3 py-2 text-xs">
      <div className="min-w-0">
        <div className="truncate font-bold text-white">{quote.display}</div>
        <div className="truncate text-[10px] text-text-muted">{quote.symbol}</div>
      </div>
      <div className="text-right font-mono text-white">
        {quote.price === null ? "--" : quote.price.toLocaleString(undefined, { maximumFractionDigits: 2 })}
      </div>
      <div className="text-right font-mono">
        <Change value={quote.change} />
      </div>
    </div>
  );
}

export default function FinanceMonitorPanel() {
  const { data, isLoading, error } = useSWR("/api/finance-monitor", fetchSnapshot, {
    refreshInterval: 30000,
  });

  if (isLoading) {
    return (
      <section className="absolute bottom-[132px] right-[316px] z-30 hidden w-[360px] rounded-lg border border-accent-border bg-bg-secondary/95 p-3 shadow-xl md:block">
        <Skeleton className="h-44" />
      </section>
    );
  }

  if (error || !data) {
    return null;
  }

  const source =
    data.source === "worldmonitor"
      ? "WorldMonitor bootstrap"
      : data.source === "finnhub-alpha"
        ? "Direct live providers"
        : "Offline fallback";
  const stress = data.sectors.filter((sector) => (sector.change ?? 0) < 0).length;

  return (
    <section className="absolute bottom-[132px] right-[316px] z-30 hidden max-h-[420px] w-[360px] overflow-hidden rounded-lg border border-accent-border bg-bg-secondary/95 shadow-xl backdrop-blur md:block">
      <header className="border-b border-accent-border p-3">
        <div className="flex items-center justify-between gap-3">
          <h2 className="flex items-center gap-2 text-sm font-bold text-white">
            <Radio size={16} className="text-accent-green" />
            Real-Time Finance Radar
          </h2>
          <span className="rounded-full bg-bg-primary px-2 py-1 text-[10px] uppercase text-accent-teal">
            {source}
          </span>
        </div>
        <div className="mt-2 flex items-center justify-between text-[11px] text-text-muted">
          <span>Updated {new Date(data.updatedAt).toLocaleTimeString()}</span>
          {data.missing?.length ? (
            <span className="flex items-center gap-1 text-accent-gold">
              <CircleAlert size={12} />
              {data.missing.length} missing feeds
            </span>
          ) : (
            <span className="text-accent-green">feeds healthy</span>
          )}
        </div>
      </header>

      <div className="max-h-[350px] overflow-y-auto p-3">
        <div className="mb-3 grid grid-cols-3 gap-2">
          <div className="rounded-lg bg-bg-primary p-2">
            <div className="text-[10px] uppercase text-text-muted">Markets</div>
            <div className="font-mono text-lg font-bold text-white">{data.marketQuotes.length}</div>
          </div>
          <div className="rounded-lg bg-bg-primary p-2">
            <div className="text-[10px] uppercase text-text-muted">Sectors Red</div>
            <div className="font-mono text-lg font-bold text-red-400">{stress}</div>
          </div>
          <div className="rounded-lg bg-bg-primary p-2">
            <div className="text-[10px] uppercase text-text-muted">Fear/Greed</div>
            <div className="font-mono text-lg font-bold text-accent-gold">
              {data.fearGreedIndex?.value ?? "--"}
            </div>
          </div>
        </div>

        <div className="mb-3 grid grid-cols-2 gap-2">
          {data.sectors.slice(0, 8).map((sector) => (
            <div
              key={sector.symbol}
              className={`rounded p-2 text-xs ${
                (sector.change ?? 0) >= 0 ? "bg-accent-green/10" : "bg-red-400/10"
              }`}
            >
              <div className="truncate text-white">{sector.name}</div>
              <div className="font-mono">
                <Change value={sector.change} />
              </div>
            </div>
          ))}
        </div>

        <div className="space-y-2">
          {[...data.marketQuotes.slice(0, 5), ...data.commodityQuotes.slice(0, 4), ...data.cryptoQuotes.slice(0, 2)].map(
            (quote) => (
              <QuoteRow key={`${quote.symbol}-${quote.display}`} quote={quote} />
            ),
          )}
        </div>
      </div>
    </section>
  );
}
