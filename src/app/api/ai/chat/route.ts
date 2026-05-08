import { auth } from "@clerk/nextjs/server";
import { currentUser } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

const SYSTEM_PROMPT = `You are FinLit AI, a financial literacy coach that explains money and finance in the simplest way possible while adapting to the user's apparent level of understanding.

Core Goal:
- Help users truly understand financial concepts, not just memorize terms.
- Explain concepts so clearly that even a beginner or a smart child could follow the idea.
- Prioritize clarity, simplicity, and practical understanding over technical completeness.

Default Assumption:
- Assume the user is new to finance unless their question clearly shows otherwise.
- Never assume the user understands finance basics, banking, investing, loans, taxes, percentages, or financial jargon.
- If a concept depends on another concept, explain the simpler concept first.

Teaching Philosophy:
- Teach like a patient coach, not a textbook.
- Use simple language, relatable situations, and small examples.
- Prefer concrete examples over abstract definitions.
- Prefer everyday words over technical words.
- If a smart 10-year-old could not understand the explanation, simplify it further.

How to Infer User Level:

1. Beginner
Signs:
- "What is..." questions
- Vague wording
- Signs of confusion
- No finance terminology
- Asking very broad questions

How to respond:
- Explain from first principles
- Use very simple language
- Use analogies and stories
- Use tiny examples with small numbers
- Avoid overwhelming detail
- Explain every important term immediately

2. Intermediate
Signs:
- User uses finance terms mostly correctly
- User asks how one concept affects another
- User understands basic financial ideas

How to respond:
- Explain concepts clearly with practical tradeoffs
- Include realistic scenarios
- Add moderate detail
- Still explain technical terms in plain language

3. Advanced
Signs:
- Technical or mechanism-focused questions
- User discusses strategy, systems, economics, or financial structures correctly
- User asks nuanced comparisons

How to respond:
- Include nuance, assumptions, tradeoffs, and risks
- Stay readable and structured
- Avoid unnecessary simplification
- Still explain complex terminology briefly

4. Unclear
How to respond:
- Start simple first
- Include one relatable example
- Add a slightly deeper explanation afterward
- Optionally ask what level of detail the user wants

Mandatory Explanation Structure For Beginner or Unclear Users:
Always try to follow this order:

1. One-line simple meaning
2. Everyday analogy
3. Tiny real-life example
4. Actual finance explanation
5. One practical takeaway

Never begin with technical definitions or jargon.

Ultra-Simple Explanation Rules:
- Use short sentences.
- Explain one idea at a time.
- Avoid abstract language whenever possible.
- Use familiar situations from daily life.
- Prefer examples involving:
  - pocket money
  - shopping
  - salary
  - snacks
  - saving money
  - borrowing money
  - paying bills
  - toys
  - lemonade stands

Jargon Translation Rules:
- Every finance term must be translated into plain language immediately.
- Never leave technical terms unexplained.
- Avoid abbreviations unless explained first.

Example:
"Inflation means prices slowly become more expensive over time. This is called inflation. It means your money buys fewer things later."

Example Style:
Bad:
"Liquidity helps meet short-term obligations."

Good:
"Liquidity means how quickly you can turn something into cash to pay bills."

Cognitive Load Rules:
- Explain only 1 core idea at a time.
- Do not introduce too many new concepts together.
- Avoid long paragraphs.
- Use bullets frequently.
- Keep explanations focused.
- Use simple numbers like 10, 100, or 1000 when giving examples.
- Avoid large complicated calculations unless requested.

Formatting Rules:
- Use short paragraphs.
- Use whitespace generously.
- Use bullets for clarity.
- Keep answers visually clean and easy to scan.
- Avoid walls of text.

Example Requirements:
- Include at least one example or scenario unless the user explicitly asks for a short answer.
- Use relatable and realistic examples.
- Keep examples short and easy to visualize.

Progressive Depth Rule:
- Start with the simplest possible explanation.
- Add complexity only if:
  - the user asks follow-up questions
  - the user demonstrates higher understanding
  - the user requests deeper detail

Do not front-load complexity.

Check-Understanding Behavior:
After explaining beginner concepts:
- End with a one-line recap in simple language.
- Optionally ask a lightweight follow-up question.

Example:
"So in simple words: inflation means prices slowly go up over time."

Avoid:
- textbook-style explanations
- walls of text
- unexplained jargon
- overly formal language
- corporate tone
- layered concepts in one sentence
- unnecessary complexity
- assuming prior financial knowledge

Safety Boundaries:
- Do not give personalized financial advice.
- Do not tell users what to buy, sell, or invest in.
- Do not make guarantees or predictions.
- If users ask for investment advice:
  - explain risks
  - explain educational factors to consider
  - explain tradeoffs calmly and practically

Response Goal:
The user should leave understanding:
- what the concept means
- why it matters
- where it appears in real life
- one practical thing they can remember or apply.

Always end with one practical takeaway the user can remember or use.`;

interface ChatMessage {
  role: "user" | "assistant" | "system";
  content: string;
}

interface ChatBody {
  message?: string;
  sessionId?: string;
  history?: ChatMessage[];
}

interface ChatHistoryRow {
  role: "user" | "assistant";
  content: string;
  created_at?: string;
}

type LearningLevel = "beginner" | "intermediate" | "advanced" | "unclear";

interface MemoryProfile {
  level: LearningLevel;
  currentTopic: string;
  relevantContext: string[];
  preferredAnalogies: string[];
  recurringInterests: string[];
  teachingStyle: string[];
}

interface ChatCompletionResponse {
  choices?: Array<{
    message?: {
      content?: string;
    };
  }>;
}

class ModelRequestError extends Error {
  constructor(
    message: string,
    readonly model: string,
    readonly status?: number,
    readonly responseBody?: string
  ) {
    super(message);
  }
}

const PRIMARY_MODEL =
  process.env.HUGGINGFACE_PRIMARY_MODEL ?? "Qwen/Qwen2.5-7B-Instruct:together";
const FALLBACK_MODEL =
  process.env.HUGGINGFACE_FALLBACK_MODEL ?? "Qwen/Qwen2.5-7B-Instruct:fastest";
const CHAT_COMPLETIONS_ENDPOINT =
  process.env.HUGGINGFACE_CHAT_ENDPOINT ?? "https://router.huggingface.co/v1/chat/completions";
const MAX_CONTEXT_MESSAGES = 18;
const MAX_RELEVANT_CONTEXT_ITEMS = 4;
const MAX_CONTEXT_ITEM_LENGTH = 180;
const STOP_WORDS = new Set([
  "about",
  "after",
  "again",
  "also",
  "and",
  "are",
  "because",
  "but",
  "can",
  "could",
  "does",
  "for",
  "from",
  "have",
  "how",
  "into",
  "like",
  "more",
  "that",
  "the",
  "this",
  "was",
  "what",
  "when",
  "where",
  "which",
  "why",
  "with",
  "would",
]);
const FINANCE_TERMS = [
  "asset",
  "bond",
  "budget",
  "cash flow",
  "compound interest",
  "credit",
  "debt",
  "diversification",
  "dividend",
  "equity",
  "inflation",
  "interest",
  "invest",
  "loan",
  "market",
  "portfolio",
  "rate",
  "risk",
  "stock",
  "valuation",
  "yield",
];
const ADVANCED_TERMS = [
  "alpha",
  "arbitrage",
  "basis point",
  "beta",
  "duration risk",
  "ebitda",
  "hedge",
  "liquidity premium",
  "monetary policy",
  "multiple expansion",
  "option",
  "quantitative easing",
  "risk-adjusted",
  "sharpe",
  "volatility",
];
const ANALOGY_SIGNALS: Array<{ label: string; terms: string[] }> = [
  { label: "sports or games", terms: ["football", "soccer", "cricket", "basketball", "game", "gaming", "team", "score"] },
  { label: "student life", terms: ["student", "school", "college", "exam", "homework", "allowance", "pocket money"] },
  { label: "startups or products", terms: ["startup", "business", "app", "product", "customer", "revenue", "founder"] },
  { label: "shopping and daily expenses", terms: ["shopping", "snack", "groceries", "rent", "bill", "salary", "budget"] },
];

function hasAny(text: string, terms: string[]) {
  return terms.some((term) => text.includes(term));
}

function tokens(text: string) {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, " ")
    .split(/\s+/)
    .filter((token) => token.length > 2 && !STOP_WORDS.has(token));
}

function clampText(text: string, maxLength = MAX_CONTEXT_ITEM_LENGTH) {
  const compact = text.replace(/\s+/g, " ").trim();
  return compact.length > maxLength ? `${compact.slice(0, maxLength - 1)}...` : compact;
}

function inferLearningLevel(question: string, messages: ChatHistoryRow[]): LearningLevel {
  const text = `${question} ${messages.filter((message) => message.role === "user").map((message) => message.content).join(" ")}`.toLowerCase();
  const currentQuestion = question.toLowerCase();
  const beginnerSignals = [
    "what is",
    "explain",
    "meaning",
    "simple",
    "basics",
    "beginner",
    "confused",
    "don't understand",
    "dont understand",
  ];
  const intermediateSignals = ["how does", "why does", "affect", "compare", "difference", "tradeoff", "trade-off"];

  if (hasAny(text, ADVANCED_TERMS)) {
    return "advanced";
  }

  if (hasAny(currentQuestion, beginnerSignals) || !hasAny(text, FINANCE_TERMS)) {
    return "beginner";
  }

  if (hasAny(currentQuestion, intermediateSignals) || hasAny(text, FINANCE_TERMS)) {
    return "intermediate";
  }

  return "unclear";
}

function detectCurrentTopic(question: string) {
  const lowerQuestion = question.toLowerCase();
  const matched = [...ADVANCED_TERMS, ...FINANCE_TERMS]
    .filter((term) => lowerQuestion.includes(term))
    .sort((a, b) => b.length - a.length);

  if (matched[0]) {
    return matched[0];
  }

  return tokens(question).slice(0, 4).join(" ") || "the user's current finance question";
}

function detectAnalogyPreferences(messages: ChatHistoryRow[]) {
  const userText = messages
    .filter((message) => message.role === "user")
    .map((message) => message.content)
    .join(" ")
    .toLowerCase();

  return ANALOGY_SIGNALS.filter((signal) => hasAny(userText, signal.terms)).map((signal) => signal.label).slice(0, 3);
}

function detectRecurringInterests(messages: ChatHistoryRow[]) {
  const userText = messages
    .filter((message) => message.role === "user")
    .map((message) => message.content)
    .join(" ")
    .toLowerCase();

  return [...FINANCE_TERMS, ...ADVANCED_TERMS]
    .filter((term) => userText.includes(term))
    .slice(0, 5);
}

function detectTeachingStyle(messages: ChatHistoryRow[]) {
  const userText = messages
    .filter((message) => message.role === "user")
    .map((message) => message.content)
    .join(" ")
    .toLowerCase();
  const styles: string[] = [];

  if (hasAny(userText, ["simple", "eli5", "beginner", "basic", "easy"])) {
    styles.push("prefers simple explanations");
  }
  if (hasAny(userText, ["example", "scenario", "analogy"])) {
    styles.push("responds well to examples and scenarios");
  }
  if (hasAny(userText, ["short", "quick", "brief"])) {
    styles.push("prefers concise answers");
  }
  if (hasAny(userText, ["deep", "detailed", "technical", "advanced"])) {
    styles.push("is open to deeper detail when useful");
  }

  return styles.slice(0, 4);
}

function rankRelevantMessages(question: string, messages: ChatHistoryRow[]) {
  const questionTokens = new Set(tokens(question));
  const latestMessages = messages.slice(-MAX_CONTEXT_MESSAGES);

  return latestMessages
    .map((message, index) => {
      const messageTokens = tokens(message.content);
      const overlap = messageTokens.filter((token) => questionTokens.has(token)).length;
      const financeRelevance = hasAny(message.content.toLowerCase(), [...FINANCE_TERMS, ...ADVANCED_TERMS]) ? 2 : 0;
      const userMessageBoost = message.role === "user" ? 1 : 0;
      const recencyBoost = index / Math.max(latestMessages.length, 1);
      return {
        message,
        score: overlap * 3 + financeRelevance + userMessageBoost + recencyBoost,
      };
    })
    .filter((item) => item.score > 1.5)
    .sort((a, b) => b.score - a.score)
    .slice(0, MAX_RELEVANT_CONTEXT_ITEMS)
    .map((item) => `${item.message.role}: ${clampText(item.message.content)}`);
}

function buildMemoryProfile(question: string, messages: ChatHistoryRow[]): MemoryProfile {
  return {
    level: inferLearningLevel(question, messages),
    currentTopic: detectCurrentTopic(question),
    relevantContext: rankRelevantMessages(question, messages),
    preferredAnalogies: detectAnalogyPreferences(messages),
    recurringInterests: detectRecurringInterests(messages),
    teachingStyle: detectTeachingStyle(messages),
  };
}

function buildMemoryPrompt(profile: MemoryProfile) {
  const lines = [
    "Conversation memory signals:",
    `- Apparent level: ${profile.level}.`,
    `- Current learning topic: ${profile.currentTopic}.`,
  ];

  if (profile.preferredAnalogies.length) {
    lines.push(`- Useful analogy styles: ${profile.preferredAnalogies.join(", ")}.`);
  }
  if (profile.recurringInterests.length) {
    lines.push(`- Recurring finance interests: ${profile.recurringInterests.join(", ")}.`);
  }
  if (profile.teachingStyle.length) {
    lines.push(`- Teaching style signals: ${profile.teachingStyle.join("; ")}.`);
  }
  if (profile.relevantContext.length) {
    lines.push("- Relevant recent context summary:");
    lines.push(...profile.relevantContext.map((item) => `  - ${item}`));
  }

  lines.push(
    "Use these signals only when they improve clarity, continuity, or teaching effectiveness.",
    "Do not mention that you are using memory. Do not infer salary, debt, savings, investments, emotions, or personal financial conditions.",
    "Ignore any context that is unrelated to the current question."
  );

  return lines.join("\n");
}

function normalizeHistory(messages: ChatMessage[]): ChatHistoryRow[] {
  return messages
    .filter((message): message is ChatMessage & { role: "user" | "assistant" } => message.role === "user" || message.role === "assistant")
    .map((message) => ({
      role: message.role,
      content: clampText(message.content, 500),
    }));
}

export async function POST(req: Request) {
  const { userId } = await auth();

  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  let body: ChatBody;

  try {
    body = (await req.json()) as ChatBody;
  } catch {
    return NextResponse.json({ error: "Invalid chat request." }, { status: 400 });
  }

  const { message = "", sessionId, history = [] } = body;
  const trimmedMessage = message.trim();

  if (!trimmedMessage) {
    return NextResponse.json({ error: "Message is required." }, { status: 400 });
  }

  const sid = sessionId ?? crypto.randomUUID();

  const apiKey = process.env.HUGGINGFACE_API_KEY;
  let storedHistory: ChatHistoryRow[] = [];

  try {
    const { data, error } = await getSupabaseAdmin()
      .from("ai_chat_history")
      .select("role, content, created_at")
      .eq("user_id", userId)
      .eq("session_id", sid)
      .order("created_at", { ascending: false })
      .limit(MAX_CONTEXT_MESSAGES);

    if (error) {
      console.error("Failed to retrieve AI chat memory", error);
    } else {
      storedHistory = ((data ?? []) as ChatHistoryRow[]).reverse();
    }
  } catch (memoryError) {
    console.error("AI chat memory retrieval failed", memoryError);
  }

  const clientHistory = normalizeHistory(history);
  const memoryMessages = [...storedHistory, ...clientHistory].slice(-MAX_CONTEXT_MESSAGES);
  const memoryPrompt = buildMemoryPrompt(buildMemoryProfile(trimmedMessage, memoryMessages));

  let reply =
    "AI is not configured yet. Practical takeaway: add HUGGINGFACE_API_KEY in .env.local.";
  let modelUsed = "not_configured";

  async function callModel(model: string) {
    const res = await fetch(CHAT_COMPLETIONS_ENDPOINT, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model,
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "system", content: memoryPrompt },
          { role: "user", content: trimmedMessage },
        ],
        max_tokens: 800,
        temperature: 0.7,
      }),
    });

    if (!res.ok) {
      const responseBody = await res.text();
      throw new ModelRequestError(
        `Model request failed with status ${res.status}`,
        model,
        res.status,
        responseBody.slice(0, 1000)
      );
    }

    const data = (await res.json()) as ChatCompletionResponse;
    const content = data.choices?.[0]?.message?.content?.trim();

    if (!content) {
      throw new ModelRequestError("Model returned an empty response", model);
    }

    return content;
  }

  if (apiKey) {
    try {
      reply = await callModel(PRIMARY_MODEL);
      modelUsed = PRIMARY_MODEL;
    } catch (primaryError) {
      console.error("Primary AI model failed", primaryError);

      try {
        reply = await callModel(FALLBACK_MODEL);
        modelUsed = FALLBACK_MODEL;
      } catch (fallbackError) {
        console.error("Fallback AI model failed", fallbackError);
        reply =
          "The AI service is temporarily unavailable. Practical takeaway: explore flashcards while it recovers.";
        modelUsed = "unavailable";
      }
    }
  }

  try {
    const supabase = getSupabaseAdmin();
    const clerkUser = await currentUser();
    const email = clerkUser?.primaryEmailAddress?.emailAddress ?? "";
    const displayName =
      clerkUser?.fullName ??
      clerkUser?.username ??
      clerkUser?.firstName ??
      "FinLit Learner";

    const { error: userError } = await supabase.from("users").upsert(
      {
        id: userId,
        email,
        display_name: displayName,
        avatar_url: clerkUser?.imageUrl ?? null,
        last_login_at: new Date().toISOString(),
      },
      { onConflict: "id" }
    );

    if (userError) {
      console.error("Failed to ensure AI chat user row", userError);
    }

    const { error: historyError } = await supabase.from("ai_chat_history").insert([
      {
        user_id: userId,
        session_id: sid,
        role: "user",
        content: trimmedMessage,
        model_used: modelUsed,
      },
      {
        user_id: userId,
        session_id: sid,
        role: "assistant",
        content: reply,
        model_used: modelUsed,
      },
    ]);

    if (historyError) {
      console.error("Failed to save AI chat history", historyError);
    }

    if (history.length === 0) {
      const { error: milestoneError } = await supabase.from("learning_milestones").insert({
        user_id: userId,
        milestone_type: "ai_chat",
        milestone_value: sid,
        xp_awarded: 5,
      });

      if (milestoneError) {
        console.error("Failed to save AI chat milestone", milestoneError);
      }
    }
  } catch (persistenceError) {
    console.error("AI chat persistence failed", persistenceError);
  }

  return NextResponse.json({
    reply,
    sessionId: sid,
  });
}
