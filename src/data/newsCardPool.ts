export type Sector = "Tech" | "Energy" | "Finance" | "Healthcare" | "Consumer";

export interface MarketNewsCard {
  id: string;
  headline: string;
  sectors: Sector[];
  effect: Partial<Record<Sector, number>>;
}

const baseCards: MarketNewsCard[] = [
  { id: "n1", headline: "Fed raises rates by 0.25%", sectors: ["Finance", "Consumer"], effect: { Finance: 0.03, Consumer: -0.03 } },
  { id: "n2", headline: "Oil supply cut by OPEC", sectors: ["Energy"], effect: { Energy: 0.08 } },
  { id: "n3", headline: "Tech giant misses earnings", sectors: ["Tech"], effect: { Tech: -0.06 } },
  { id: "n4", headline: "Inflation falls to 3-year low", sectors: ["Finance", "Consumer"], effect: { Finance: 0.04, Consumer: 0.03 } },
  { id: "n5", headline: "New AI chip demand surges", sectors: ["Tech"], effect: { Tech: 0.07 } },
  { id: "n6", headline: "Drug approval surprises market", sectors: ["Healthcare"], effect: { Healthcare: 0.06 } },
  { id: "n7", headline: "Retail sales disappoint", sectors: ["Consumer"], effect: { Consumer: -0.05 } },
  { id: "n8", headline: "Bank capital rules relaxed", sectors: ["Finance"], effect: { Finance: 0.05 } },
  { id: "n9", headline: "Cybersecurity breach hits software sector", sectors: ["Tech"], effect: { Tech: -0.04 } },
  { id: "n10", headline: "Natural gas prices spike", sectors: ["Energy", "Consumer"], effect: { Energy: 0.06, Consumer: -0.02 } },
];

export const NEWS_CARDS: MarketNewsCard[] = Array.from({ length: 50 }, (_, index) => {
  const card = baseCards[index % baseCards.length];
  return {
    ...card,
    id: `n${index + 1}`,
    headline: index < baseCards.length ? card.headline : `${card.headline} (${index + 1})`,
  };
});
