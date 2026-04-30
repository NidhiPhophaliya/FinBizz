"use client";

import { useEffect, useRef } from "react";
import type { MapEntity } from "@/data/mapLayers";
import { CHOKEPOINTS } from "@/data/mapLayers";

interface TripDatum {
  path: [number, number][];
  timestamps: number[];
  color: [number, number, number, number];
  width: number;
}

interface Props {
  activeMapLayers: string[];
  pointEntities: MapEntity[];
  tripData: TripDatum[];
  time: number;
  onEntityClick: (e: MapEntity) => void;
}

export default function GlobeView({ activeMapLayers, pointEntities, tripData, onEntityClick }: Props) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;
    const container = containerRef.current;
    let destroyed = false;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let globe: any = null;

    (async () => {
      const mod = await import("globe.gl");
      if (destroyed || !container) return;

      // globe.gl v2 exports a factory function: Globe()(element)
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const GlobeFactory = (mod.default ?? mod) as any;
      globe = GlobeFactory({ animateIn: true })(container);

      globe
        .globeImageUrl("//unpkg.com/three-globe/example/img/earth-dark.jpg")
        .backgroundImageUrl("//unpkg.com/three-globe/example/img/night-sky.png")
        .atmosphereColor("#4466cc")
        .atmosphereAltitude(0.18);

      // Controls
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const controls = globe.controls() as any;
      controls.autoRotate = true;
      controls.autoRotateSpeed = 0.35;
      controls.enableDamping = true;
      controls.minDistance = 101;
      controls.maxDistance = 600;

      const stopRotate = () => {
        controls.autoRotate = false;
        setTimeout(() => { if (!destroyed) controls.autoRotate = true; }, 30_000);
      };
      container.addEventListener("mousedown", stopRotate);
      container.addEventListener("touchstart", stopRotate, { passive: true });

      // ── Arcs (animated trade routes) ────────────────────────────────────
      const arcs = tripData.map((trip) => {
        const [r, g, b, a] = trip.color;
        const alpha = ((a) / 255).toFixed(2);
        const src = trip.path[0];
        const dst = trip.path[trip.path.length - 1];
        if (!src || !dst) return null;
        return {
          startLat: src[1],  startLng: src[0],
          endLat:   dst[1],  endLng:   dst[0],
          color: [
            `rgba(${r},${g},${b},0.04)`,
            `rgba(${r},${g},${b},${alpha})`,
            `rgba(${r},${g},${b},0.04)`,
          ],
          stroke: trip.width * 0.35,
        };
      }).filter(Boolean);

      globe
        .arcsData(arcs)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .arcStartLat((d: any) => d.startLat)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .arcStartLng((d: any) => d.startLng)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .arcEndLat((d: any) => d.endLat)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .arcEndLng((d: any) => d.endLng)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .arcColor((d: any) => d.color)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .arcStroke((d: any) => d.stroke)
        .arcDashLength(0.9)
        .arcDashGap(4)
        .arcDashAnimateTime(4000)
        .arcAltitudeAutoScale(0.3);

      // ── HTML markers ────────────────────────────────────────────────────
      const markers: Array<{
        lat: number; lng: number;
        _entity: MapEntity; _kind: string; color: string;
      }> = [];

      if (activeMapLayers.includes("stock-exchanges")) {
        pointEntities
          .filter((e) => e.layer === "stock-exchanges")
          .forEach((e) => {
            markers.push({
              lat: e.lat, lng: e.lng, _entity: e, _kind: "exchange",
              color: typeof e.change === "number" && e.change >= 0 ? "#64ff96" : "#ff5050",
            });
          });
      }
      if (activeMapLayers.includes("financial-centers")) {
        pointEntities
          .filter((e) => e.layer === "financial-centers")
          .forEach((e) => {
            markers.push({ lat: e.lat, lng: e.lng, _entity: e, _kind: "center", color: "#42a5f5" });
          });
      }
      if (activeMapLayers.includes("chokepoints")) {
        CHOKEPOINTS.forEach((e) => {
          markers.push({ lat: e.lat, lng: e.lng, _entity: e, _kind: "chokepoint", color: "#ff4d4d" });
        });
      }

      globe
        .htmlElementsData(markers)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .htmlLat((d: any) => d.lat)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .htmlLng((d: any) => d.lng)
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        .htmlElement((d: any) => {
          const el = document.createElement("div");
          const size = d._kind === "chokepoint" ? 14 : 9;
          const isDiamond = d._kind === "chokepoint";
          el.style.cssText = [
            `width:${size}px`, `height:${size}px`,
            `background:${d.color as string}`,
            "border:1.5px solid rgba(255,255,255,0.55)",
            `border-radius:${isDiamond ? "2px" : "50%"}`,
            `transform:${isDiamond ? "rotate(45deg)" : "none"}`,
            `box-shadow:0 0 8px ${d.color as string}80`,
            "cursor:pointer",
            "transition:transform 0.15s ease",
          ].join(";");
          el.title = d._entity?.name ?? "";
          el.addEventListener("click", () => { onEntityClick(d._entity as MapEntity); });
          el.addEventListener("mouseenter", () => {
            el.style.transform = `scale(1.9)${isDiamond ? " rotate(45deg)" : ""}`;
          });
          el.addEventListener("mouseleave", () => {
            el.style.transform = `scale(1)${isDiamond ? " rotate(45deg)" : ""}`;
          });
          return el;
        });

      // ── Chokepoint rings ────────────────────────────────────────────────
      if (activeMapLayers.includes("chokepoints")) {
        globe
          .ringsData(CHOKEPOINTS.map((c) => ({
            lat: c.lat, lng: c.lng, maxR: 5, propagationSpeed: 1, repeatPeriod: 900,
          })))
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          .ringLat((d: any) => d.lat)
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          .ringLng((d: any) => d.lng)
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          .ringMaxRadius((d: any) => d.maxR)
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          .ringPropagationSpeed((d: any) => d.propagationSpeed)
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          .ringRepeatPeriod((d: any) => d.repeatPeriod)
          .ringColor(() => (t: number) => `rgba(255,77,77,${1 - t})`);
      }
    })();

    return () => {
      destroyed = true;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      (globe as any)?._destructor?.();
      globe = null;
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return <div ref={containerRef} className="absolute inset-0 bg-black" />;
}
