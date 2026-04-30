import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { levelFromXP } from "@/lib/utils";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

function dayKey(date: Date) {
  return Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate());
}

export async function POST() {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const supabase = getSupabaseAdmin();
  const { data: user } = await supabase
    .from("users")
    .select("last_login_at, streak_days, xp_total")
    .eq("id", userId)
    .single();

  const today = dayKey(new Date());
  const last = user?.last_login_at ? dayKey(new Date(user.last_login_at)) : null;
  const diffDays = last === null ? 999 : Math.round((today - last) / 86400000);
  const currentStreak = typeof user?.streak_days === "number" ? user.streak_days : 0;
  const streak = diffDays === 0 ? currentStreak : diffDays === 1 ? currentStreak + 1 : 1;
  const dailyXP = diffDays === 0 ? 0 : 10;
  const milestoneXP = streak === 7 ? 100 : streak === 30 ? 500 : 0;
  const xpTotal = (typeof user?.xp_total === "number" ? user.xp_total : 0) + dailyXP + milestoneXP;

  await supabase
    .from("users")
    .update({
      streak_days: streak,
      last_login_at: new Date().toISOString(),
      xp_total: xpTotal,
      level: levelFromXP(xpTotal),
    })
    .eq("id", userId);

  if (dailyXP || milestoneXP) {
    await supabase.from("learning_milestones").insert({
      user_id: userId,
      milestone_type: "daily_login",
      milestone_value: `${streak}`,
      xp_awarded: dailyXP + milestoneXP,
    });
  }

  return NextResponse.json({ streak, xpAwarded: dailyXP + milestoneXP, xpTotal });
}
