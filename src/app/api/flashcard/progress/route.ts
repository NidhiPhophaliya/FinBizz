import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

interface FlashcardBody {
  cardId?: string;
  deck?: string;
  correct?: boolean;
}

export async function POST(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  const body = (await req.json()) as FlashcardBody;
  const supabase = getSupabaseAdmin();
  const cardId = body.cardId ?? "";
  const deck = body.deck ?? "basics";
  const { data: previous } = await supabase
    .from("flashcard_progress")
    .select("times_seen, times_correct")
    .eq("user_id", userId)
    .eq("card_id", cardId)
    .single();
  const timesSeen = (typeof previous?.times_seen === "number" ? previous.times_seen : 0) + 1;
  const timesCorrect = (typeof previous?.times_correct === "number" ? previous.times_correct : 0) + (body.correct ? 1 : 0);
  const status = timesCorrect >= 5 ? "mastered" : timesSeen > 1 ? "learning" : "new";

  await supabase.from("flashcard_progress").upsert({
    user_id: userId,
    card_id: cardId,
    deck,
    status,
    times_seen: timesSeen,
    times_correct: timesCorrect,
    last_seen_at: new Date().toISOString(),
  });

  await supabase.from("learning_milestones").insert({
    user_id: userId,
    milestone_type: status === "mastered" ? "flashcard_mastered" : "flashcard_seen",
    milestone_value: cardId,
    xp_awarded: status === "mastered" ? 10 : 2,
  });

  return NextResponse.json({ success: true, status, timesSeen, timesCorrect });
}
