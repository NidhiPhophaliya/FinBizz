import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { levelFromXP } from "@/lib/utils";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

interface GameSessionBody {
  gameName?: string;
  score?: number;
  durationSeconds?: number;
  roundsPlayed?: number;
  outcome?: "win" | "loss" | "incomplete";
  metadata?: Record<string, unknown>;
}

export async function POST(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  const body = (await req.json()) as GameSessionBody;
  const supabase = getSupabaseAdmin();
  const score = body.score ?? 0;
  const xp = Math.max(25, Math.min(100, Math.round(score / 15))) + (body.outcome === "win" ? 50 : 0);

  const { error } = await supabase.from("game_sessions").insert({
    user_id: userId,
    game_name: body.gameName ?? "game",
    score,
    duration_seconds: body.durationSeconds ?? 0,
    rounds_played: body.roundsPlayed ?? 0,
    outcome: body.outcome ?? "incomplete",
    metadata: body.metadata ?? {},
  });
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  const { data: user } = await supabase.from("users").select("xp_total").eq("id", userId).single();
  const nextXP = (typeof user?.xp_total === "number" ? user.xp_total : 0) + xp;
  await supabase.from("users").update({ xp_total: nextXP, level: levelFromXP(nextXP) }).eq("id", userId);
  await supabase.from("learning_milestones").insert({
    user_id: userId,
    milestone_type: "game_completed",
    milestone_value: body.gameName ?? "game",
    xp_awarded: xp,
  });

  return NextResponse.json({ success: true, xpAwarded: xp });
}
