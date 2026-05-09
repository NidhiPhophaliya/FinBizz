"use client";

import { useUser } from "@clerk/nextjs";
import { motion } from "framer-motion";
import {
  BarChart3,
  Brain,
  CandlestickChart,
  ChevronLeft,
  Coins,
  GraduationCap,
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
  | "details"
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

type GameView = Exclude<View, "hub" | "details" | "leaderboard">;

interface GameInfo {
  view: GameView;
  icon: typeof WalletCards;
  title: string;
  tagline: string;
  description: string;
  howToPlay: string[];
  improves: string[];
  bestFor: string;
  difficulty: string;
  reward: string;
  category: Category;
  accent: string;
}

const games = [
  {
    view: "alpha",
    icon: WalletCards,
    title: "Alpha",
    tagline: "Practice income, assets, debt, and cashflow decisions in a board-style simulation.",
    description: "Alpha is a long-form money decision game. It helps you understand how cashflow, assets, liabilities, and life events work together over time.",
    howToPlay: ["Review your starting financial position.", "Choose actions that improve monthly cashflow.", "Watch how debt, assets, and expenses change your runway."],
    improves: ["Cashflow planning", "Debt awareness", "Long-term financial strategy"],
    bestFor: "Learners who already know basic budgeting and want a deeper challenge.",
    difficulty: "Advanced",
    reward: "Up to 100 XP",
    category: "Planning",
    accent: "#d8b773",
  },
  {
    view: "finchess_predictor",
    icon: LineChart,
    title: "Stock Price Predictor",
    tagline: "Read live-style charts and decide the next market move before time runs out.",
    description: "This game trains chart reading. You study price movement, momentum, and market context, then predict whether the next move is likely up or down.",
    howToPlay: ["Look at the chart and recent price action.", "Decide the likely direction.", "Use the result to learn which signals were useful."],
    improves: ["Chart reading", "Pattern recognition", "Decision speed"],
    bestFor: "Learners who want a practical entry point into market analysis.",
    difficulty: "Intermediate",
    reward: "Practice",
    category: "Markets",
    accent: "#78c9bc",
  },
  {
    view: "finchess_portfolio",
    icon: PieChart,
    title: "Portfolio Challenge",
    tagline: "Build a $100K allocation, manage risk, and compare performance to the benchmark.",
    description: "Portfolio Challenge teaches allocation. You choose how to spread capital across assets and learn how diversification changes risk and returns.",
    howToPlay: ["Start with a virtual $100K portfolio.", "Allocate across available assets.", "Compare your performance against the benchmark."],
    improves: ["Diversification", "Risk management", "Asset allocation"],
    bestFor: "Learners ready to think beyond single-stock picks.",
    difficulty: "Intermediate",
    reward: "Practice",
    category: "Markets",
    accent: "#9ccf87",
  },
  {
    view: "finchess_quiz",
    icon: Brain,
    title: "Finance Quiz",
    tagline: "Review markets, economics, crypto, and technical analysis with fast questions.",
    description: "Finance Quiz is a quick knowledge check. It helps you find gaps across investing, economics, crypto, and market vocabulary.",
    howToPlay: ["Answer each question from the available choices.", "Use missed answers as review topics.", "Replay to build speed and recall."],
    improves: ["Financial vocabulary", "Market concepts", "Recall under pressure"],
    bestFor: "Beginners who want a simple warm-up before harder games.",
    difficulty: "Beginner",
    reward: "Practice",
    category: "Knowledge",
    accent: "#8fb7e8",
  },
  {
    view: "finchess_candles",
    icon: CandlestickChart,
    title: "Candlestick Trainer",
    tagline: "Recognize common candlestick patterns and learn when signals matter.",
    description: "Candlestick Trainer teaches visual price patterns. You learn how individual candles and small groups of candles can reflect market sentiment.",
    howToPlay: ["Study the displayed candle setup.", "Identify the pattern or signal.", "Use feedback to connect shape, trend, and context."],
    improves: ["Technical analysis basics", "Price action reading", "Pattern discipline"],
    bestFor: "Learners who want to understand charts before trading simulations.",
    difficulty: "Beginner",
    reward: "Practice",
    category: "Knowledge",
    accent: "#d8b773",
  },
  {
    view: "budget",
    icon: Coins,
    title: "Budget Blitz",
    tagline: "Handle surprise expenses and keep a monthly plan balanced under pressure.",
    description: "Budget Blitz is about everyday money control. You make quick choices as expenses appear and try to keep your monthly plan stable.",
    howToPlay: ["Review income and available cash.", "Choose how to respond to each event.", "Protect savings while covering needs first."],
    improves: ["Budget prioritization", "Emergency planning", "Needs versus wants"],
    bestFor: "Beginners who want the most practical starting game.",
    difficulty: "Beginner",
    reward: "Up to 75 XP",
    category: "Planning",
    accent: "#8fb7e8",
  },
  {
    view: "compound",
    icon: BarChart3,
    title: "Compound Clicker",
    tagline: "See how savings rate, time, and reinvestment change a wealth curve.",
    description: "Compound Clicker makes compounding visible. Small repeated actions show how time and reinvestment can change long-term outcomes.",
    howToPlay: ["Click or invest to grow the balance.", "Upgrade inputs that improve growth.", "Watch how the curve changes as compounding accelerates."],
    improves: ["Compound interest", "Patience with long-term growth", "Savings habit logic"],
    bestFor: "New learners who need compounding to feel concrete.",
    difficulty: "Beginner",
    reward: "Up to 50 XP",
    category: "Planning",
    accent: "#78c9bc",
  },
  {
    view: "mayhem",
    icon: Newspaper,
    title: "Market Mayhem",
    tagline: "React to headlines, rebalance sectors, and survive volatility swings.",
    description: "Market Mayhem connects news to market movement. You read events, adjust exposure, and learn how different sectors react to shocks.",
    howToPlay: ["Read each market headline carefully.", "Shift sector weights based on the event.", "Balance opportunity with downside risk."],
    improves: ["News interpretation", "Sector rotation", "Volatility management"],
    bestFor: "Learners who want to understand why markets move.",
    difficulty: "Intermediate",
    reward: "Up to 100 XP",
    category: "Markets",
    accent: "#9ccf87",
  },
  {
    view: "paper",
    icon: CandlestickChart,
    title: "Paper Trader",
    tagline: "Trade a virtual portfolio through market shocks without risking real money.",
    description: "Paper Trader is a simulated trading workspace. It lets you practice buy, sell, and hold decisions with virtual money.",
    howToPlay: ["Review available assets and price changes.", "Place virtual buy or sell orders.", "Track whether your decisions improve the final portfolio value."],
    improves: ["Trade planning", "Position sizing", "Risk control"],
    bestFor: "Learners ready to practice trading decisions without real money.",
    difficulty: "Intermediate",
    reward: "Up to 150 XP",
    category: "Markets",
    accent: "#78c9bc",
  },
] satisfies GameInfo[];

const categories: Category[] = ["All", "Markets", "Planning", "Knowledge"];

export default function GamesHubModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const [view, setView] = useState<View>("hub");
  const [category, setCategory] = useState<Category>("All");
  const [selectedGameView, setSelectedGameView] = useState<GameView | null>(null);
  const [aiAdvice, setAiAdvice] = useState("");
  const [aiLoading, setAiLoading] = useState(false);
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
  const selectedGame =
    games.find((game) => game.view === selectedGameView) ??
    games.find((game) => game.view === view);

  const showGameDetails = (game: GameInfo) => {
    setSelectedGameView(game.view);
    setAiAdvice("");
    setView("details");
  };

  const startSelectedGame = () => {
    if (selectedGame) {
      setView(selectedGame.view);
    }
  };

  const askAiForPlan = async () => {
    if (!selectedGame || aiLoading) {
      return;
    }

    const prompt = `Recommend a learning path for me in FinLit Games Hub. I am currently viewing "${selectedGame.title}" (${selectedGame.category}, ${selectedGame.difficulty}). Explain whether this game is a good next step, suggest 2-3 games I should play before or after it, and give practical tips to improve my understanding. Keep it concise and beginner-friendly.`;
    setAiLoading(true);
    setAiAdvice("");

    try {
      const res = await fetch("/api/ai/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: prompt, history: [] }),
      });
      const data = (await res.json().catch(() => null)) as { reply?: string; error?: string } | null;

      if (!res.ok) {
        throw new Error(data?.error ?? "AI recommendation is unavailable right now.");
      }

      setAiAdvice(data?.reply ?? "Try Budget Blitz first, then Finance Quiz, then move into market games.");
    } catch (error) {
      setAiAdvice(error instanceof Error ? error.message : "AI recommendation is unavailable right now.");
    } finally {
      setAiLoading(false);
    }
  };

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
                {view === "hub"
                  ? "Choose a short finance practice session."
                  : view === "details"
                    ? "Understand the game before you start."
                    : "Finish or switch back to the hub anytime."}
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
                  <GameCard key={game.title} {...game} onPlay={() => showGameDetails(game)} />
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
          ) : view === "details" && selectedGame ? (
            <section className="grid gap-5 lg:grid-cols-[minmax(0,1fr)_360px]">
              <div className="rounded-lg border border-white/[0.08] bg-[#111722] p-5 md:p-6">
                <div className="flex flex-col gap-5 md:flex-row md:items-start">
                  <span
                    className="flex h-14 w-14 shrink-0 items-center justify-center rounded-lg border border-white/[0.08] bg-[#0e131d]"
                    style={{ color: selectedGame.accent }}
                  >
                    <selectedGame.icon size={26} strokeWidth={1.8} />
                  </span>
                  <div className="min-w-0 flex-1">
                    <div className="flex flex-wrap gap-2 text-xs">
                      <span className="rounded-md bg-white/[0.05] px-2 py-1 text-[#d7dde8]">{selectedGame.category}</span>
                      <span className="rounded-md bg-white/[0.05] px-2 py-1 text-[#a5afbf]">{selectedGame.difficulty}</span>
                      <span className="rounded-md bg-white/[0.05] px-2 py-1 text-[#a5afbf]">{selectedGame.reward}</span>
                    </div>
                    <h2 className="mt-4 text-2xl font-semibold tracking-normal text-[#f5f7fb] md:text-3xl">
                      {selectedGame.title}
                    </h2>
                    <p className="mt-3 max-w-3xl text-base leading-7 text-[#a5afbf]">{selectedGame.description}</p>
                  </div>
                </div>

                <div className="mt-8 grid gap-5 md:grid-cols-2">
                  <div>
                    <h3 className="text-sm font-semibold uppercase tracking-[0.18em] text-[#78c9bc]">How to play</h3>
                    <ol className="mt-4 space-y-3">
                      {selectedGame.howToPlay.map((step, index) => (
                        <li key={step} className="flex gap-3 text-sm leading-6 text-[#c2cad6]">
                          <span className="mt-0.5 flex h-6 w-6 shrink-0 items-center justify-center rounded-md bg-white/[0.06] font-mono text-xs text-[#d7dde8]">
                            {index + 1}
                          </span>
                          <span>{step}</span>
                        </li>
                      ))}
                    </ol>
                  </div>
                  <div>
                    <h3 className="text-sm font-semibold uppercase tracking-[0.18em] text-[#78c9bc]">What it improves</h3>
                    <div className="mt-4 flex flex-wrap gap-2">
                      {selectedGame.improves.map((skill) => (
                        <span key={skill} className="rounded-md border border-white/[0.08] bg-white/[0.04] px-3 py-2 text-sm text-[#d7dde8]">
                          {skill}
                        </span>
                      ))}
                    </div>
                    <div className="mt-5 rounded-lg border border-white/[0.07] bg-[#0d131d] p-4">
                      <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[#7f8a9c]">Best for</p>
                      <p className="mt-2 text-sm leading-6 text-[#c2cad6]">{selectedGame.bestFor}</p>
                    </div>
                  </div>
                </div>

                <div className="mt-8 flex flex-col gap-3 border-t border-white/[0.07] pt-5 sm:flex-row sm:items-center sm:justify-between">
                  <button
                    className="inline-flex min-h-11 items-center justify-center rounded-lg bg-[#d7dde8] px-5 text-sm font-semibold text-[#101621] transition hover:bg-white"
                    onClick={startSelectedGame}
                  >
                    Start game
                  </button>
                  <button
                    className="inline-flex min-h-11 items-center justify-center rounded-lg border border-white/[0.08] px-5 text-sm font-medium text-[#d7dde8] transition hover:border-white/[0.16] hover:bg-white/[0.05]"
                    onClick={() => setView("hub")}
                  >
                    Choose another game
                  </button>
                </div>
              </div>

              <aside className="rounded-lg border border-white/[0.08] bg-[#111722] p-5">
                <div className="flex items-start gap-3">
                  <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-[#16232c] text-[#78c9bc]">
                    <GraduationCap size={20} />
                  </span>
                  <div>
                    <h3 className="font-semibold text-[#f5f7fb]">AI learning coach</h3>
                    <p className="mt-1 text-sm leading-6 text-[#a5afbf]">
                      Ask AI whether this is the right game and what to play next.
                    </p>
                  </div>
                </div>
                <button
                  className="mt-5 inline-flex min-h-11 w-full items-center justify-center rounded-lg bg-[#78c9bc] px-4 text-sm font-semibold text-[#07110f] transition hover:bg-[#8ed8ce] disabled:cursor-not-allowed disabled:opacity-60"
                  onClick={askAiForPlan}
                  disabled={aiLoading}
                >
                  {aiLoading ? "Asking AI..." : "Get AI recommendation"}
                </button>
                <div className="mt-5 min-h-[160px] rounded-lg border border-white/[0.07] bg-[#0d131d] p-4">
                  {aiAdvice ? (
                    <p className="whitespace-pre-wrap text-sm leading-6 text-[#c2cad6]">{aiAdvice}</p>
                  ) : (
                    <p className="text-sm leading-6 text-[#7f8a9c]">
                      The recommendation will suggest which games to play before or after {selectedGame.title}, plus a few tips for improving.
                    </p>
                  )}
                </div>
              </aside>
            </section>
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
