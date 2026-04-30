import { NextResponse } from "next/server";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

export async function GET(req: Request) {
  const url = new URL(req.url);
  const game = url.searchParams.get("game") ?? "budget_blitz";
  const { data, error } = await getSupabaseAdmin()
    .from("game_sessions")
    .select("score, played_at, users(display_name, avatar_url)")
    .eq("game_name", game)
    .order("score", { ascending: false })
    .limit(10);

  if (error) {
    return NextResponse.json([], { status: 200 });
  }

  const rows = (data ?? []).map((row) => {
    const user = Array.isArray(row.users) ? row.users[0] : row.users;
    return {
      display_name: user?.display_name ?? "FinLit Player",
      avatar_url: user?.avatar_url ?? null,
      score: row.score,
      played_at: row.played_at,
    };
  });

  return NextResponse.json(rows);
}
