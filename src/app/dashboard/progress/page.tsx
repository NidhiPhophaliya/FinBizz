import { auth } from "@clerk/nextjs/server";
import { ProgressBar } from "@/components/ui/ProgressBar";
import { flashcards } from "@/data/flashcards";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

interface UserRow {
  xp_total: number;
  level: number;
  streak_days: number;
  learning_goals: string[] | null;
}

interface CountResult {
  count: number | null;
}

export default async function ProgressPage() {
  const { userId } = await auth();
  const supabase = getSupabaseAdmin();
  let user: UserRow = { xp_total: 0, level: 1, streak_days: 0, learning_goals: [] };
  let mastered: CountResult = { count: 0 };
  let games: CountResult = { count: 0 };
  let gameHistory: { game_name: string; score: number; outcome: string | null; played_at: string }[] = [];
  let progressRows: { deck: string; status: string }[] = [];

  if (userId) {
    const [userRes, masteredRes, gamesRes, historyRes, progressRes] = await Promise.all([
      supabase.from("users").select("xp_total, level, streak_days, learning_goals").eq("id", userId).single(),
      supabase.from("flashcard_progress").select("*", { count: "exact", head: true }).eq("user_id", userId).eq("status", "mastered"),
      supabase.from("game_sessions").select("*", { count: "exact", head: true }).eq("user_id", userId),
      supabase.from("game_sessions").select("game_name, score, outcome, played_at").eq("user_id", userId).order("played_at", { ascending: false }).limit(10),
      supabase.from("flashcard_progress").select("deck, status").eq("user_id", userId),
    ]);
    user = (userRes.data as UserRow | null) ?? user;
    mastered = masteredRes;
    games = gamesRes;
    gameHistory = (historyRes.data ?? []) as typeof gameHistory;
    progressRows = (progressRes.data ?? []) as typeof progressRows;
  }

  const xpIntoLevel = user.xp_total % 100;
  const decks = Array.from(new Set(flashcards.map((card) => card.deck)));
  const gaps = decks
    .map((deck) => {
      const total = flashcards.filter((card) => card.deck === deck).length;
      const deckMastered = progressRows.filter((row) => row.deck === deck && row.status === "mastered").length;
      return { deck, total, mastered: deckMastered, percent: total ? (deckMastered / total) * 100 : 0 };
    })
    .filter((deck) => deck.percent < 60);

  return (
    <div className="h-full overflow-y-auto p-5 pb-[150px] md:pr-[320px]">
      <section className="rounded-lg border border-accent-border bg-bg-secondary p-5">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-sm font-bold text-accent-gold">Level {user.level}</p>
            <h1 className="text-3xl font-bold text-white">My Progress</h1>
          </div>
          <div className="font-mono text-2xl font-bold text-accent-green">{user.xp_total} XP</div>
        </div>
        <div className="mt-5">
          <ProgressBar value={xpIntoLevel} />
          <p className="mt-2 text-sm text-text-muted">{100 - xpIntoLevel} XP to next level</p>
        </div>
      </section>

      <section className="mt-5 grid gap-4 md:grid-cols-4">
        {[
          ["📚", "Flashcards Mastered", mastered.count ?? 0],
          ["🎮", "Games Played", games.count ?? 0],
          ["🔥", "Day Streak", user.streak_days],
          ["⏱", "Time Learning", `${Math.max(0, (games.count ?? 0) * 8)} min`],
        ].map(([icon, label, value]) => (
          <div key={label} className="rounded-lg border border-accent-border bg-bg-secondary p-4">
            <div className="text-2xl">{icon}</div>
            <div className="mt-2 text-sm text-text-muted">{label}</div>
            <div className="font-mono text-2xl font-bold text-white">{value}</div>
          </div>
        ))}
      </section>

      <section className="mt-5 grid gap-5 lg:grid-cols-2">
        <div className="rounded-lg border border-accent-border bg-bg-secondary p-5">
          <h2 className="mb-4 text-xl font-bold text-white">Flashcard Progress</h2>
          <div className="space-y-4">
            {decks.map((deck) => {
              const item = gaps.find((gap) => gap.deck === deck) ?? {
                deck,
                total: flashcards.filter((card) => card.deck === deck).length,
                mastered: progressRows.filter((row) => row.deck === deck && row.status === "mastered").length,
                percent: 0,
              };
              return (
                <div key={deck}>
                  <div className="mb-1 flex justify-between text-sm">
                    <span className="capitalize text-text-muted">{deck}</span>
                    <span className="text-white">{item.mastered}/{item.total}</span>
                  </div>
                  <ProgressBar value={item.percent} />
                </div>
              );
            })}
          </div>
        </div>

        <div className="rounded-lg border border-accent-border bg-bg-secondary p-5">
          <h2 className="mb-4 text-xl font-bold text-white">Knowledge Gap Analysis</h2>
          {gaps.slice(0, 3).map((gap) => (
            <div key={gap.deck} className="mb-3 rounded-lg bg-bg-tertiary p-3 text-sm text-text-muted">
              Review the <span className="font-bold capitalize text-white">{gap.deck}</span> deck. You have mastered {gap.mastered} of {gap.total} cards.
            </div>
          ))}
          {gaps.length === 0 ? <p className="text-text-muted">No major gaps detected yet. Keep the streak alive.</p> : null}
        </div>
      </section>

      <section className="mt-5 rounded-lg border border-accent-border bg-bg-secondary p-5">
        <h2 className="mb-4 text-xl font-bold text-white">Game History</h2>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[560px] text-left text-sm">
            <thead className="text-text-muted">
              <tr>
                <th className="py-2">Game</th>
                <th>Score</th>
                <th>Outcome</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {gameHistory.map((session) => (
                <tr key={`${session.game_name}-${session.played_at}`} className="border-t border-accent-border">
                  <td className="py-3 text-white">{session.game_name}</td>
                  <td className="font-mono text-accent-green">{session.score}</td>
                  <td className="text-text-muted">{session.outcome}</td>
                  <td className="text-text-muted">{new Date(session.played_at).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
