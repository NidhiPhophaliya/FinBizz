"use client";

import { useState } from "react";
import useSWR from "swr";
import NewsCard, { type NewsArticle } from "@/components/dashboard/NewsCard";
import { Skeleton } from "@/components/ui/Skeleton";

type NewsTab = "markets" | "economics" | "breaking" | "commodities";
const TABS: { label: string; value: NewsTab }[] = [
  { label: "Markets", value: "markets" },
  { label: "Macro", value: "economics" },
  { label: "Breaking", value: "breaking" },
  { label: "Commodities", value: "commodities" },
];

async function fetchJson<T>(url: string): Promise<T> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Request failed: ${res.status}`);
  return res.json() as Promise<T>;
}

interface CommodityQuote {
  symbol: string;
  price: number;
  change: number;
}

export default function RightNewsPanel() {
  const [activeTab, setActiveTab] = useState<NewsTab>("markets");

  const news = useSWR<NewsArticle[]>(
    activeTab !== "commodities" ? `/api/news?category=${activeTab}` : null,
    fetchJson,
    { refreshInterval: 60_000 },
  );

  const commodities = useSWR<CommodityQuote[]>(
    activeTab === "commodities" ? "/api/commodities" : null,
    fetchJson,
    { refreshInterval: 300_000 },
  );

  return (
    <aside className="relative hidden h-full w-[300px] shrink-0 flex-col border-l border-[#36384a] bg-[#0f111a] md:flex">
      {/* Tab header */}
      <div className="flex h-10 shrink-0 items-stretch border-b border-[#36384a]">
        {TABS.map((tab) => (
          <button
            key={tab.value}
            onClick={() => setActiveTab(tab.value)}
            className={`flex flex-1 items-center justify-center border-b-2 text-[10px] font-bold uppercase tracking-wide transition-colors ${
              activeTab === tab.value
                ? "border-[#42a5f5] text-white"
                : "border-transparent text-[#a7b1c1] hover:text-white"
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Content */}
      <div className="min-h-0 flex-1 overflow-y-auto">
        {activeTab === "commodities" ? (
          <div className="space-y-2 p-3">
            {commodities.isLoading ? (
              <>
                <Skeleton className="h-12" />
                <Skeleton className="h-12" />
                <Skeleton className="h-12" />
              </>
            ) : (commodities.data ?? []).length === 0 ? (
              <EmptyState label="No commodity data" />
            ) : (
              (commodities.data ?? []).map((item) => (
                <div
                  key={item.symbol}
                  className="flex items-center justify-between rounded-xl border border-[#36384a] bg-[#1a1c26] p-3"
                >
                  <span className="text-sm font-bold text-white">{item.symbol}</span>
                  <span className="font-mono text-sm text-white">
                    ${item.price.toFixed(2)}
                  </span>
                  <span
                    className={`text-sm font-bold ${
                      item.change >= 0 ? "text-[#99ff88]" : "text-[#ff5050]"
                    }`}
                  >
                    {item.change >= 0 ? "+" : ""}
                    {item.change.toFixed(2)}%
                  </span>
                </div>
              ))
            )}
          </div>
        ) : news.isLoading ? (
          <div className="space-y-3 p-3">
            <Skeleton className="h-20" />
            <Skeleton className="h-20" />
            <Skeleton className="h-20" />
            <Skeleton className="h-20" />
          </div>
        ) : (news.data ?? []).length === 0 ? (
          <EmptyState label="No articles yet" />
        ) : (
          <div className="divide-y divide-[#36384a]">
            {(news.data ?? []).map((article) => (
              <NewsCard key={article.url} article={article} category={activeTab} />
            ))}
          </div>
        )}
      </div>

      {/* Footer */}
      <div className="shrink-0 border-t border-[#36384a] px-3 py-2">
        <p className="text-[9px] text-[#a7b1c1]/50">
          Data refreshes every 60s · WorldMonitor API
        </p>
      </div>
    </aside>
  );
}

function EmptyState({ label }: { label: string }) {
  return (
    <div className="flex flex-col items-center justify-center gap-2 py-16 text-center">
      <span className="text-2xl">📭</span>
      <p className="text-xs text-[#a7b1c1]">{label}</p>
    </div>
  );
}
