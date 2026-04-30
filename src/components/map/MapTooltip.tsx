"use client";

import type { MapEntity } from "@/data/mapLayers";
import { LAYER_CONFIG } from "@/data/mapLayers";

interface Props {
  entity: MapEntity;
  x: number;
  y: number;
}

function fmt(n: number | null | undefined, decimals = 2) {
  if (n == null) return "—";
  return n.toLocaleString("en-US", { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
}

function fmtChange(n: number | null | undefined) {
  if (n == null) return null;
  const sign = n >= 0 ? "+" : "";
  return `${sign}${n.toFixed(2)}%`;
}

export default function MapTooltip({ entity, x, y }: Props) {
  const cfg = LAYER_CONFIG[entity.layer];
  const changeStr = fmtChange(entity.change);
  const isPositive = (entity.change ?? 0) >= 0;

  // Keep tooltip in viewport
  const left = x + 14;
  const top = y - 10;

  return (
    <div
      className="pointer-events-none absolute z-50"
      style={{ left, top, maxWidth: 240 }}
    >
      <div className="rounded-xl border border-[#36384a] bg-[#1a1c26]/95 p-3 shadow-2xl backdrop-blur-sm">
        {/* Header */}
        <div className="mb-1.5 flex items-center gap-2">
          <span className="text-base leading-none">{cfg.icon}</span>
          <span
            className="h-2 w-2 shrink-0 rounded-full"
            style={{ background: cfg.color }}
          />
          <span className="text-[10px] font-bold uppercase tracking-widest text-[#a7b1c1]">
            {cfg.label}
          </span>
        </div>

        {/* Name */}
        <p className="mb-0.5 text-sm font-bold leading-tight text-white">{entity.name}</p>
        {entity.country && (
          <p className="mb-2 text-[11px] text-[#a7b1c1]">{entity.country}</p>
        )}

        {/* Value + change */}
        {entity.value != null && (
          <div className="flex items-baseline gap-2">
            <span className="font-mono text-sm font-bold text-white">
              {entity.layer === "stock-exchanges" ? `$${fmt(entity.value, 0)}B` : fmt(entity.value)}
            </span>
            {changeStr && (
              <span
                className={`text-[11px] font-bold ${isPositive ? "text-[#99ff88]" : "text-[#ff5050]"}`}
              >
                {changeStr}
              </span>
            )}
          </div>
        )}

        {/* Description */}
        {entity.description && (
          <p className="mt-1.5 text-[10px] leading-relaxed text-[#a7b1c1]">
            {entity.description}
          </p>
        )}

        {/* Live badge */}
        {entity.extra?.liveSymbol != null && (
          <div className="mt-2 flex items-center gap-1">
            <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-[#99ff88]" />
            <span className="text-[9px] font-bold uppercase text-[#99ff88]">
              LIVE · {String(entity.extra.liveSymbol as string)}
            </span>
          </div>
        )}
      </div>
    </div>
  );
}
