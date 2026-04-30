"use client";

import { useUser } from "@clerk/nextjs";
import { useReducer } from "react";
import { Button } from "@/components/ui/Button";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { budgetEvents } from "@/data/budgetEvents";
import { recordGameXp } from "@/lib/gamesXpStorage";
import { useDashboardStore } from "@/store/dashboardStore";
import { useToastStore } from "@/store/toastStore";

interface Allocation {
  needs: number;
  wants: number;
  savings: number;
  investments: number;
}

interface State {
  round: number;
  salary: number;
  events: typeof budgetEvents;
  allocation: Allocation;
  score: number;
  complete: boolean;
}

type Action =
  | { type: "allocate"; key: keyof Allocation; value: number }
  | { type: "next" }
  | { type: "restart" };

const ideal: Allocation = { needs: 50, wants: 20, savings: 20, investments: 10 };

function pickEvents(round: number) {
  return budgetEvents.slice((round * 3) % budgetEvents.length, (round * 3) % budgetEvents.length + 3);
}

function initialState(): State {
  return {
    round: 1,
    salary: 20000 + Math.floor(Math.random() * 180000),
    events: pickEvents(1),
    allocation: { needs: 50, wants: 20, savings: 20, investments: 10 },
    score: 0,
    complete: false,
  };
}

function roundScore(allocation: Allocation) {
  const distance = (Object.keys(ideal) as (keyof Allocation)[]).reduce(
    (total, key) => total + Math.abs(allocation[key] - ideal[key]),
    0,
  );
  return Math.max(0, Math.round(170 - distance * 2));
}

function reducer(state: State, action: Action): State {
  if (action.type === "allocate") {
    return { ...state, allocation: { ...state.allocation, [action.key]: action.value } };
  }
  if (action.type === "next") {
    const nextScore = state.score + roundScore(state.allocation);
    if (state.round >= 6) {
      return { ...state, score: nextScore, complete: true };
    }
    const nextRound = state.round + 1;
    return { ...state, round: nextRound, score: nextScore, salary: 20000 + Math.floor(Math.random() * 180000), events: pickEvents(nextRound) };
  }
  return initialState();
}

export default function BudgetBlitzGame() {
  const [state, dispatch] = useReducer(reducer, undefined, initialState);
  const { user } = useUser();
  const email = user?.primaryEmailAddress?.emailAddress;
  const setUserXP = useDashboardStore((store) => store.setUserXP);
  const pushToast = useToastStore((store) => store.pushToast);
  const totalExpenses = state.events.reduce((sum, event) => sum + event.cost, 0);
  const available = Math.max(0, state.salary - totalExpenses);

  const finish = async () => {
    const xp = Math.max(25, Math.min(75, Math.round(state.score / 12)));
    const res = await fetch("/api/games/session", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ gameName: "budget_blitz", score: state.score, roundsPlayed: 6, outcome: "win", metadata: { xp } }),
    });
    if (res.ok) {
      const data = (await res.json()) as { xpAwarded?: number };
      const xpAwarded = data.xpAwarded ?? 0;
      if (email && typeof data.xpAwarded === "number") {
        const localGameXp = recordGameXp(email, { gameName: "budget_blitz", xpAwarded, score: state.score });
        if (localGameXp) {
          setUserXP(localGameXp.totalXp, localGameXp.level);
        }
      }
      pushToast({ title: `🎉 +${xpAwarded} XP earned!` });
    } else {
      pushToast({ title: "Unable to save score", description: "Try again in a moment." });
    }
  };

  if (state.complete) {
    return (
      <div className="p-6 text-center">
        <h2 className="text-3xl font-bold text-white">Budget Blitz Complete</h2>
        <p className="mt-3 font-mono text-5xl font-bold text-accent-green">{state.score}/1000</p>
        <p className="mt-3 text-text-muted">Strong budgets leave room for needs, joy, safety, and future growth.</p>
        <div className="mt-6 flex justify-center gap-3">
          <Button onClick={() => void finish()}>Save Score</Button>
          <Button variant="secondary" onClick={() => dispatch({ type: "restart" })}>Play Again</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="grid gap-5 p-5 lg:grid-cols-[1fr_1.2fr]">
      <section className="rounded-lg border border-accent-border bg-bg-primary p-5">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-xl font-bold text-white">Budget Blitz</h2>
          <span className="text-sm text-accent-gold">Round {state.round} of 6</span>
        </div>
        <ProgressBar value={(state.round / 6) * 100} />
        <div className="mt-5 grid gap-3">
          <div className="rounded-lg bg-bg-tertiary p-3">
            <div className="text-xs text-text-muted">Monthly salary</div>
            <div className="font-mono text-2xl font-bold text-accent-green">₹{state.salary.toLocaleString()}</div>
          </div>
          <div className="rounded-lg bg-bg-tertiary p-3">
            <div className="text-xs text-text-muted">After life events</div>
            <div className="font-mono text-xl font-bold text-white">₹{available.toLocaleString()}</div>
          </div>
        </div>
        <div className="mt-5 space-y-2">
          {state.events.map((event) => (
            <div key={event.id} className="rounded-lg border border-accent-border bg-bg-tertiary p-3">
              <div className="font-bold text-white">{event.title}</div>
              <div className="text-sm text-text-muted">₹{event.cost.toLocaleString()}</div>
            </div>
          ))}
        </div>
      </section>
      <section className="rounded-lg border border-accent-border bg-bg-primary p-5">
        <h3 className="mb-4 font-bold text-white">Allocation</h3>
        {(Object.keys(state.allocation) as (keyof Allocation)[]).map((key) => (
          <label key={key} className="mb-4 block">
            <div className="mb-2 flex justify-between text-sm">
              <span className="capitalize text-text-muted">{key}</span>
              <span className="font-mono text-white">{state.allocation[key]}%</span>
            </div>
            <input
              className="w-full accent-accent-gold"
              type="range"
              min={0}
              max={70}
              value={state.allocation[key]}
              onChange={(event) => dispatch({ type: "allocate", key, value: Number(event.target.value) })}
            />
          </label>
        ))}
        <p className="rounded-lg bg-bg-tertiary p-3 text-sm text-text-muted">
          AI feedback: Aim near 50/20/20/10. You are learning to balance survival, comfort, resilience, and growth.
        </p>
        <Button className="mt-5 w-full" onClick={() => dispatch({ type: "next" })}>
          Lock Round
        </Button>
      </section>
    </div>
  );
}
