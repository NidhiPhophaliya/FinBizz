"use client";

import { useUser } from "@clerk/nextjs";
import { motion } from "framer-motion";
import {
  BarChart3,
  Brain,
  CandlestickChart,
  ChevronLeft,
  Coins,
  LineChart,
  Medal,
  MousePointer2,
  Newspaper,
  PieChart,
  Search,
  Trophy,
  WalletCards,
  X,
} from "lucide-react";
import { useEffect, useState } from "react";
import AlphaGame from "@/components/games/AlphaGame";
import BudgetBlitzGame from "@/components/games/BudgetBlitzGame";
import CompoundClickerGame from "@/components/games/CompoundClickerGame";
import FinchessGame, { type FinchessGameId } from "@/components/games/FinchessGame";
import GameCard from "@/components/games/GameCard";
import Leaderboard from "@/components/games/Leaderboard";
import MarketMayhemGame from "@/components/games/MarketMayhemGame";
import PaperTradingGame from "@/components/games/PaperTradingGame";
import { ErrorBoundary } from "@/components/ui/ErrorBoundary";
import { useDashboardStore } from "@/store/dashboardStore";

type View =
  | "hub"
  | "alpha"
  | "budget"
  | "compound"
  | "mayhem"
  | "paper"
  | "finchess_predictor"
  | "finchess_portfolio"
  | "finchess_quiz"
  | "finchess_candles"
  | "leaderboard";

const finchessViewToGame: Partial<Record<View, FinchessGameId>> = {
  finchess_predictor: "predictor",
  finchess_portfolio: "portfolio",
  finchess_quiz: "quiz",
  finchess_candles: "candles",
};

type Category = "All" | "Markets" | "Planning" | "Knowledge";

const games = [
  { view: "alpha" as View, icon: WalletCards, title: "Alpha", tagline: "Practice income, assets, debt, and cashflow decisions in a board-style simulation.", difficulty: "Advanced", reward: "Up to 100 XP", category: "Planning" as Category, accent: "#d8b773" },
  { view: "finchess_predictor" as View, icon: LineChart, title: "Stock Price Predictor", tagline: "Read live-style charts and decide the next market move before time runs out.", difficulty: "Intermediate", reward: "Practice", category: "Markets" as Category, accent: "#78c9bc" },
  { view: "finchess_portfolio" as View, icon: PieChart, title: "Portfolio Challenge", tagline: "Build a $100K allocation, manage risk, and compare performance to the benchmark.", difficulty: "Intermediate", reward: "Practice", category: "Markets" as Category, accent: "#9ccf87" },
  { view: "finchess_quiz" as View, icon: Brain, title: "Finance Quiz", tagline: "Review markets, economics, crypto, and technical analysis with fast questions.", difficulty: "Beginner", reward: "Practice", category: "Knowledge" as Category, accent: "#8fb7e8" },
  { view: "finchess_candles" as View, icon: CandlestickChart, title: "Candlestick Trainer", tagline: "Recognize common candlestick patterns and learn when signals matter.", difficulty: "Beginner", reward: "Practice", category: "Knowledge" as Category, accent: "#d8b773" },
  { view: "budget" as View, icon: Coins, title: "Budget Blitz", tagline: "Handle surprise expenses and keep a monthly plan balanced under pressure.", difficulty: "Beginner", reward: "Up to 75 XP", category: "Planning" as Category, accent: "#8fb7e8" },
  { view: "compound" as View, icon: BarChart3, title: "Compound Clicker", tagline: "See how savings rate, time, and reinvestment change a wealth curve.", difficulty: "Beginner", reward: "Up to 50 XP", category: "Planning" as Category, accent: "#78c9bc" },
  { view: "mayhem" as View, icon: Newspaper, title: "Market Mayhem", tagline: "React to headlines, rebalance sectors, and survive volatility swings.", difficulty: "Intermediate", reward: "Up to 100 XP", category: "Markets" as Category, accent: "#9ccf87" },
  { view: "paper" as View, icon: CandlestickChart, title: "Paper Trader", tagline: "Trade a virtual portfolio through market shocks without risking real money.", difficulty: "Intermediate", reward: "Up to 150 XP", category: "Markets" as Category, accent: "#78c9bc" },
];

const categories: Category[] = ["All", "Markets", "Planning", "Knowledge"];

export default function GamesHubModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const [view, setView] = useState<View>("hub");
  const [category, setCategory] = useState<Category>("All");
  const { user } = useUser();
  const email = user?.primaryEmailAddress?.emailAddress;
  const userXP = useDashboardStore((state) => state.userXP);
  const userLevel = useDashboardStore((state) => state.userLevel);
  const setUserXP = useDashboardStore((state) => state.setUserXP);

  useEffect(() => {
    if (!open) {
      return;
    }

    if (!email) {
      setUserXP(0, 1);
      return;
    }

    let cancelled = false;
    void fetch("/api/user/xp")
      .then(async (res) => {
        if (!res.ok) {
          return null;
        }
        return (await res.json()) as { xpTotal?: number; level?: number };
      })
      .then((data) => {
        if (!cancelled && data) {
          setUserXP(data.xpTotal ?? 0, data.level ?? 1);
        }
      })
      .catch(() => {
        if (!cancelled) {
          setUserXP(0, 1);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [email, open, setUserXP]);

  if (!open) {
    return null;
  }

  const filteredGames = category === "All" ? games : games.filter((game) => game.category === category);
  const selectedGame = games.find((game) => game.view === view);

  return (
    <div className="fixed inset-0 z-[100] overflow-y-auto bg-[#090d14]">
      <motion.div
        className="min-h-screen bg-[radial-gradient(circle_at_20%_0%,rgba(81,129,134,0.18),transparent_34%),linear-gradient(180deg,#101621_0%,#0b1018_48%,#090d14_100%)]"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
      >
        <header className="sticky top-0 z-20 border-b border-white/[0.07] bg-[#090d14]/85 px-4 py-3 backdrop-blur-xl md:px-8">
          <div className="mx-auto flex max-w-7xl items-center gap-3">
            {view !== "hub" ? (
              <button
                className="inline-flex h-10 items-center gap-2 rounded-lg border border-white/[0.08] bg-white/[0.03] px-3 text-sm font-medium text-[#d7dde8] transition hover:border-white/[0.16] hover:bg-white/[0.06]"
                onClick={() => setView("hub")}
              >
                <ChevronLeft size={17} />
                Hub
              </button>
            ) : null}
            <div className="min-w-0 flex-1">
              <div className="flex items-center gap-2">
                <MousePointer2 className="text-[#78c9bc]" size={18} />
                <h1 className="truncate text-lg font-semibold text-[#f5f7fb] md:text-xl">
                  {view === "hub" ? "Games Hub" : selectedGame?.title ?? "Leaderboard"}
                </h1>
              </div>
              <p className="mt-0.5 hidden text-sm text-[#8d98aa] sm:block">
                {view === "hub" ? "Choose a short finance practice session." : "Finish or switch back to the hub anytime."}
              </p>
            </div>
            <div className="hidden items-center gap-2 rounded-lg border border-white/[0.07] bg-white/[0.03] px-3 py-2 text-sm text-[#d7dde8] md:flex">
              <Medal size={16} className="text-[#d8b773]" />
              <span>Level {userLevel}</span>
              <span className="text-[#687386]">/</span>
              <span className="font-mono text-xs text-[#aeb8c7]">{userXP} XP</span>
            </div>
            {view !== "leaderboard" ? (
              <button
                className="hidden h-10 items-center gap-2 rounded-lg border border-white/[0.08] bg-white/[0.03] px-3 text-sm font-medium text-[#d7dde8] transition hover:border-white/[0.16] hover:bg-white/[0.06] sm:inline-flex"
                onClick={() => setView("leaderboard")}
              >
                <Trophy size={16} />
                Leaderboard
              </button>
            ) : null}
            <button
              className="inline-flex h-10 w-10 items-center justify-center rounded-lg text-[#9ca7b8] transition hover:bg-white/[0.06] hover:text-white"
              onClick={onClose}
              aria-label="Close games hub"
            >
              <X size={20} />
            </button>
          </div>
        </header>

        <main className="mx-auto max-w-7xl px-4 py-6 md:px-8 md:py-8">
          {view === "hub" ? (
            <>
              <section className="grid gap-6 lg:grid-cols-[minmax(0,1fr)_320px]">
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.26em] text-[#78c9bc]">
                    Practice library
                  </p>
                  <h2 className="mt-3 max-w-3xl text-3xl font-semibold tracking-normal text-[#f5f7fb] md:text-4xl">
                    Pick a game by the skill you want to sharpen.
                  </h2>
                </div>
                <aside className="rounded-lg border border-white/[0.07] bg-white/[0.035] p-4">
                  <div className="flex items-center justify-between text-sm">
                    <span className="text-[#8d98aa]">Current progress</span>
                    <span className="font-mono text-xs text-[#d7dde8]">{userXP} XP</span>
                  </div>
                  <div className="mt-3 h-2 overflow-hidden rounded-full bg-[#1c2431]">
                    <div
                      className="h-full rounded-full bg-[#78c9bc]"
                      style={{ width: `${Math.min(100, (userXP % 500) / 5)}%` }}
                    />
                  </div>
                  <p className="mt-3 text-sm leading-6 text-[#a5afbf]">
                    Level {userLevel}. Short sessions count toward XP when a game supports scoring.
                  </p>
                </aside>
              </section>

              <div className="mt-8 flex flex-col gap-3 border-y border-white/[0.06] py-3 md:flex-row md:items-center md:justify-between">
                <div className="flex items-center gap-2 overflow-x-auto">
                  {categories.map((item) => (
                    <button
                      key={item}
                      className={`shrink-0 rounded-lg px-3 py-2 text-sm font-medium transition ${
                        category === item
                          ? "bg-[#d7dde8] text-[#101621]"
                          : "text-[#98a3b4] hover:bg-white/[0.05] hover:text-white"
                      }`}
                      onClick={() => setCategory(item)}
                    >
                      {item}
                    </button>
                  ))}
                </div>
                <div className="flex items-center gap-2 text-sm text-[#7f8a9c]">
                  <Search size={16} />
                  <span>{filteredGames.length} games available</span>
                </div>
              </div>

              <div className="mt-6 grid gap-3 md:grid-cols-2 xl:grid-cols-3">
                {filteredGames.map((game) => (
                  <GameCard key={game.title} {...game} onPlay={() => setView(game.view)} />
                ))}
              </div>

              <button
                className="mt-5 flex w-full items-center justify-between rounded-lg border border-white/[0.07] bg-[#111722] px-4 py-4 text-left transition hover:border-white/[0.16] hover:bg-[#151c29]"
                onClick={() => setView("leaderboard")}
              >
                <span>
                  <span className="block text-sm font-semibold text-[#f5f7fb]">Leaderboard</span>
                  <span className="mt-1 block text-sm text-[#8d98aa]">Compare scores across completed games.</span>
                </span>
                <Trophy className="text-[#d8b773]" size={20} />
              </button>
            </>
          ) : (
            <section className="overflow-hidden rounded-lg border border-white/[0.08] bg-[#111722] shadow-2xl shadow-black/30">
              <ErrorBoundary label="Game">
                {view === "alpha" ? <AlphaGame /> : null}
                {view === "budget" ? <BudgetBlitzGame /> : null}
                {view === "compound" ? <CompoundClickerGame /> : null}
                {view === "mayhem" ? <MarketMayhemGame /> : null}
                {view === "paper" ? <PaperTradingGame /> : null}
                {finchessViewToGame[view] ? <FinchessGame game={finchessViewToGame[view]} /> : null}
                {view === "leaderboard" ? <Leaderboard /> : null}
              </ErrorBoundary>
            </section>
          )}
        </main>
      </motion.div>
    </div>
  );
}
