"use client";

import useSWR from "swr";
import { Skeleton } from "@/components/ui/Skeleton";

interface LeaderboardRow {
  display_name: string | null;
  avatar_url: string | null;
  score: number;
  played_at: string;
}

async function fetchRows(url: string): Promise<LeaderboardRow[]> {
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error("Unable to load leaderboard");
  }
  return res.json() as Promise<LeaderboardRow[]>;
}

export default function Leaderboard({ game = "budget_blitz" }: { game?: string }) {
  const { data, isLoading } = useSWR(`/api/leaderboard?game=${game}`, fetchRows);

  if (isLoading) {
    return <Skeleton className="h-64" />;
  }

  return (
    <div className="p-5">
      <h2 className="mb-4 text-xl font-bold text-white">Leaderboard</h2>
      <div className="overflow-hidden rounded-lg border border-accent-border">
        {(data ?? []).map((row, index) => (
          <div key={`${row.display_name}-${row.played_at}`} className="grid grid-cols-[48px_1fr_90px] border-b border-accent-border p-3 text-sm">
            <span className="font-mono text-accent-gold">#{index + 1}</span>
            <span className="text-white">{row.display_name ?? "FinLit Player"}</span>
            <span className="font-mono text-accent-green">{row.score}</span>
          </div>
        ))}
        {data?.length === 0 ? <div className="p-4 text-text-muted">No scores yet.</div> : null}
      </div>
    </div>
  );
}
