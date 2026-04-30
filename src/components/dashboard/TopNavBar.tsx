"use client";

import { useEffect, useState } from "react";
import { Search, Bell, Settings, Link2, RefreshCw } from "lucide-react";
import { UserButton } from "@clerk/nextjs";
import GamesHubButton from "@/components/games/GamesHubButton";
import { useDashboardStore, type MapScope, type MapViewMode, type TimeRange } from "@/store/dashboardStore";

const TIME_RANGES: { label: string; value: TimeRange }[] = [
  { label: "1H", value: "1h" },
  { label: "6H", value: "6h" },
  { label: "24H", value: "24h" },
  { label: "48H", value: "48h" },
  { label: "7D", value: "7d" },
  { label: "ALL", value: "all" },
];

const SCOPES: { label: string; value: MapScope }[] = [
  { label: "Global", value: "global" },
  { label: "Asia-Pacific", value: "asia" },
  { label: "Europe", value: "europe" },
  { label: "Americas", value: "americas" },
  { label: "Watchlist", value: "watchlist" },
];

function utcTimestamp(date: Date) {
  const d = date.toUTCString().replace("GMT", "UTC").replace(",", "").toUpperCase();
  return d;
}

export default function TopNavBar() {
  const [now, setNow] = useState(() => new Date());
  const [isLive, setIsLive] = useState(true);

  const mapScope = useDashboardStore((s) => s.mapScope);
  const setMapScope = useDashboardStore((s) => s.setMapScope);
  const mapViewMode = useDashboardStore((s) => s.mapViewMode);
  const setMapViewMode = useDashboardStore((s) => s.setMapViewMode);
  const timeRange = useDashboardStore((s) => s.timeRange);
  const setTimeRange = useDashboardStore((s) => s.setTimeRange);

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <header className="z-50 flex h-[52px] shrink-0 flex-col border-b border-[#36384a] bg-[#0f111a]">
      <div className="flex h-full items-center gap-2 px-3">

        {/* ── Brand ─────────────────────────────────────────────────────── */}
        <div className="flex shrink-0 items-center gap-2">
          <div className="flex items-center gap-1 text-xl font-black tracking-tight">
            <span className="text-[#42a5f5]">FIN</span>
            <span className="text-[#ffd780]">LIT</span>
          </div>
          <span className="hidden rounded border border-[#36384a] px-1.5 py-0.5 text-[9px] font-bold text-[#a7b1c1] sm:block">
            v2.0
          </span>
        </div>

        {/* ── Live indicator ────────────────────────────────────────────── */}
        <div className="hidden items-center gap-1.5 sm:flex">
          <span className="h-2 w-2 animate-pulse rounded-full bg-[#99ff88]" />
          <span className="text-[10px] font-bold uppercase tracking-widest text-[#99ff88]">
            {isLive ? "LIVE" : "PAUSED"}
          </span>
        </div>

        <div className="mx-2 hidden h-5 w-px bg-[#36384a] sm:block" />

        {/* ── Region selector ───────────────────────────────────────────── */}
        <select
          className="hidden h-8 rounded-lg border border-[#36384a] bg-[#1d1f29] px-2.5 text-xs font-medium text-white outline-none transition-colors hover:border-[#42a5f5] focus:border-[#42a5f5] md:block"
          value={mapScope}
          onChange={(e) => setMapScope(e.target.value as MapScope)}
          aria-label="Map region"
        >
          {SCOPES.map((s) => (
            <option key={s.value} value={s.value}>{s.label}</option>
          ))}
        </select>

        {/* ── UTC clock ─────────────────────────────────────────────────── */}
        <time className="hidden font-mono text-[11px] text-[#a7b1c1] md:block">
          {utcTimestamp(now)}
        </time>

        {/* ── Spacer ───────────────────────────────────────────────────── */}
        <div className="flex-1" />

        {/* ── Time range pills ─────────────────────────────────────────── */}
        <div className="hidden items-center gap-0.5 rounded-lg border border-[#36384a] bg-[#1d1f29] p-0.5 sm:flex">
          {TIME_RANGES.map((r) => (
            <button
              key={r.value}
              onClick={() => setTimeRange(r.value)}
              className={`rounded px-2.5 py-1 text-[10px] font-bold transition-all ${
                timeRange === r.value
                  ? "bg-[#42a5f5] text-[#0f111a] shadow"
                  : "text-[#a7b1c1] hover:bg-[#272937] hover:text-white"
              }`}
            >
              {r.label}
            </button>
          ))}
        </div>

        <div className="mx-2 hidden h-5 w-px bg-[#36384a] sm:block" />

        {/* ── 2D / 3D toggle ───────────────────────────────────────────── */}
        <div className="flex items-center rounded-lg border border-[#36384a] bg-[#1d1f29] p-0.5">
          {(["2d", "3d"] as MapViewMode[]).map((mode) => (
            <button
              key={mode}
              onClick={() => setMapViewMode(mode)}
              className={`rounded px-3 py-1 text-[10px] font-bold uppercase transition-all ${
                mapViewMode === mode
                  ? "bg-[#42a5f5] text-[#0f111a]"
                  : "text-[#a7b1c1] hover:text-white"
              }`}
            >
              {mode}
            </button>
          ))}
        </div>

        <div className="mx-2 hidden h-5 w-px bg-[#36384a] sm:block" />

        {/* ── Action buttons ────────────────────────────────────────────── */}
        <button
          className="hidden h-8 w-8 items-center justify-center rounded-lg text-[#a7b1c1] transition-colors hover:bg-[#272937] hover:text-white sm:flex"
          aria-label="Search"
        >
          <Search size={16} />
        </button>

        <button
          className="hidden h-8 w-8 items-center justify-center rounded-lg text-[#a7b1c1] transition-colors hover:bg-[#272937] hover:text-white sm:flex"
          aria-label="Refresh"
          onClick={() => { setIsLive(false); setTimeout(() => setIsLive(true), 500); }}
        >
          <RefreshCw size={15} />
        </button>

        <GamesHubButton />

        <UserButton
          appearance={{
            elements: {
              avatarBox: "h-7 w-7",
            },
          }}
        />
      </div>

      {/* ── Global situation bar ──────────────────────────────────────────── */}
      <div className="flex h-8 shrink-0 items-center justify-between border-t border-[#36384a] bg-[#0d0f17] px-4">
        <span className="text-[10px] font-bold uppercase tracking-widest text-[#a7b1c1]">
          Global Situation
        </span>
        <time className="font-mono text-[10px] text-[#a7b1c1]">
          {utcTimestamp(now)}
        </time>
        <div className="flex items-center gap-1">
          <button className="rounded px-2 py-0.5 text-[9px] font-bold uppercase text-[#a7b1c1] hover:bg-[#272937]">
            ⊞
          </button>
          <button className="rounded px-2 py-0.5 text-[9px] font-bold uppercase text-[#a7b1c1] hover:bg-[#272937]">
            ↗
          </button>
        </div>
      </div>
    </header>
  );
}
