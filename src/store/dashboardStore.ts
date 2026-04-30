import { create } from "zustand";

export type MapScope = "global" | "asia" | "europe" | "americas" | "watchlist";
export type MapViewMode = "2d" | "3d";
export type TimeRange = "1h" | "6h" | "24h" | "48h" | "7d" | "all";

interface DashboardStore {
  activeMapLayers: string[];
  toggleLayer: (layer: string) => void;
  setActiveLayers: (layers: string[]) => void;
  mapScope: MapScope;
  setMapScope: (scope: MapScope) => void;
  mapViewMode: MapViewMode;
  setMapViewMode: (mode: MapViewMode) => void;
  timeRange: TimeRange;
  setTimeRange: (range: TimeRange) => void;
  isGamesHubOpen: boolean;
  isAIChatOpen: boolean;
  setGamesHubOpen: (open: boolean) => void;
  setAIChatOpen: (open: boolean) => void;
  userXP: number;
  userLevel: number;
  setUserXP: (xp: number, level: number) => void;
}

export const useDashboardStore = create<DashboardStore>((set) => ({
  activeMapLayers: [
    "stock-exchanges",
    "financial-centers",
    "trade-routes",
    "undersea-cables",
    "chokepoints",
    "pipelines",
  ],
  toggleLayer: (layer) =>
    set((state) => ({
      activeMapLayers: state.activeMapLayers.includes(layer)
        ? state.activeMapLayers.filter((item) => item !== layer)
        : [...state.activeMapLayers, layer],
    })),
  setActiveLayers: (layers) => set({ activeMapLayers: layers }),
  mapScope: "global",
  setMapScope: (scope) => set({ mapScope: scope }),
  mapViewMode: "2d",
  setMapViewMode: (mode) => set({ mapViewMode: mode }),
  timeRange: "7d",
  setTimeRange: (range) => set({ timeRange: range }),
  isGamesHubOpen: false,
  isAIChatOpen: false,
  setGamesHubOpen: (open) => set({ isGamesHubOpen: open }),
  setAIChatOpen: (open) => set({ isAIChatOpen: open }),
  userXP: 0,
  userLevel: 1,
  setUserXP: (xp, level) => set({ userXP: xp, userLevel: level }),
}));
