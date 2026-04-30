import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { levelFromXP } from "@/lib/utils";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

interface XPBody {
  xpAmount?: number;
  milestoneType?: string;
  milestoneValue?: string;
}

export async function POST(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { xpAmount = 0, milestoneType = "xp", milestoneValue = "" } = (await req.json()) as XPBody;
  const supabase = getSupabaseAdmin();
  const { data: user } = await supabase.from("users").select("xp_total").eq("id", userId).single();
  const currentXP = typeof user?.xp_total === "number" ? user.xp_total : 0;
  const newXP = currentXP + Math.max(0, xpAmount);
  const newLevel = Math.min(levelFromXP(newXP), 100);

  const { error } = await supabase.from("users").update({ xp_total: newXP, level: newLevel }).eq("id", userId);
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  await supabase.from("learning_milestones").insert({
    user_id: userId,
    milestone_type: milestoneType,
    milestone_value: milestoneValue,
    xp_awarded: xpAmount,
  });

  return NextResponse.json({ newXP, newLevel });
}
