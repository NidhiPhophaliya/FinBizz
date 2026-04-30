"use client";

import { useUser } from "@clerk/nextjs";
import { useMemo, useState } from "react";
import { Cell, Pie, PieChart, ResponsiveContainer } from "recharts";
import { Button } from "@/components/ui/Button";
import { NEWS_CARDS, type Sector } from "@/data/newsCardPool";
import { recordGameXp } from "@/lib/gamesXpStorage";
import { useDashboardStore } from "@/store/dashboardStore";
import { useToastStore } from "@/store/toastStore";

const sectors: Sector[] = ["Tech", "Energy", "Finance", "Healthcare", "Consumer"];
const colors = ["#42a5f5", "#ffd780", "#7ee4e3", "#99ff88", "#a7b1c1"];

export default function MarketMayhemGame() {
  const { user } = useUser();
  const email = user?.primaryEmailAddress?.emailAddress;
  const [round, setRound] = useState(1);
  const [portfolio, setPortfolio] = useState<Record<Sector, number>>({
    Tech: 2000,
    Energy: 2000,
    Finance: 2000,
    Healthcare: 2000,
    Consumer: 2000,
  });
  const setUserXP = useDashboardStore((store) => store.setUserXP);
  const pushToast = useToastStore((store) => store.pushToast);
  const cards = useMemo(() => NEWS_CARDS.slice((round - 1) * 3, round * 3), [round]);
  const total = Object.values(portfolio).reduce((sum, value) => sum + value, 0);

  const applyRound = async () => {
    const next = { ...portfolio };
    for (const card of cards) {
      for (const sector of sectors) {
        const effect = card.effect[sector] ?? (Math.random() - 0.5) * 0.025;
        next[sector] = Math.max(0, next[sector] * (1 + effect));
      }
    }
    setPortfolio(next);
    if (round >= 10) {
      const score = Math.round(Object.values(next).reduce((sum, value) => sum + value, 0));
      const res = await fetch("/api/games/session", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          gameName: "market_mayhem",
          score,
          roundsPlayed: 10,
          outcome: "win",
          metadata: next,
        }),
      });
      if (res.ok) {
        const data = (await res.json()) as { xpAwarded?: number };
        if (email && typeof data.xpAwarded === "number") {
          const localGameXp = recordGameXp(email, { gameName: "market_mayhem", xpAwarded: data.xpAwarded, score });
          if (localGameXp) {
            setUserXP(localGameXp.totalXp, localGameXp.level);
          }
        }
        pushToast({ title: "Market Mayhem saved", description: `+${data.xpAwarded ?? 0} XP earned.` });
      } else {
        pushToast({ title: "Unable to save score", description: "Try again in a moment." });
      }
    } else {
      setRound((value) => value + 1);
    }
  };

  const chartData = sectors.map((sector) => ({ name: sector, value: Math.round(portfolio[sector]) }));

  return (
    <div className="grid min-h-[560px] gap-4 p-5 lg:grid-cols-[1fr_1fr]">
      <section className="rounded-lg border border-accent-border bg-bg-primary p-5">
        <div className="mb-4 flex justify-between">
          <h2 className="text-xl font-bold text-white">Market Mayhem</h2>
          <span className="text-accent-gold">Round {round} of 10</span>
        </div>
        <div className="grid gap-3">
          {cards.map((card) => (
            <article key={card.id} className="rounded-lg border border-brand-blue bg-bg-tertiary p-4">
              <div className="text-xs font-bold uppercase text-accent-teal">News reveal</div>
              <h3 className="mt-1 font-bold text-white">{card.headline}</h3>
            </article>
          ))}
        </div>
        <Button className="mt-5 w-full" onClick={() => void applyRound()}>
          Apply Market Move
        </Button>
      </section>
      <section className="rounded-lg border border-accent-border bg-bg-primary p-5">
        <div className="text-xs uppercase text-text-muted">Portfolio value</div>
        <div className="font-mono text-4xl font-bold text-accent-green">${total.toFixed(0)}</div>
        <ResponsiveContainer width="100%" height={260}>
          <PieChart>
            <Pie data={chartData} dataKey="value" nameKey="name" innerRadius={60} outerRadius={100}>
              {chartData.map((entry, index) => (
                <Cell key={entry.name} fill={colors[index]} />
              ))}
            </Pie>
          </PieChart>
        </ResponsiveContainer>
        <div className="grid grid-cols-2 gap-2">
          {chartData.map((item) => (
            <div key={item.name} className="rounded bg-bg-tertiary p-2 text-sm text-text-muted">
              {item.name}: <span className="font-mono text-white">${item.value}</span>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
