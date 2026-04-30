import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

const SYSTEM_PROMPT = `You are FinLit AI, a friendly and knowledgeable financial literacy assistant.
Explain financial concepts clearly, avoid specific investment advice, and keep answers concise.
Always include one practical takeaway.`;

interface ChatMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

interface ChatBody {
  message?: string;
  sessionId?: string;
  history?: ChatMessage[];
}

export async function POST(req: Request) {
  const { userId } = await auth();

  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { message = "", sessionId, history = [] } =
    (await req.json()) as ChatBody;

  const sid = sessionId ?? crypto.randomUUID();

  const apiKey = process.env.HUGGINGFACE_API_KEY;

  // 🔥 Primary + fallback models
  const PRIMARY_MODEL =
    "mmistralai/Mistral-7B-Instruct-v0.2";
  const FALLBACK_MODEL = "google/gemma-2b-it";

  let reply =
    "AI is not configured yet. Practical takeaway: add HUGGINGFACE_API_KEY in .env.local.";

  async function callModel(model: string) {
    const res = await fetch(
      "https://router.huggingface.co/v1/chat/completions",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model,
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            ...history.slice(-8),
            { role: "user", content: message },
          ],
          max_tokens: 800,
          temperature: 0.7,
        }),
      }
    );

    if (!res.ok) {
      throw new Error("Model request failed");
    }

    const data = await res.json();
    return data?.choices?.[0]?.message?.content;
  }

  if (apiKey) {
    try {
      // 🔹 Try primary model (Mistral)
      reply = await callModel(PRIMARY_MODEL);

      // 🔹 If empty, fallback
      if (!reply) {
        reply = await callModel(FALLBACK_MODEL);
      }
    } catch {
      try {
        // 🔹 Retry with fallback model
        reply = await callModel(FALLBACK_MODEL);
      } catch {
        reply =
          "The AI service is temporarily unavailable. Practical takeaway: explore flashcards while it recovers.";
      }
    }
  }

  const supabase = getSupabaseAdmin();

  // 🧠 Save chat history
  await supabase.from("ai_chat_history").insert([
    {
      user_id: userId,
      session_id: sid,
      role: "user",
      content: message,
      model_used: PRIMARY_MODEL,
    },
    {
      user_id: userId,
      session_id: sid,
      role: "assistant",
      content: reply,
      model_used: PRIMARY_MODEL,
    },
  ]);

  // 🎯 XP milestone (first message only)
  if (history.length === 0) {
    await supabase.from("learning_milestones").insert({
      user_id: userId,
      milestone_type: "ai_chat",
      milestone_value: sid,
      xp_awarded: 5,
    });
  }

  return NextResponse.json({
    reply,
    sessionId: sid,
  });
}