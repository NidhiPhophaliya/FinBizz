"use client";

import { useEffect, useMemo, useState } from "react";
import { Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { Button } from "@/components/ui/Button";
import { upgrades, type UpgradeKey } from "@/data/upgradeTree";
import { useToastStore } from "@/store/toastStore";

interface Point {
  tick: number;
  balance: number;
}

export default function CompoundClickerGame() {
  const [balance, setBalance] = useState(100);
  const [interestRate, setInterestRate] = useState(0.005);
  const [tickSpeed, setTickSpeed] = useState(2000);
  const [owned, setOwned] = useState<UpgradeKey[]>([]);
  const [ticks, setTicks] = useState(0);
  const [data, setData] = useState<Point[]>([{ tick: 0, balance: 100 }]);
  const [celebrated, setCelebrated] = useState(false);
  const pushToast = useToastStore((store) => store.pushToast);
  const passiveIncome = useMemo(
    () => upgrades.filter((upgrade) => owned.includes(upgrade.key)).reduce((sum, upgrade) => sum + (upgrade.passiveIncome ?? 0), 0),
    [owned],
  );

  useEffect(() => {
    const timer = window.setInterval(() => {
      setBalance((current) => {
        const next = current * (1 + interestRate) + passiveIncome;
        setTicks((tick) => {
          const nextTick = tick + 1;
          setData((points) => [...points.slice(-40), { tick: nextTick, balance: next }]);
          return nextTick;
        });
        if (next > 10000 && !celebrated) {
          setCelebrated(true);
          pushToast({ title: "🎉 Compound interest unlocked", description: "Your money is earning money automatically." });
        }
        return next;
      });
    }, tickSpeed);
    return () => window.clearInterval(timer);
  }, [celebrated, interestRate, passiveIncome, pushToast, tickSpeed]);

  const buy = (key: UpgradeKey) => {
    const upgrade = upgrades.find((item) => item.key === key);
    if (!upgrade || balance < upgrade.cost || owned.includes(key)) {
      return;
    }
    setBalance((value) => value - upgrade.cost);
    setOwned((value) => [...value, key]);
    setInterestRate((value) => value + (upgrade.rateBoost ?? 0));
    const speedMultiplier = upgrade.speedMultiplier;
    if (speedMultiplier) {
      setTickSpeed((value) => Math.max(500, value / speedMultiplier));
    }
  };

  return (
    <div className="grid min-h-[560px] gap-4 p-5 lg:grid-cols-[0.8fr_1.2fr_1fr]">
      <section className="rounded-lg border border-accent-border bg-bg-primary p-5">
        <div className="text-xs font-bold uppercase text-text-muted">Total wealth</div>
        <div className="mt-2 animate-pulse font-mono text-5xl font-bold text-accent-green">
          ${balance.toFixed(0)}
        </div>
        <Button className="mt-6 w-full" onClick={() => setBalance((value) => value + 100)}>
          Deposit $100
        </Button>
      </section>
      <section className="rounded-lg border border-accent-border bg-bg-primary p-5">
        <ResponsiveContainer width="100%" height={320}>
          <LineChart data={data}>
            <XAxis dataKey="tick" stroke="#a7b1c1" />
            <YAxis stroke="#a7b1c1" />
            <Tooltip contentStyle={{ background: "#222431", border: "1px solid #36384a" }} />
            <Line type="monotone" dataKey="balance" stroke="#99ff88" strokeWidth={3} dot={false} />
          </LineChart>
        </ResponsiveContainer>
        <div className="mt-4 grid grid-cols-3 gap-2 text-xs">
          <div className="rounded bg-bg-tertiary p-2 text-text-muted">Rate <span className="text-white">{(interestRate * 100).toFixed(2)}%</span></div>
          <div className="rounded bg-bg-tertiary p-2 text-text-muted">Passive <span className="text-white">${passiveIncome}/tick</span></div>
          <div className="rounded bg-bg-tertiary p-2 text-text-muted">Ticks <span className="text-white">{ticks}</span></div>
        </div>
      </section>
      <section className="max-h-[520px] overflow-y-auto rounded-lg border border-accent-border bg-bg-primary p-4">
        <h3 className="mb-3 font-bold text-white">Upgrade Shop</h3>
        <div className="space-y-2">
          {upgrades.map((upgrade) => {
            const purchased = owned.includes(upgrade.key);
            return (
              <div key={upgrade.key} className="rounded-lg border border-accent-border bg-bg-tertiary p-3">
                <div className="font-bold text-white">{upgrade.name}</div>
                <p className="text-xs text-text-muted">{upgrade.description}</p>
                <Button className="mt-2 w-full" disabled={purchased || balance < upgrade.cost} onClick={() => buy(upgrade.key)}>
                  {purchased ? "Owned" : `Buy $${upgrade.cost.toLocaleString()}`}
                </Button>
              </div>
            );
          })}
        </div>
      </section>
    </div>
  );
}
