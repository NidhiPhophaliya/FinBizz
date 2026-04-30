"use client";

import DeckGL from "@deck.gl/react";
import { ArcLayer, ScatterplotLayer } from "@deck.gl/layers";
import { TripsLayer } from "@deck.gl/geo-layers";
import MapLibreMap from "react-map-gl/maplibre";
import { useEffect, useMemo, useRef, useState, useCallback } from "react";
import useSWR from "swr";
import EntityDetailPanel from "@/components/map/EntityDetailPanel";
import MapTooltip from "@/components/map/MapTooltip";
import GlobeView from "@/components/map/GlobeView";
import {
  LAYER_CONFIG,
  TRADE_ROUTES,
  CHOKEPOINTS,
  routeEntities,
  type LayerKey,
  type MapEntity,
} from "@/data/mapLayers";
import { financialCenters, otherMapEntities, stockExchanges } from "@/data/stockExchanges";
import { useDashboardStore } from "@/store/dashboardStore";
import type { FinanceMonitorSnapshot, FinanceQuote } from "@/types/financeMonitor";

// ─── Constants ─────────────────────────────────────────────────────────────
const INITIAL_VIEW_STATE = {
  longitude: 18,
  latitude: 22,
  zoom: 1.35,
  pitch: 35,
  bearing: 0,
};
const MAP_STYLE = "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json";
const ANIMATION_SPEED = 0.4;
const TRAIL_LENGTH = 180;
const LOOP_LENGTH = 1800;

const STATUS_COLORS: Record<string, [number, number, number, number]> = {
  active:    [0, 212, 255, 200],
  high_risk: [255, 180, 0,   210],
  disrupted: [255, 50,  50,  220],
};

const CATEGORY_COLORS: Record<string, [number, number, number, number]> = {
  container: [0,   212, 255, 200],
  energy:    [255, 140, 0,   200],
  data:      [0,   200, 120, 200],
  commodity: [180, 100, 255, 200],
};

const EXCHANGE_QUOTE_SYMBOLS: Record<string, string> = {
  nyse: "SPY", nasdaq: "QQQ", lse: "EWU", jpx: "EWJ",
  tse: "EWJ", nse: "INDA", bse: "INDA", sse: "MCHI",
  szse: "MCHI", hkex: "EWH", tsx: "EWC", asx: "EWA",
  b3: "EWZ", krx: "EWY", twse: "EWT", six: "EWL", tadawul: "TASI",
};

// ─── Trip datum type ────────────────────────────────────────────────────────
interface TripDatum {
  path: [number, number][];
  timestamps: number[];
  color: [number, number, number, number];
  width: number;
}

// ─── Helpers ────────────────────────────────────────────────────────────────
function hexToRgba(hex: string, alpha = 210): [number, number, number, number] {
  const n = hex.replace("#", "");
  const v = parseInt(n, 16);
  return [(v >> 16) & 255, (v >> 8) & 255, v & 255, alpha];
}

async function fetchSnapshot(url: string): Promise<FinanceMonitorSnapshot> {
  const res = await fetch(url);
  if (!res.ok) throw new Error("Unable to load finance monitor");
  return res.json() as Promise<FinanceMonitorSnapshot>;
}

function buildQuoteMap(snapshot?: FinanceMonitorSnapshot) {
  const map = new Map<string, FinanceQuote>();
  for (const q of [
    ...(snapshot?.marketQuotes ?? []),
    ...(snapshot?.commodityQuotes ?? []),
    ...(snapshot?.cryptoQuotes ?? []),
    ...(snapshot?.gulfQuotes ?? []),
  ]) {
    map.set(q.symbol, q);
  }
  return map;
}

function buildTripData(routes: typeof TRADE_ROUTES): TripDatum[] {
  return routes.map((route) => {
    const wps = route.waypoints;
    const timestamps = wps.map((_, i) =>
      Math.round((i / Math.max(wps.length - 1, 1)) * LOOP_LENGTH),
    );
    const color: [number, number, number, number] =
      STATUS_COLORS[route.status] ?? CATEGORY_COLORS[route.category] ?? [0, 200, 255, 200];
    return { path: wps, timestamps, color, width: Math.max(1.5, (route.value ?? 5) * 0.4) };
  });
}

// ─── Component ──────────────────────────────────────────────────────────────
export default function FinanceMap() {
  const activeMapLayers = useDashboardStore((s) => s.activeMapLayers);
  const mapViewMode     = useDashboardStore((s) => s.mapViewMode);

  const { data: monitor } = useSWR("/api/finance-monitor", fetchSnapshot, {
    refreshInterval: 30_000,
  });

  const [tooltip, setTooltip] = useState<{ entity: MapEntity; x: number; y: number } | null>(null);
  const [selected, setSelected] = useState<MapEntity | null>(null);
  const [time, setTime] = useState(0);
  const animRef    = useRef<number | null>(null);
  const lastTimeRef = useRef<number>(Date.now());

  // ── Animation loop ────────────────────────────────────────────────────────
  const animate = useCallback(() => {
    const now   = Date.now();
    const delta = now - lastTimeRef.current;
    lastTimeRef.current = now;
    setTime((t) => (t + delta * ANIMATION_SPEED) % LOOP_LENGTH);
    animRef.current = requestAnimationFrame(animate);
  }, []);

  useEffect(() => {
    animRef.current = requestAnimationFrame(animate);
    return () => { if (animRef.current) cancelAnimationFrame(animRef.current); };
  }, [animate]);

  // ── Quote enrichment ──────────────────────────────────────────────────────
  const quoteMap = useMemo(() => buildQuoteMap(monitor), [monitor]);

  const pointEntities = useMemo(
    () =>
      [...stockExchanges, ...financialCenters, ...otherMapEntities].map((entity) => {
        const symbol = EXCHANGE_QUOTE_SYMBOLS[entity.id];
        const quote  = symbol ? quoteMap.get(symbol) : undefined;
        if (!quote) return entity;
        return {
          ...entity,
          value:  quote.price  ?? entity.value,
          change: quote.change ?? entity.change,
          extra: {
            ...entity.extra,
            liveSymbol:  quote.symbol,
            liveDisplay: quote.display,
            liveSource:  monitor?.source,
            updatedAt:   monitor?.updatedAt,
          },
        };
      }),
    [monitor?.source, monitor?.updatedAt, quoteMap],
  );

  const tripData = useMemo(() => buildTripData(TRADE_ROUTES), []);

  // ── Layer building ────────────────────────────────────────────────────────
  const layers = useMemo(() => {
    const out = [];

    /* ── Scatter points ── */
    const pointKeys = (Object.keys(LAYER_CONFIG) as LayerKey[]).filter(
      (k) => LAYER_CONFIG[k].markerType !== "line" && activeMapLayers.includes(k),
    );
    for (const key of pointKeys) {
      const data: MapEntity[] =
        key === "chokepoints"
          ? CHOKEPOINTS
          : pointEntities.filter((e) => e.layer === key);
      if (!data.length) continue;

      out.push(
        new ScatterplotLayer<MapEntity>({
          id: `scatter-${key}`,
          data,
          pickable: true,
          stroked: true,
          filled: true,
          radiusUnits: "meters",
          getPosition: (e: MapEntity) => [e.lng, e.lat] as [number, number],
          getRadius: (e: MapEntity) =>
            key === "chokepoints"
              ? Math.max(80_000, (e.value ?? 5) * 20_000)
              : Math.max(45_000, Math.sqrt(e.value ?? 1) * 12_000),
          getFillColor: (e: MapEntity): [number, number, number, number] => {
            if (key === "chokepoints") return [255, 77, 77, 200];
            if (key === "stock-exchanges" && typeof e.change === "number")
              return e.change >= 0 ? [100, 255, 150, 220] : [255, 80, 80, 220];
            return hexToRgba(LAYER_CONFIG[key].color);
          },
          getLineColor: [255, 255, 255, 140] as [number, number, number, number],
          lineWidthMinPixels: 1,
          onHover: (info) => {
            if (info.object) setTooltip({ entity: info.object, x: info.x, y: info.y });
            else setTooltip(null);
          },
          onClick: (info) => { if (info.object) setSelected(info.object); },
          updateTriggers: { getFillColor: [monitor?.updatedAt], getRadius: [monitor?.updatedAt] },
        }),
      );
    }

    /* ── Animated trade-route trips ── */
    if (activeMapLayers.includes("trade-routes")) {
      const containerTrips = tripData.filter(
        (_, i) => TRADE_ROUTES[i]?.category === "container" || TRADE_ROUTES[i]?.category === "commodity",
      );
      out.push(
        new TripsLayer<TripDatum>({
          id: "trips-trade",
          data: containerTrips,
          getPath: (d: TripDatum) => d.path,
          getTimestamps: (d: TripDatum) => d.timestamps,
          getColor: (d: TripDatum) => d.color,
          opacity: 0.85,
          widthMinPixels: 1.5,
          widthMaxPixels: 5,
          getWidth: (d: TripDatum) => d.width,
          jointRounded: true,
          capRounded: true,
          trailLength: TRAIL_LENGTH,
          currentTime: time,
        }),
      );

      // Faint background arc
      out.push(
        new ArcLayer({
          id: "arcs-trade-bg",
          data: routeEntities.filter(
            (e) => e.layer === "trade-routes",
          ),
          pickable: false,
          getSourcePosition: (e) => e.source,
          getTargetPosition: (e) => e.target,
          getSourceColor: [0, 180, 220, 20] as [number, number, number, number],
          getTargetColor:  [0, 180, 220, 20] as [number, number, number, number],
          getWidth: 0.5,
        }),
      );
    }

    /* ── Animated energy trips ── */
    if (activeMapLayers.includes("pipelines")) {
      const energyTrips = tripData.filter((_, i) => TRADE_ROUTES[i]?.category === "energy");
      out.push(
        new TripsLayer<TripDatum>({
          id: "trips-energy",
          data: energyTrips,
          getPath: (d: TripDatum) => d.path,
          getTimestamps: (d: TripDatum) => d.timestamps,
          getColor: (d: TripDatum) => d.color,
          opacity: 0.8,
          widthMinPixels: 1.5,
          widthMaxPixels: 4,
          getWidth: (d: TripDatum) => d.width,
          jointRounded: true,
          capRounded: true,
          trailLength: TRAIL_LENGTH,
          currentTime: time,
        }),
      );
    }

    /* ── Animated data-cable trips ── */
    if (activeMapLayers.includes("undersea-cables")) {
      const dataTrips = tripData.filter((_, i) => TRADE_ROUTES[i]?.category === "data");
      out.push(
        new TripsLayer<TripDatum>({
          id: "trips-data",
          data: dataTrips,
          getPath: (d: TripDatum) => d.path,
          getTimestamps: (d: TripDatum) => d.timestamps,
          getColor: (d: TripDatum) => d.color,
          opacity: 0.75,
          widthMinPixels: 1,
          widthMaxPixels: 3,
          getWidth: (d: TripDatum) => d.width,
          jointRounded: true,
          capRounded: true,
          trailLength: TRAIL_LENGTH,
          currentTime: time,
        }),
      );

      out.push(
        new ArcLayer({
          id: "arcs-cables-bg",
          data: routeEntities.filter((e) => e.layer === "undersea-cables"),
          pickable: false,
          getSourcePosition: (e) => e.source,
          getTargetPosition: (e) => e.target,
          getSourceColor: [0, 200, 120, 15] as [number, number, number, number],
          getTargetColor:  [0, 200, 120, 15] as [number, number, number, number],
          getWidth: 0.4,
        }),
      );
    }

    return out;
  }, [activeMapLayers, pointEntities, time, tripData, monitor?.updatedAt]);

  // ── 3D globe ──────────────────────────────────────────────────────────────
  if (mapViewMode === "3d") {
    return (
      <div className="absolute inset-0">
        <GlobeView
          activeMapLayers={activeMapLayers}
          pointEntities={pointEntities}
          tripData={tripData}
          time={time}
          onEntityClick={setSelected}
        />
        <EntityDetailPanel entity={selected} onClose={() => setSelected(null)} />
      </div>
    );
  }

  // ── 2D map ────────────────────────────────────────────────────────────────
  return (
    <div className="absolute inset-0">
      <DeckGL
        controller
        initialViewState={INITIAL_VIEW_STATE}
        layers={layers}
        getCursor={({ isHovering }) => (isHovering ? "pointer" : "grab")}
      >
        <MapLibreMap mapStyle={MAP_STYLE} reuseMaps />
      </DeckGL>
      {tooltip && <MapTooltip entity={tooltip.entity} x={tooltip.x} y={tooltip.y} />}
      <EntityDetailPanel entity={selected} onClose={() => setSelected(null)} />
    </div>
  );
}
