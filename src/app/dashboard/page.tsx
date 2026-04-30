"use client";

import { useEffect } from "react";
import FinanceMap from "@/components/map/FinanceMap";
import LayersPanel from "@/components/map/LayersPanel";
import MapFilters from "@/components/map/MapFilters";
import { ErrorBoundary } from "@/components/ui/ErrorBoundary";

export default function DashboardPage() {
  useEffect(() => {
    void fetch("/api/user/streak", { method: "POST" });
  }, []);

  return (
    <div className="relative h-full w-full">
      {/* Full-bleed map */}
      <ErrorBoundary label="Finance map">
        <FinanceMap />
      </ErrorBoundary>

      {/* Left layers panel — absolute over map */}
      <LayersPanel />

      {/* Optional filter chips (time range, view) */}
      <MapFilters />
    </div>
  );
}
