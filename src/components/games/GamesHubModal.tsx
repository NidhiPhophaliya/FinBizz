"use client";

import { useUser } from "@clerk/nextjs";
import { motion } from "framer-motion";
import { X } from "lucide-react";
import { useEffect, useState } from "react";
import AlphaGame from "@/components/games/AlphaGame";
import BudgetBlitzGame from "@/components/games/BudgetBlitzGame";
import CompoundClickerGame from "@/components/games/CompoundClickerGame";
import GameCard from "@/components/games/GameCard";
import Leaderboard from "@/components/games/Leaderboard";
import MarketMayhemGame from "@/components/games/MarketMayhemGame";
import PaperTradingGame from "@/components/games/PaperTradingGame";
import { Button } from "@/components/ui/Button";
import { ErrorBoundary } from "@/components/ui/ErrorBoundary";
import { loadGameXp } from "@/lib/gamesXpStorage";
import { useDashboardStore } from "@/store/dashboardStore";

type View = "hub" | "alpha" | "budget" | "compound" | "mayhem" | "paper" | "leaderboard";

const games = [
  { view: "alpha" as View, icon: "💼", title: "Alpha", tagline: "Cashflow strategy board game embed.", difficulty: "Advanced", reward: "Up to 100 XP", accent: "#ffd780" },
  { view: "budget" as View, icon: "⚡", title: "Budget Blitz", tagline: "Handle life events and build a balanced monthly plan.", difficulty: "Beginner", reward: "Up to 75 XP", accent: "#42a5f5" },
  { view: "compound" as View, icon: "📈", title: "Compound Clicker", tagline: "Watch wealth curves bend as compounding accelerates.", difficulty: "Beginner", reward: "Up to 50 XP", accent: "#7ee4e3" },
  { view: "mayhem" as View, icon: "📰", title: "Market Mayhem", tagline: "Read news, rebalance sectors, and survive volatility.", difficulty: "Intermediate", reward: "Up to 100 XP", accent: "#99ff88" },
  { view: "paper" as View, icon: "💹", title: "Paper Trader", tagline: "Trade a virtual portfolio through market shocks.", difficulty: "Intermediate", reward: "Up to 150 XP", accent: "#00d4ff" },
];

export default function GamesHubModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const [view, setView] = useState<View>("hub");
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

    const localGameXp = loadGameXp(email);
    setUserXP(localGameXp?.totalXp ?? 0, localGameXp?.level ?? 1);
  }, [email, open, setUserXP]);

  if (!open) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-[100] overflow-y-auto bg-bg-primary">
      <motion.div
        className="min-h-screen p-4 md:p-8"
        style={{ background: "radial-gradient(ellipse at center, #222431 0%, #1d1f29 70%)" }}
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
      >
        <header className="relative mb-6 text-center">
          <h1 className="text-4xl font-bold text-accent-gold">🎮 GAMES HUB</h1>
          <p className="mt-2 text-text-muted">Learn finance by playing</p>
          <div className="absolute right-12 top-0 hidden rounded-full border border-accent-teal px-3 py-1 text-sm font-bold text-accent-teal md:block">
            LVL {userLevel} | {userXP} XP
          </div>
          <button
            className="absolute right-0 top-0 rounded-lg p-2 text-text-muted hover:bg-bg-tertiary hover:text-white"
            onClick={onClose}
            aria-label="Close games hub"
          >
            <X size={22} />
          </button>
        </header>

        {view !== "hub" ? (
          <div className="mb-4 flex gap-2">
            <Button variant="secondary" onClick={() => setView("hub")}>
              Back to Hub
            </Button>
            <Button variant="secondary" onClick={() => setView("leaderboard")}>
              Leaderboard
            </Button>
          </div>
        ) : null}

        {view === "hub" ? (
          <div className="mx-auto grid max-w-6xl gap-4 md:grid-cols-2 xl:grid-cols-5">
            {games.map((game) => (
              <GameCard key={game.title} {...game} onPlay={() => setView(game.view)} />
            ))}
            <Button variant="gold" className="md:col-span-2 xl:col-span-5" onClick={() => setView("leaderboard")}>
              View Leaderboard
            </Button>
          </div>
        ) : (
          <section className="mx-auto max-w-7xl overflow-hidden rounded-lg border border-accent-border bg-bg-secondary">
            <ErrorBoundary label="Game">
              {view === "alpha" ? <AlphaGame /> : null}
              {view === "budget" ? <BudgetBlitzGame /> : null}
              {view === "compound" ? <CompoundClickerGame /> : null}
              {view === "mayhem" ? <MarketMayhemGame /> : null}
              {view === "paper" ? <PaperTradingGame /> : null}
              {view === "leaderboard" ? <Leaderboard /> : null}
            </ErrorBoundary>
          </section>
        )}
      </motion.div>
    </div>
  );
}
