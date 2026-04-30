"use client";

import { useState, useMemo } from "react";
import { ChevronLeft, ChevronRight, Search, Filter } from "lucide-react";
import { LAYER_CONFIG, type LayerKey } from "@/data/mapLayers";
import { useDashboardStore } from "@/store/dashboardStore";

const ALL_KEYS = Object.keys(LAYER_CONFIG) as LayerKey[];

const LAYER_GROUPS: { label: string; keys: LayerKey[] }[] = [
  {
    label: "Infrastructure",
    keys: ["undersea-cables", "pipelines", "trade-routes", "chokepoints"],
  },
  {
    label: "Finance",
    keys: ["stock-exchanges", "financial-centers", "central-banks", "commodity-hubs", "gcc-investments"],
  },
  {
    label: "Events",
    keys: ["natural-events", "internet-disruptions", "weather-alerts"],
  },
];

// Legend bottom items matching WorldMonitor
const LEGEND_ITEMS = [
  { label: "Stock Exchange", color: "#ffd780", shape: "circle" },
  { label: "Financial Center", color: "#42a5f5", shape: "circle" },
  { label: "Central Bank", color: "#ffffff", shape: "square" },
  { label: "Waterway / Route", color: "#00d4ff", shape: "line" },
];

export default function LayersPanel() {
  const [collapsed, setCollapsed] = useState(false);
  const [search, setSearch] = useState("");
  const activeMapLayers = useDashboardStore((s) => s.activeMapLayers);
  const toggleLayer = useDashboardStore((s) => s.toggleLayer);

  const filtered = useMemo(() => {
    if (!search.trim()) return null; // null = show all grouped
    const q = search.toLowerCase();
    return ALL_KEYS.filter((k) => LAYER_CONFIG[k].label.toLowerCase().includes(q));
  }, [search]);

  const activeCount = activeMapLayers.length;

  return (
    <aside
      className={`absolute left-4 top-4 z-30 flex flex-col rounded-xl border border-[#36384a] bg-[#1a1c26]/95 shadow-2xl backdrop-blur-sm transition-all duration-200 ${
        collapsed ? "w-[52px]" : "w-[220px]"
      }`}
      style={{ maxHeight: "calc(100vh - 180px)" }}
    >
      {/* ── Header ─────────────────────────────────────────────────── */}
      <div className="flex h-11 shrink-0 items-center justify-between border-b border-[#36384a] px-3">
        {!collapsed && (
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold uppercase tracking-widest text-white">Layers</span>
            <span className="rounded bg-[#36384a] px-1.5 py-0.5 text-[10px] font-bold text-[#a7b1c1]">
              {activeCount}
            </span>
          </div>
        )}
        <button
          className="ml-auto rounded-lg p-1.5 text-[#a7b1c1] transition-colors hover:bg-[#36384a] hover:text-white"
          onClick={() => setCollapsed((v) => !v)}
          aria-label={collapsed ? "Expand layers" : "Collapse layers"}
        >
          {collapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
        </button>
      </div>

      {!collapsed && (
        <>
          {/* ── Search ─────────────────────────────────────────────── */}
          <div className="shrink-0 border-b border-[#36384a] p-2">
            <div className="flex items-center gap-2 rounded-lg bg-[#272937] px-2.5 py-1.5">
              <Search size={13} className="shrink-0 text-[#a7b1c1]" />
              <input
                type="text"
                placeholder="Search layers…"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full bg-transparent text-xs text-white placeholder-[#a7b1c1] outline-none"
              />
            </div>
          </div>

          {/* ── Layer List ──────────────────────────────────────────── */}
          <div className="min-h-0 flex-1 overflow-y-auto">
            {filtered ? (
              /* Search results (flat) */
              <div className="p-2 space-y-0.5">
                {filtered.length === 0 && (
                  <p className="py-4 text-center text-[11px] text-[#a7b1c1]">No layers found</p>
                )}
                {filtered.map((key) => (
                  <LayerRow
                    key={key}
                    layerKey={key}
                    checked={activeMapLayers.includes(key)}
                    onToggle={() => toggleLayer(key)}
                  />
                ))}
              </div>
            ) : (
              /* Grouped view */
              <div className="p-2 space-y-3">
                {LAYER_GROUPS.map((group) => (
                  <div key={group.label}>
                    <p className="mb-1 px-2 text-[9px] font-bold uppercase tracking-widest text-[#a7b1c1]/60">
                      {group.label}
                    </p>
                    <div className="space-y-0.5">
                      {group.keys.map((key) => (
                        <LayerRow
                          key={key}
                          layerKey={key}
                          checked={activeMapLayers.includes(key)}
                          onToggle={() => toggleLayer(key)}
                        />
                      ))}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* ── Legend ─────────────────────────────────────────────── */}
          <div className="shrink-0 border-t border-[#36384a] p-3">
            <p className="mb-2 text-[9px] font-bold uppercase tracking-widest text-[#a7b1c1]/60">
              Legend
            </p>
            <div className="space-y-1.5">
              {LEGEND_ITEMS.map((item) => (
                <div key={item.label} className="flex items-center gap-2">
                  {item.shape === "circle" && (
                    <span
                      className="h-2.5 w-2.5 shrink-0 rounded-full"
                      style={{ background: item.color }}
                    />
                  )}
                  {item.shape === "square" && (
                    <span
                      className="h-2 w-2 shrink-0 rounded-[2px]"
                      style={{ background: item.color }}
                    />
                  )}
                  {item.shape === "line" && (
                    <span
                      className="h-0.5 w-4 shrink-0 rounded-full"
                      style={{ background: item.color }}
                    />
                  )}
                  <span className="text-[10px] text-[#a7b1c1]">{item.label}</span>
                </div>
              ))}
            </div>
            <p className="mt-3 text-[9px] text-[#a7b1c1]/50">
              
            </p>
          </div>
        </>
      )}
    </aside>
  );
}

/* ── Reusable row ─────────────────────────────────────────────────────────── */
function LayerRow({
  layerKey,
  checked,
  onToggle,
}: {
  layerKey: LayerKey;
  checked: boolean;
  onToggle: () => void;
}) {
  const cfg = LAYER_CONFIG[layerKey];

  return (
    <label
      className={`flex cursor-pointer items-center gap-2 rounded-lg px-2 py-1.5 text-xs transition-colors ${
        checked ? "bg-[#272937] text-white" : "text-[#a7b1c1] hover:bg-[#272937]/60 hover:text-white"
      }`}
    >
      {/* Custom checkbox */}
      <span
        onClick={onToggle}
        className={`relative flex h-4 w-4 shrink-0 items-center justify-center rounded border transition-colors ${
          checked
            ? "border-[#42a5f5] bg-[#42a5f5]"
            : "border-[#36384a] bg-transparent"
        }`}
      >
        {checked && (
          <svg width="8" height="8" viewBox="0 0 8 8" fill="none">
            <path d="M1.5 4L3.5 6L6.5 2" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
          </svg>
        )}
      </span>

      <span className="text-sm leading-none">{cfg.icon}</span>
      <span className="min-w-0 flex-1 truncate text-[11px] font-medium uppercase tracking-wide">
        {cfg.label}
      </span>

      {/* Color swatch / status indicator */}
      <span
        className={`h-2 w-2 shrink-0 rounded-full transition-opacity ${checked ? "opacity-100" : "opacity-30"}`}
        style={{ background: cfg.color }}
      />
    </label>
  );
}
