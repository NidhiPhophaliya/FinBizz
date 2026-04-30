"use client";

import { ArrowDownRight, ArrowUpRight, X } from "lucide-react";
import { Button } from "@/components/ui/Button";
import type { MapEntity } from "@/data/mapLayers";
import { useDashboardStore } from "@/store/dashboardStore";

export default function EntityDetailPanel({
  entity,
  onClose,
}: {
  entity: MapEntity | null;
  onClose: () => void;
}) {
  const setAIChatOpen = useDashboardStore((state) => state.setAIChatOpen);

  if (!entity) {
    return null;
  }

  const positive = (entity.change ?? 0) >= 0;
  const ChangeIcon = positive ? ArrowUpRight : ArrowDownRight;
  const liveDisplay =
    typeof entity.extra?.liveDisplay === "string" ? entity.extra.liveDisplay : undefined;
  const updatedAt =
    typeof entity.extra?.updatedAt === "string"
      ? new Date(entity.extra.updatedAt).toLocaleTimeString()
      : undefined;

  return (
    <aside className="absolute right-4 top-4 z-40 w-[320px] rounded-lg border border-accent-border bg-bg-secondary shadow-2xl">
      <header className="flex items-start justify-between border-b border-accent-border p-4">
        <div>
          <h2 className="text-xl font-bold text-white">{entity.name}</h2>
          <p className="mt-1 text-sm text-text-muted">{entity.country}</p>
        </div>
        <button
          className="rounded-md p-1 text-text-muted hover:bg-bg-tertiary hover:text-white"
          onClick={onClose}
          aria-label="Close entity detail"
        >
          <X size={18} />
        </button>
      </header>
      <div className="space-y-4 p-4">
        <div>
          <div className="text-xs uppercase text-text-muted">Current value</div>
          <div className="font-mono text-2xl font-bold text-accent-green">
            {entity.currency ?? "USD"} {entity.value?.toLocaleString() ?? "N/A"}
          </div>
          {liveDisplay ? (
            <div className="mt-1 text-xs text-accent-teal">
              Live proxy: {liveDisplay}
              {updatedAt ? ` · ${updatedAt}` : ""}
            </div>
          ) : null}
        </div>
        <div className={positive ? "flex items-center gap-2 text-accent-green" : "flex items-center gap-2 text-red-400"}>
          <ChangeIcon size={18} />
          <span className="font-mono font-bold">
            {positive ? "+" : ""}
            {(entity.change ?? 0).toFixed(2)}%
          </span>
        </div>
        <p className="text-sm leading-6 text-text-muted">
          {entity.description ??
            "A major node in the global financial system. Use it as a learning anchor for markets, capital flows, and regional risk."}
        </p>
        <Button
          className="w-full"
          onClick={() => {
            setAIChatOpen(true);
            onClose();
          }}
        >
          Learn More
        </Button>
      </div>
    </aside>
  );
}
