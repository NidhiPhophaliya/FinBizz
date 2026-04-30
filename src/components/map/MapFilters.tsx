"use client";

// MapFilters — small bottom-right info bar showing live status + attribution
// This is intentionally minimal; the main controls live in TopNavBar
export default function MapFilters() {
  return (
    <div className="pointer-events-none absolute bottom-6 left-1/2 z-20 -translate-x-1/2">
      {/* Bottom legend ribbon, WorldMonitor style */}
      <div className="flex items-center gap-3 rounded-full border border-[#36384a] bg-[#0f111a]/90 px-4 py-2 backdrop-blur-sm">
        <LegendDot color="#ffd780" label="Stock Exchange" />
        <LegendDot color="#42a5f5" label="Financial Center" />
        <LegendDot color="#ffffff" label="Central Bank" shape="square" />
        <LegendLine color="#00d4ff" label="Waterway" />
      </div>
    </div>
  );
}

function LegendDot({
  color,
  label,
  shape = "circle",
}: {
  color: string;
  label: string;
  shape?: "circle" | "square";
}) {
  return (
    <div className="flex items-center gap-1.5">
      <span
        className={shape === "circle" ? "h-2.5 w-2.5 rounded-full" : "h-2 w-2 rounded-sm"}
        style={{ background: color }}
      />
      <span className="text-[10px] font-medium text-[#a7b1c1]">{label}</span>
    </div>
  );
}

function LegendLine({ color, label }: { color: string; label: string }) {
  return (
    <div className="flex items-center gap-1.5">
      <span className="h-0.5 w-4 rounded-full" style={{ background: color }} />
      <span className="text-[10px] font-medium text-[#a7b1c1]">{label}</span>
    </div>
  );
}
