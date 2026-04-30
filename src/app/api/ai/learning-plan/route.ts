import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  const body = (await req.json()) as { gaps?: string[]; goals?: string[] };
  const gaps = body.gaps?.length ? body.gaps : ["investing basics", "budgeting", "macro signals"];
  const goals = body.goals?.length ? body.goals : ["build confidence"];

  return NextResponse.json({
    plan: [
      `Review ${gaps[0]} flashcards for 10 minutes.`,
      `Play Budget Blitz once and compare your allocation to 50/20/20/10.`,
      `Ask FinLit AI one question connected to: ${goals[0]}.`,
    ],
  });
}
