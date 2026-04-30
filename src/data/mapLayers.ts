export type LayerKey =
  | "stock-exchanges"
  | "financial-centers"
  | "central-banks"
  | "commodity-hubs"
  | "gcc-investments"
  | "trade-routes"
  | "undersea-cables"
  | "pipelines"
  | "chokepoints"
  | "natural-events"
  | "internet-disruptions"
  | "weather-alerts";

export interface MapEntity {
  id: string;
  name: string;
  lat: number;
  lng: number;
  layer: LayerKey;
  country?: string;
  value?: number;
  change?: number;
  currency?: string;
  description?: string;
  extra?: Record<string, unknown>;
}

export interface RouteEntity {
  id: string;
  name: string;
  layer: LayerKey;
  source: [number, number];
  target: [number, number];
  value?: number;
  category?: "energy" | "container" | "data" | "commodity";
  status?: "active" | "disrupted" | "high_risk";
  waypoints?: [number, number][];
}

export const LAYER_CONFIG: Record<
  LayerKey,
  {
    label: string;
    icon: string;
    color: string;
    markerType: "circle" | "square" | "triangle" | "line";
    description: string;
  }
> = {
  "stock-exchanges": {
    label: "Stock Exchanges",
    icon: "📈",
    color: "#ffd780",
    markerType: "circle",
    description: "92 global stock exchanges by market cap",
  },
  "financial-centers": {
    label: "Financial Centers",
    icon: "🏦",
    color: "#42a5f5",
    markerType: "circle",
    description: "Top financial hubs by GFCI ranking",
  },
  "central-banks": {
    label: "Central Banks",
    icon: "🏛",
    color: "#ffffff",
    markerType: "square",
    description: "Central banks and monetary authorities",
  },
  "commodity-hubs": {
    label: "Commodity Hubs",
    icon: "⚡",
    color: "#7ee4e3",
    markerType: "triangle",
    description: "Major commodity trading and production centers",
  },
  "gcc-investments": {
    label: "GCC Investments",
    icon: "💰",
    color: "#ffd780",
    markerType: "circle",
    description: "Gulf sovereign wealth fund investment destinations",
  },
  "trade-routes": {
    label: "Trade Routes",
    icon: "🚢",
    color: "#00d4ff",
    markerType: "line",
    description: "Major maritime trade routes — animated",
  },
  "undersea-cables": {
    label: "Undersea Cables",
    icon: "📡",
    color: "#00c8ff",
    markerType: "line",
    description: "Global undersea internet cable network",
  },
  pipelines: {
    label: "Pipelines",
    icon: "🛢",
    color: "#ff8c42",
    markerType: "line",
    description: "Major oil and gas pipeline routes",
  },
  chokepoints: {
    label: "Chokepoints",
    icon: "⚓",
    color: "#ff4d4d",
    markerType: "circle",
    description: "Critical maritime chokepoints",
  },
  "natural-events": {
    label: "Natural Events",
    icon: "🌋",
    color: "#ff6b35",
    markerType: "circle",
    description: "Earthquakes, storms, volcanic activity",
  },
  "internet-disruptions": {
    label: "Internet Disruptions",
    icon: "🔴",
    color: "#ff2d55",
    markerType: "circle",
    description: "Active internet outages and disruptions",
  },
  "weather-alerts": {
    label: "Weather Alerts",
    icon: "🌩",
    color: "#ffd60a",
    markerType: "circle",
    description: "Severe weather warnings",
  },
};

// ─── Animated Trade Route Arcs ────────────────────────────────────────────────
// These are used with deck.gl TripsLayer for moving particles
export interface TradeRoute {
  id: string;
  name: string;
  category: "energy" | "container" | "data" | "commodity";
  status: "active" | "disrupted" | "high_risk";
  volumeDesc: string;
  // Array of [lng, lat] waypoints
  waypoints: [number, number][];
  value?: number;
}

export const TRADE_ROUTES: TradeRoute[] = [
  // ── Container routes ──────────────────────────────────────────────────────
  {
    id: "trans-pacific-eastbound",
    name: "Trans-Pacific (Asia→US West)",
    category: "container",
    status: "active",
    volumeDesc: "~$1.4T / yr",
    waypoints: [
      [121.47, 31.23],   // Shanghai
      [126.92, 35.1],    // Korea
      [139.69, 35.68],   // Tokyo
      [170, 30],          // Mid-Pacific
      [-150, 22],
      [-118.25, 33.74],  // LA
    ],
    value: 18,
  },
  {
    id: "trans-atlantic",
    name: "Trans-Atlantic (US→Europe)",
    category: "container",
    status: "active",
    volumeDesc: "~$800B / yr",
    waypoints: [
      [-74.0, 40.71],    // New York
      [-40, 42],
      [-20, 45],
      [-9.14, 38.71],    // Lisbon
      [-0.12, 51.5],     // London
      [4.9, 52.37],      // Amsterdam
    ],
    value: 14,
  },
  {
    id: "suez-asia-europe",
    name: "Asia–Europe via Suez",
    category: "container",
    status: "high_risk",
    volumeDesc: "~$1.0T / yr",
    waypoints: [
      [103.82, 1.35],    // Singapore
      [80.27, 13.08],    // Sri Lanka
      [57.0, 20.0],      // Arabian Sea
      [43.61, 11.59],    // Gulf of Aden
      [32.55, 29.97],    // Suez Canal
      [32.3, 32.3],      // Med entry
      [14.5, 37.5],      // Med
      [2.35, 48.85],     // France
      [-0.12, 51.5],     // London
    ],
    value: 20,
  },
  {
    id: "cape-of-good-hope",
    name: "Cape of Good Hope Route",
    category: "container",
    status: "active",
    volumeDesc: "Suez Alternative",
    waypoints: [
      [103.82, 1.35],    // Singapore
      [73.0, -5.0],      // Indian Ocean
      [45.0, -25.0],
      [18.42, -33.92],   // Cape Town
      [-10.0, -30.0],
      [-10.0, 10.0],
      [-0.12, 51.5],     // London
    ],
    value: 8,
  },
  {
    id: "intra-asia",
    name: "Intra-Asia Trade",
    category: "container",
    status: "active",
    volumeDesc: "~$600B / yr",
    waypoints: [
      [121.47, 31.23],   // Shanghai
      [114.17, 22.32],   // HK
      [103.82, 1.35],    // Singapore
      [106.69, 10.82],   // Ho Chi Minh
      [100.52, 13.76],   // Bangkok
      [95.37, 5.42],     // Malacca
    ],
    value: 10,
  },
  {
    id: "us-gulf-latam",
    name: "US Gulf–Latin America",
    category: "container",
    status: "active",
    volumeDesc: "~$300B / yr",
    waypoints: [
      [-90.07, 29.95],   // New Orleans
      [-80.0, 23.0],     // Caribbean
      [-66.1, 10.48],    // Venezuela
      [-43.17, -22.9],   // Rio
      [-46.63, -23.54],  // São Paulo
    ],
    value: 6,
  },
  {
    id: "europe-west-africa",
    name: "Europe–West Africa",
    category: "container",
    status: "active",
    volumeDesc: "~$180B / yr",
    waypoints: [
      [-0.12, 51.5],     // London
      [-9.14, 38.71],    // Lisbon
      [-17.44, 14.69],   // Dakar
      [-15.0, 10.0],
      [3.38, 6.45],      // Lagos
      [9.7, 4.06],       // Douala
    ],
    value: 4,
  },
  {
    id: "middle-east-india",
    name: "Middle East–India Corridor",
    category: "container",
    status: "active",
    volumeDesc: "~$250B / yr",
    waypoints: [
      [55.27, 25.2],     // Dubai
      [57.65, 23.6],     // Muscat
      [66.98, 24.86],    // Karachi
      [72.87, 19.08],    // Mumbai
      [80.27, 13.08],    // Chennai
    ],
    value: 7,
  },

  // ── Energy routes ──────────────────────────────────────────────────────────
  {
    id: "persian-gulf-east",
    name: "Persian Gulf → East Asia (Oil)",
    category: "energy",
    status: "active",
    volumeDesc: "~17M bbl/day",
    waypoints: [
      [50.6, 26.23],     // Bahrain / Strait of Hormuz
      [56.27, 23.6],     // Gulf of Oman
      [62.0, 20.0],      // Arabian Sea
      [72.0, 10.0],
      [80.0, 5.0],
      [103.82, 1.35],    // Malacca Strait
      [114.17, 22.32],   // HK
      [121.47, 31.23],   // Shanghai
      [126.92, 35.1],    // Korea
      [139.69, 35.68],   // Japan
    ],
    value: 17,
  },
  {
    id: "russia-europe-oil",
    name: "Russia → Europe (Oil/Gas)",
    category: "energy",
    status: "disrupted",
    volumeDesc: "Disrupted post-2022",
    waypoints: [
      [37.62, 55.75],    // Moscow
      [30.52, 50.45],    // Kyiv
      [16.37, 48.21],    // Vienna
      [2.35, 48.85],     // Paris
      [-0.12, 51.5],     // London
    ],
    value: 3,
  },
  {
    id: "north-sea-norway",
    name: "North Sea Energy Corridor",
    category: "energy",
    status: "active",
    volumeDesc: "~3M bbl/day",
    waypoints: [
      [10.75, 59.91],    // Oslo
      [5.32, 60.39],     // Bergen
      [2.0, 57.0],       // North Sea
      [-2.0, 56.0],
      [-0.12, 51.5],     // London
    ],
    value: 5,
  },
  {
    id: "us-lng-europe",
    name: "US LNG → Europe",
    category: "energy",
    status: "active",
    volumeDesc: "~15 bcf/day",
    waypoints: [
      [-93.75, 29.65],   // Sabine Pass LNG
      [-70.0, 35.0],
      [-40.0, 38.0],
      [-10.0, 45.0],
      [-8.64, 41.15],    // Porto LNG
      [2.35, 48.85],     // France
    ],
    value: 9,
  },

  // ── Data cables (rendered as arcs too) ────────────────────────────────────
  {
    id: "ny-london-cable",
    name: "NY–London Transatlantic",
    category: "data",
    status: "active",
    volumeDesc: "~430 Tbps",
    waypoints: [
      [-74.0, 40.71],
      [-40.0, 50.0],
      [-15.0, 52.0],
      [-0.12, 51.5],
    ],
    value: 9,
  },
  {
    id: "pacific-submarine-cable",
    name: "Trans-Pacific Cable System",
    category: "data",
    status: "active",
    volumeDesc: "~200 Tbps",
    waypoints: [
      [-74.0, 40.71],
      [-118.25, 33.74],
      [-150.0, 22.0],
      [170.0, 30.0],
      [139.69, 35.68],
      [121.47, 31.23],
    ],
    value: 7,
  },
  {
    id: "sea-me-we-5",
    name: "SEA-ME-WE-5 Cable",
    category: "data",
    status: "active",
    volumeDesc: "~24 Tbps",
    waypoints: [
      [103.82, 1.35],
      [80.27, 13.08],
      [57.0, 20.0],
      [32.55, 29.97],
      [25.0, 36.0],
      [14.5, 40.0],
      [2.35, 48.85],
    ],
    value: 5,
  },
  {
    id: "africa-1-cable",
    name: "Africa-1 Submarine Cable",
    category: "data",
    status: "active",
    volumeDesc: "~60 Tbps",
    waypoints: [
      [-0.12, 51.5],
      [-9.14, 38.71],
      [-17.44, 14.69],
      [3.38, 6.45],
      [18.42, -33.92],
      [36.82, -1.29],
      [55.27, 25.2],
      [57.0, 20.0],
      [80.27, 13.08],
    ],
    value: 4,
  },
];

// ─── Point Entities (Chokepoints) ─────────────────────────────────────────────
export const CHOKEPOINTS: MapEntity[] = [
  {
    id: "strait-of-hormuz",
    name: "Strait of Hormuz",
    lat: 26.56,
    lng: 56.27,
    layer: "chokepoints",
    country: "Oman / Iran",
    description: "~20% of global oil supply passes through here",
    value: 21,
  },
  {
    id: "strait-of-malacca",
    name: "Strait of Malacca",
    lat: 1.26,
    lng: 103.84,
    layer: "chokepoints",
    country: "Malaysia / Singapore / Indonesia",
    description: "~80% of China's oil imports pass through here",
    value: 16,
  },
  {
    id: "suez-canal",
    name: "Suez Canal",
    lat: 30.46,
    lng: 32.34,
    layer: "chokepoints",
    country: "Egypt",
    description: "12% of global trade, 30% of container traffic",
    value: 14,
  },
  {
    id: "bab-el-mandeb",
    name: "Bab-el-Mandeb",
    lat: 12.58,
    lng: 43.37,
    layer: "chokepoints",
    country: "Djibouti / Yemen",
    description: "Gateway between Red Sea and Gulf of Aden — high risk",
    value: 12,
  },
  {
    id: "panama-canal",
    name: "Panama Canal",
    lat: 9.08,
    lng: -79.68,
    layer: "chokepoints",
    country: "Panama",
    description: "5% of global trade, linking Atlantic and Pacific",
    value: 8,
  },
  {
    id: "danish-straits",
    name: "Danish Straits",
    lat: 55.82,
    lng: 12.59,
    layer: "chokepoints",
    country: "Denmark",
    description: "Gateway to Baltic Sea — key for Russia energy exports",
    value: 5,
  },
  {
    id: "turkish-straits",
    name: "Turkish Straits (Bosphorus)",
    lat: 41.12,
    lng: 29.07,
    layer: "chokepoints",
    country: "Turkey",
    description: "Gateway between Black Sea and Mediterranean",
    value: 6,
  },
  {
    id: "cape-of-good-hope-cp",
    name: "Cape of Good Hope",
    lat: -34.36,
    lng: 18.47,
    layer: "chokepoints",
    country: "South Africa",
    description: "Alternative to Suez for very large vessels",
    value: 4,
  },
];

// Build simple arc RouteEntities from TRADE_ROUTES for the Arc layer
export const routeEntities: RouteEntity[] = TRADE_ROUTES.map((r) => {
  const wps = r.waypoints;
  return {
    id: r.id,
    name: r.name,
    layer:
      r.category === "data"
        ? ("undersea-cables" as LayerKey)
        : r.category === "energy"
        ? ("pipelines" as LayerKey)
        : ("trade-routes" as LayerKey),
    source: wps[0],
    target: wps[wps.length - 1],
    value: r.value,
    category: r.category,
    status: r.status,
    waypoints: wps,
  };
});
