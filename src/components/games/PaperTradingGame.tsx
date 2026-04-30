"use client";

import { useUser } from "@clerk/nextjs";
import { useMemo, useState } from "react";
import useSWR from "swr";
import { Button } from "@/components/ui/Button";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { recordGameXp } from "@/lib/gamesXpStorage";
import { useDashboardStore } from "@/store/dashboardStore";
import { useToastStore } from "@/store/toastStore";
import type { FinanceMonitorSnapshot, FinanceQuote } from "@/types/financeMonitor";

const STARTING_CASH = 100_000;
const MIN_ORDER = 100;
const TOTAL_ROUNDS = 10;

interface Asset {
  symbol: string;
  name: string;
  display: string;
  price: number;
  change: number;
  category: "Stock/ETF" | "Commodity" | "Crypto";
}

interface Trade {
  id: string;
  round: number;
  side: "buy" | "sell";
  symbol: string;
  amount: number;
  quantity: number;
  price: number;
}

interface Scenario {
  title: string;
  description: string;
  modifiers: Record<string, number>;
  defaultMove: number;
  feedback: string;
}

const DEFAULT_ASSETS: Asset[] = [
  { symbol: "SPY", name: "S&P 500 ETF", display: "S&P 500", price: 522.41, change: 0.34, category: "Stock/ETF" },
  { symbol: "QQQ", name: "Nasdaq 100 ETF", display: "NASDAQ", price: 452.9, change: 0.57, category: "Stock/ETF" },
  { symbol: "DIA", name: "Dow Jones ETF", display: "Dow", price: 393.12, change: -0.08, category: "Stock/ETF" },
  { symbol: "INDA", name: "India ETF", display: "India", price: 51.8, change: 0.41, category: "Stock/ETF" },
  { symbol: "GC=F", name: "Gold Futures", display: "Gold", price: 2325.4, change: 0.18, category: "Commodity" },
  { symbol: "SI=F", name: "Silver Futures", display: "Silver", price: 28.14, change: -0.22, category: "Commodity" },
  { symbol: "CL=F", name: "WTI Crude", display: "WTI", price: 83.6, change: 0.28, category: "Commodity" },
  { symbol: "NG=F", name: "Natural Gas", display: "Natural Gas", price: 2.2, change: -0.44, category: "Commodity" },
  { symbol: "BTC", name: "Bitcoin", display: "BTC", price: 68400, change: 1.1, category: "Crypto" },
  { symbol: "ETH", name: "Ethereum", display: "ETH", price: 3520, change: 0.8, category: "Crypto" },
];

const SCENARIOS: Scenario[] = [
  {
    title: "Fed signals rates may stay higher",
    description: "Growth stocks wobble while defensive blue chips hold up better.",
    modifiers: { QQQ: -0.038, SPY: -0.018, DIA: -0.006, INDA: -0.012, "GC=F": 0.012, BTC: -0.046, ETH: -0.052 },
    defaultMove: -0.015,
    feedback: "High tech exposure increased drawdown when rates stayed elevated.",
  },
  {
    title: "AI earnings surprise lifts megacap tech",
    description: "Semiconductor and platform optimism pulls Nasdaq exposure higher.",
    modifiers: { QQQ: 0.052, SPY: 0.024, DIA: 0.007, INDA: 0.014, BTC: 0.034, ETH: 0.042, "GC=F": -0.006 },
    defaultMove: 0.018,
    feedback: "Diversified portfolios participated without depending on one trade.",
  },
  {
    title: "Oil route disruption pushes inflation fears",
    description: "Energy pressure hits import-sensitive markets and boosts volatility.",
    modifiers: { INDA: -0.031, QQQ: -0.017, SPY: -0.01, DIA: 0.004, "CL=F": 0.072, "NG=F": 0.045, "GC=F": 0.014, BTC: -0.022 },
    defaultMove: -0.012,
    feedback: "Cash reduced volatility but limited upside during the shock.",
  },
  {
    title: "Global manufacturing PMI rebounds",
    description: "Cyclical markets catch a bid as demand expectations improve.",
    modifiers: { DIA: 0.026, SPY: 0.019, INDA: 0.024, QQQ: 0.012, "CL=F": 0.028, "SI=F": 0.016, BTC: 0.018 },
    defaultMove: 0.017,
    feedback: "Balanced exposure helped capture the broad recovery.",
  },
  {
    title: "Dollar rally pressures emerging markets",
    description: "Capital moves toward US assets while EM ETFs lag.",
    modifiers: { INDA: -0.044, DIA: 0.01, SPY: 0.006, QQQ: -0.004, "GC=F": -0.018, "SI=F": -0.026, BTC: -0.031, ETH: -0.036 },
    defaultMove: -0.008,
    feedback: "Concentration in one region can create avoidable single-market risk.",
  },
  {
    title: "Soft inflation print sparks risk-on trade",
    description: "Lower yield expectations support broad equity allocations.",
    modifiers: { QQQ: 0.041, SPY: 0.029, DIA: 0.018, INDA: 0.033, "GC=F": 0.011, BTC: 0.055, ETH: 0.063 },
    defaultMove: 0.026,
    feedback: "Staying invested allowed compounding to work after the data improved.",
  },
  {
    title: "Bank stress headlines hit financial sentiment",
    description: "Large-cap value slips while tech acts as a relative safe haven.",
    modifiers: { DIA: -0.035, SPY: -0.014, QQQ: 0.006, INDA: -0.018, "GC=F": 0.018, BTC: -0.012, ETH: -0.016 },
    defaultMove: -0.012,
    feedback: "Diversified portfolios handled this shock better.",
  },
  {
    title: "India growth upgrade draws foreign inflows",
    description: "Emerging-market optimism lifts India-linked exposure.",
    modifiers: { INDA: 0.058, SPY: 0.011, QQQ: 0.009, DIA: 0.006, "CL=F": 0.012, BTC: 0.017 },
    defaultMove: 0.01,
    feedback: "A satellite allocation can add return without dominating the portfolio.",
  },
  {
    title: "Geopolitical risk triggers broad de-risking",
    description: "Markets sell off together as investors reduce exposure.",
    modifiers: { QQQ: -0.045, SPY: -0.032, DIA: -0.024, INDA: -0.039, "GC=F": 0.032, "SI=F": 0.018, BTC: -0.061, ETH: -0.069 },
    defaultMove: -0.032,
    feedback: "Position sizing matters most when correlations rise together.",
  },
  {
    title: "Year-end rally rewards resilient portfolios",
    description: "Markets recover as earnings guidance and liquidity improve.",
    modifiers: { SPY: 0.032, QQQ: 0.039, DIA: 0.025, INDA: 0.028, "CL=F": 0.016, BTC: 0.048, ETH: 0.052 },
    defaultMove: 0.03,
    feedback: "Risk control kept the portfolio ready for the rebound.",
  },
];

async function fetchSnapshot(url: string): Promise<FinanceMonitorSnapshot> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error("Unable to load finance monitor");
  }
  return res.json() as Promise<FinanceMonitorSnapshot>;
}

function toAsset(quote: FinanceQuote, category: Asset["category"]): Asset | null {
  if (quote.price === null || quote.price <= 0) {
    return null;
  }
  return {
    symbol: quote.symbol,
    name: quote.name,
    display: quote.display,
    price: quote.price,
    change: quote.change ?? 0,
    category,
  };
}

function roundShares(value: number) {
  return Math.floor(value * 10_000) / 10_000;
}

function money(value: number) {
  return value.toLocaleString("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: value >= 1000 ? 0 : 2,
  });
}

function percent(value: number) {
  return `${value >= 0 ? "+" : ""}${value.toFixed(2)}%`;
}

function clamp(value: number, min: number, max: number) {
  return Math.max(min, Math.min(max, value));
}

function maxDrawdown(values: number[]) {
  let peak = values[0] ?? STARTING_CASH;
  let worst = 0;
  for (const value of values) {
    peak = Math.max(peak, value);
    worst = Math.max(worst, peak > 0 ? (peak - value) / peak : 0);
  }
  return worst * 100;
}

function diversificationScore(holdings: Record<string, number>, prices: Record<string, number>, totalValue: number) {
  const weights = Object.entries(holdings)
    .map(([symbol, qty]) => (qty * (prices[symbol] ?? 0)) / Math.max(totalValue, 1))
    .filter((weight) => weight > 0.02);
  if (!weights.length) {
    return 0;
  }
  const maxWeight = Math.max(...weights);
  const breadthScore = Math.min(100, weights.length * 25);
  const concentrationPenalty = Math.max(0, (maxWeight - 0.45) * 120);
  return Math.round(clamp(breadthScore - concentrationPenalty, 0, 100));
}

function scoreGame(returnPct: number, drawdown: number, diversification: number) {
  const returnScore = clamp(650 + returnPct * 14, 0, 900);
  const riskScore = clamp(350 - drawdown * 10, 0, 350);
  const diversificationScoreValue = diversification * 2.5;
  return Math.round(clamp(returnScore + riskScore + diversificationScoreValue, 0, 1500));
}

export default function PaperTradingGame() {
  const { user } = useUser();
  const email = user?.primaryEmailAddress?.emailAddress;
  const { data: monitor } = useSWR("/api/finance-monitor", fetchSnapshot, {
    refreshInterval: 30_000,
  });
  const setUserXP = useDashboardStore((store) => store.setUserXP);
  const pushToast = useToastStore((store) => store.pushToast);
  const assets = useMemo(() => {
    const liveAssets = [
      ...(monitor?.marketQuotes ?? []).map((quote) => toAsset(quote, "Stock/ETF")),
      ...(monitor?.commodityQuotes ?? []).map((quote) => toAsset(quote, "Commodity")),
      ...(monitor?.cryptoQuotes ?? []).map((quote) => toAsset(quote, "Crypto")),
    ].filter((asset): asset is Asset => asset !== null);
    return [...liveAssets, ...DEFAULT_ASSETS].reduce<Asset[]>((items, asset) => {
      if (!items.some((item) => item.symbol === asset.symbol)) {
        items.push(asset);
      }
      return items;
    }, []);
  }, [monitor?.commodityQuotes, monitor?.cryptoQuotes, monitor?.marketQuotes]);
  const basePriceMap = useMemo(
    () => Object.fromEntries(assets.map((asset) => [asset.symbol, asset.price])),
    [assets],
  );
  const [prices, setPrices] = useState<Record<string, number>>({});
  const effectivePrices = useMemo(() => ({ ...basePriceMap, ...prices }), [basePriceMap, prices]);
  const [cash, setCash] = useState(STARTING_CASH);
  const [holdings, setHoldings] = useState<Record<string, number>>({});
  const [trades, setTrades] = useState<Trade[]>([]);
  const [round, setRound] = useState(0);
  const [selectedSymbol, setSelectedSymbol] = useState("SPY");
  const [side, setSide] = useState<"buy" | "sell">("buy");
  const [amount, setAmount] = useState("5000");
  const [valueHistory, setValueHistory] = useState([STARTING_CASH]);
  const [lastFeedback, setLastFeedback] = useState("Build a balanced portfolio before the first market shock.");
  const [saved, setSaved] = useState(false);
  const complete = round >= TOTAL_ROUNDS;
  const quoteSource =
    monitor?.source === "worldmonitor"
      ? "WorldMonitor"
      : monitor?.source === "finnhub-alpha"
        ? "Finnhub"
        : "Fallback";

  const portfolioValue = useMemo(
    () =>
      cash +
      Object.entries(holdings).reduce(
        (sum, [symbol, qty]) => sum + qty * (effectivePrices[symbol] ?? 0),
        0,
      ),
    [cash, effectivePrices, holdings],
  );
  const returnPct = ((portfolioValue - STARTING_CASH) / STARTING_CASH) * 100;
  const drawdown = maxDrawdown([...valueHistory, portfolioValue]);
  const diversification = diversificationScore(holdings, effectivePrices, portfolioValue);
  const finalScore = scoreGame(returnPct, drawdown, diversification);
  const currentScenario = SCENARIOS[Math.min(round, SCENARIOS.length - 1)];
  const selectedPrice = effectivePrices[selectedSymbol] ?? 0;
  const selectedQty = holdings[selectedSymbol] ?? 0;
  const numericAmount = Number(amount);

  const placeOrder = () => {
    if (complete) {
      return;
    }
    if (!Number.isFinite(numericAmount) || numericAmount < MIN_ORDER) {
      pushToast({ title: "Order too small", description: `Minimum order is ${money(MIN_ORDER)}.` });
      return;
    }
    if (!selectedPrice) {
      pushToast({ title: "Quote unavailable", description: "Choose another asset with a valid price." });
      return;
    }

    if (side === "buy") {
      if (numericAmount > cash) {
        pushToast({ title: "Insufficient cash", description: "Reduce the order size or sell another position." });
        return;
      }
      const quantity = roundShares(numericAmount / selectedPrice);
      const cost = quantity * selectedPrice;
      setCash((value) => value - cost);
      setHoldings((current) => ({ ...current, [selectedSymbol]: (current[selectedSymbol] ?? 0) + quantity }));
      setTrades((current) => [
        ...current,
        { id: crypto.randomUUID(), round: round + 1, side, symbol: selectedSymbol, amount: cost, quantity, price: selectedPrice },
      ]);
      pushToast({ title: "Buy order filled", description: `${quantity.toFixed(4)} ${selectedSymbol} at ${money(selectedPrice)}.` });
      return;
    }

    const ownedValue = selectedQty * selectedPrice;
    if (numericAmount > ownedValue + 0.01) {
      pushToast({ title: "Insufficient shares", description: `You can sell up to ${money(ownedValue)} of ${selectedSymbol}.` });
      return;
    }
    const quantity = Math.min(selectedQty, roundShares(numericAmount / selectedPrice));
    const proceeds = quantity * selectedPrice;
    setCash((value) => value + proceeds);
    setHoldings((current) => ({ ...current, [selectedSymbol]: roundShares((current[selectedSymbol] ?? 0) - quantity) }));
    setTrades((current) => [
      ...current,
      { id: crypto.randomUUID(), round: round + 1, side, symbol: selectedSymbol, amount: proceeds, quantity, price: selectedPrice },
    ]);
    pushToast({ title: "Sell order filled", description: `${quantity.toFixed(4)} ${selectedSymbol} at ${money(selectedPrice)}.` });
  };

  const lockRound = async () => {
    if (complete) {
      return;
    }
    const scenario = SCENARIOS[round];
    const nextPrices = Object.fromEntries(
      assets.map((asset) => {
        const price = prices[asset.symbol] ?? asset.price;
        const symbol = asset.symbol;
        const move = scenario.modifiers[symbol] ?? scenario.defaultMove;
        return [symbol, Math.max(1, price * (1 + move))];
      }),
    );
    const nextValue =
      cash +
      Object.entries(holdings).reduce(
        (sum, [symbol, qty]) => sum + qty * (nextPrices[symbol] ?? effectivePrices[symbol] ?? 0),
        0,
      );
    setPrices(nextPrices);
    setValueHistory((current) => [...current, nextValue]);
    setLastFeedback(scenario.feedback);
    if (round + 1 >= TOTAL_ROUNDS) {
      setRound(TOTAL_ROUNDS);
    } else {
      setRound((value) => value + 1);
    }
  };

  const saveScore = async () => {
    if (saved) {
      return;
    }
    const res = await fetch("/api/games/session", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        gameName: "paper_trader",
        score: finalScore,
        roundsPlayed: TOTAL_ROUNDS,
        outcome: portfolioValue > STARTING_CASH ? "win" : "loss",
        metadata: {
          finalCash: cash,
          holdings,
          trades,
          returnPct,
          maxDrawdown: drawdown,
          diversificationScore: diversification,
          finalValue: portfolioValue,
        },
      }),
    });
    if (res.ok) {
      const data = (await res.json()) as { xpAwarded?: number };
      if (email && typeof data.xpAwarded === "number") {
        const localGameXp = recordGameXp(email, { gameName: "paper_trader", xpAwarded: data.xpAwarded, score: finalScore });
        if (localGameXp) {
          setUserXP(localGameXp.totalXp, localGameXp.level);
        }
      }
      setSaved(true);
      pushToast({ title: `Paper Trader saved`, description: `+${data.xpAwarded ?? 0} XP earned.` });
    } else {
      pushToast({ title: "Unable to save score", description: "Try again in a moment." });
    }
  };

  const restart = () => {
    setCash(STARTING_CASH);
    setHoldings({});
    setTrades([]);
    setRound(0);
    setAmount("5000");
    setSide("buy");
    setValueHistory([STARTING_CASH]);
    setLastFeedback("Build a balanced portfolio before the first market shock.");
    setSaved(false);
    setPrices({});
  };

  if (complete) {
    return (
      <div className="p-5">
        <section className="rounded-lg border border-accent-border bg-bg-primary p-6 text-center">
          <p className="text-sm font-bold uppercase tracking-widest text-accent-gold">Paper Trader complete</p>
          <h2 className="mt-2 text-3xl font-bold text-white">{money(portfolioValue)}</h2>
          <p className={returnPct >= 0 ? "mt-2 font-mono text-accent-green" : "mt-2 font-mono text-accent-red"}>
            {percent(returnPct)} total return
          </p>
          <div className="mt-6 grid gap-3 md:grid-cols-4">
            <ResultStat label="Score" value={`${finalScore}/1500`} />
            <ResultStat label="Max drawdown" value={`${drawdown.toFixed(2)}%`} />
            <ResultStat label="Diversification" value={`${diversification}/100`} />
            <ResultStat label="Trades" value={String(trades.length)} />
          </div>
          <p className="mx-auto mt-5 max-w-2xl text-sm leading-6 text-text-muted">
            {lastFeedback} Strong paper traders manage return and risk together, not just the biggest winning trade.
          </p>
          <div className="mt-6 flex flex-wrap justify-center gap-3">
            <Button onClick={() => void saveScore()} disabled={saved}>
              {saved ? "Saved" : "Save Score"}
            </Button>
            <Button variant="secondary" onClick={restart}>
              Play Again
            </Button>
          </div>
        </section>
      </div>
    );
  }

  return (
    <div className="grid min-h-[640px] gap-4 p-4 xl:grid-cols-[1.1fr_0.9fr_1fr]">
      <section className="rounded-lg border border-accent-border bg-bg-primary p-4">
        <div className="flex items-start justify-between gap-3">
          <div>
            <p className="text-xs font-bold uppercase tracking-widest text-accent-gold">Paper Trader</p>
            <h2 className="mt-1 text-2xl font-bold text-white">{money(portfolioValue)}</h2>
            <p className={returnPct >= 0 ? "font-mono text-sm text-accent-green" : "font-mono text-sm text-accent-red"}>
              {percent(returnPct)} return
            </p>
          </div>
          <div className="rounded-lg bg-bg-tertiary px-3 py-2 text-right">
            <div className="text-[10px] uppercase text-text-muted">Cash</div>
            <div className="font-mono text-sm font-bold text-white">{money(cash)}</div>
          </div>
        </div>
        <div className="mt-4">
          <div className="mb-2 flex justify-between text-xs text-text-muted">
            <span>Round {round + 1} of {TOTAL_ROUNDS}</span>
            <span>Drawdown {drawdown.toFixed(2)}%</span>
          </div>
          <ProgressBar value={(round / TOTAL_ROUNDS) * 100} />
        </div>

        <div className="mt-5 rounded-lg border border-brand-blue/50 bg-bg-tertiary p-4">
          <p className="text-xs font-bold uppercase text-accent-teal">Market scenario</p>
          <h3 className="mt-1 font-bold text-white">{currentScenario.title}</h3>
          <p className="mt-2 text-sm leading-6 text-text-muted">{currentScenario.description}</p>
        </div>

        <div className="mt-4 rounded-lg bg-bg-tertiary p-3 text-sm text-text-muted">
          {lastFeedback}
        </div>

        <Button className="mt-4 w-full" onClick={() => void lockRound()}>
          Lock Round & Move Market
        </Button>
      </section>

      <section className="rounded-lg border border-accent-border bg-bg-primary p-4">
        <h3 className="font-bold text-white">Trade Ticket</h3>
        <div className="mt-4 grid grid-cols-2 gap-2">
          {(["buy", "sell"] as const).map((item) => (
            <button
              key={item}
              className={`rounded-lg border px-3 py-2 text-sm font-bold uppercase ${
                side === item
                  ? item === "buy"
                    ? "border-accent-green bg-accent-green/15 text-accent-green"
                    : "border-accent-red bg-accent-red/15 text-accent-red"
                  : "border-accent-border bg-bg-tertiary text-text-muted"
              }`}
              onClick={() => setSide(item)}
            >
              {item}
            </button>
          ))}
        </div>
        <label className="mt-4 block text-sm">
          <span className="text-text-muted">Asset</span>
          <select
            className="mt-2 h-11 w-full rounded-lg border border-accent-border bg-bg-tertiary px-3 text-white outline-none focus:border-brand-blue"
            value={selectedSymbol}
            onChange={(event) => setSelectedSymbol(event.target.value)}
          >
            {assets.map((asset) => (
              <option key={asset.symbol} value={asset.symbol}>
                {asset.display} ({asset.symbol}) · {asset.category}
              </option>
            ))}
          </select>
        </label>
        <label className="mt-4 block text-sm">
          <span className="text-text-muted">Dollar amount</span>
          <input
            className="mt-2 h-11 w-full rounded-lg border border-accent-border bg-bg-tertiary px-3 font-mono text-white outline-none focus:border-brand-blue"
            min={MIN_ORDER}
            step={100}
            type="number"
            value={amount}
            onChange={(event) => setAmount(event.target.value)}
          />
        </label>
        <div className="mt-4 grid grid-cols-2 gap-2 text-xs">
          <div className="rounded bg-bg-tertiary p-3 text-text-muted">
            Quote <span className="block font-mono text-sm text-white">{money(selectedPrice)}</span>
          </div>
          <div className="rounded bg-bg-tertiary p-3 text-text-muted">
            Owned <span className="block font-mono text-sm text-white">{selectedQty.toFixed(4)}</span>
          </div>
        </div>
        <Button className="mt-4 w-full" onClick={placeOrder}>
          Submit Market Order
        </Button>
        <p className="mt-3 text-xs leading-5 text-text-muted">
          Minimum order {money(MIN_ORDER)}. Trades fill immediately at the displayed paper quote.
        </p>
      </section>

      <section className="rounded-lg border border-accent-border bg-bg-primary p-4">
        <div className="flex items-start justify-between gap-3">
          <div>
            <h3 className="font-bold text-white">Market Watch</h3>
            <p className="mt-1 text-[11px] text-text-muted">
              Real quotes from {quoteSource}
              {monitor?.updatedAt ? ` · ${new Date(monitor.updatedAt).toLocaleTimeString()}` : ""}
            </p>
          </div>
          {Object.keys(prices).length ? (
            <span className="rounded-full bg-brand-blue/10 px-2 py-1 text-[10px] font-bold uppercase text-accent-teal">
              Paper prices active
            </span>
          ) : null}
        </div>
        <div className="mt-3 max-h-[250px] space-y-2 overflow-y-auto">
          {assets.map((asset) => {
            const paperPrice = prices[asset.symbol];
            const activePrice = paperPrice ?? asset.price;
            const paperChange = paperPrice ? ((paperPrice - asset.price) / asset.price) * 100 : 0;
            return (
              <button
                key={asset.symbol}
                className={`grid w-full grid-cols-[1fr_92px_70px] items-center gap-2 rounded-lg border px-3 py-2 text-left text-xs ${
                  selectedSymbol === asset.symbol ? "border-brand-blue bg-brand-blue/10" : "border-accent-border bg-bg-tertiary"
                }`}
                onClick={() => setSelectedSymbol(asset.symbol)}
              >
                <span className="min-w-0">
                  <span className="block truncate font-bold text-white">{asset.display}</span>
                  <span className="text-text-muted">
                    {asset.symbol} · {asset.category}
                    {paperPrice ? ` · Paper ${percent(paperChange)}` : ""}
                  </span>
                </span>
                <span className="text-right">
                  <span className="block font-mono text-white">{money(activePrice)}</span>
                  {paperPrice ? <span className="text-[10px] text-text-muted">paper</span> : <span className="text-[10px] text-text-muted">real</span>}
                </span>
                <span className={asset.change >= 0 ? "text-right font-mono text-accent-green" : "text-right font-mono text-accent-red"}>
                  {percent(asset.change)}
                </span>
              </button>
            );
          })}
        </div>

        <h3 className="mt-5 font-bold text-white">Holdings</h3>
        <div className="mt-3 space-y-2">
          {Object.entries(holdings).filter(([, qty]) => qty > 0.0001).length ? (
            Object.entries(holdings)
              .filter(([, qty]) => qty > 0.0001)
              .map(([symbol, qty]) => (
                <div key={symbol} className="grid grid-cols-[1fr_88px_88px] rounded-lg bg-bg-tertiary px-3 py-2 text-xs">
                  <span className="font-bold text-white">{symbol}</span>
                  <span className="text-right font-mono text-text-muted">{qty.toFixed(4)}</span>
                  <span className="text-right font-mono text-white">{money(qty * (effectivePrices[symbol] ?? 0))}</span>
                </div>
              ))
          ) : (
            <p className="rounded-lg bg-bg-tertiary p-3 text-sm text-text-muted">No positions yet.</p>
          )}
        </div>
      </section>
    </div>
  );
}

function ResultStat({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg bg-bg-tertiary p-4">
      <div className="text-xs uppercase text-text-muted">{label}</div>
      <div className="mt-1 font-mono text-xl font-bold text-white">{value}</div>
    </div>
  );
}
