import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

interface OnboardingBody {
  email?: string;
  displayName?: string;
  avatarUrl?: string;
  knowledgeLevel?: number;
  learningGoals?: string[];
  gamePreference?: string;
}

export async function POST(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const body = (await req.json()) as OnboardingBody;
  const { error } = await getSupabaseAdmin()
    .from("users")
    .upsert({
      id: userId,
      email: body.email ?? "",
      display_name: body.displayName ?? "FinLit Learner",
      avatar_url: body.avatarUrl ?? null,
      financial_knowledge_level: body.knowledgeLevel ?? 1,
      learning_goals: body.learningGoals ?? [],
      game_preference: body.gamePreference ?? null,
      onboarding_completed: true,
      last_login_at: new Date().toISOString(),
    });

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
  return NextResponse.json({ success: true });
}
