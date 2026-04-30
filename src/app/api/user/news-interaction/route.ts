import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

interface NewsInteractionBody {
  articleUrl?: string;
  headline?: string;
  category?: string;
  timeSpentSeconds?: number;
}

export async function POST(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  const body = (await req.json()) as NewsInteractionBody;
  const supabase = getSupabaseAdmin();

  await supabase.from("news_interactions").insert({
    user_id: userId,
    article_url: body.articleUrl ?? "",
    headline: body.headline ?? "",
    category: body.category ?? "markets",
    time_spent_seconds: body.timeSpentSeconds ?? 0,
  });

  if ((body.timeSpentSeconds ?? 0) >= 30) {
    await supabase.from("learning_milestones").insert({
      user_id: userId,
      milestone_type: "news_read",
      milestone_value: body.articleUrl ?? "",
      xp_awarded: 5,
    });
  }

  return NextResponse.json({ success: true });
}
