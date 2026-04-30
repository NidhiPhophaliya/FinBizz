"use client";

import { useUser } from "@clerk/nextjs";
import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import { Button } from "@/components/ui/Button";

const questions = [
  {
    prompt: "What does P/E ratio stand for?",
    options: ["Price-Earnings", "Profit-Equity", "Price-Equity", "Portfolio-Earnings"],
    answer: "Price-Earnings",
  },
  {
    prompt: "Which is considered a 'safe haven' asset?",
    options: ["Gold", "Bitcoin", "Growth Stocks", "Bonds"],
    answer: "Gold",
  },
  {
    prompt: "What does diversification mean in investing?",
    options: ["Spreading investments", "Buying one winner", "Timing the market", "Avoiding cash"],
    answer: "Spreading investments",
  },
  {
    prompt: "What is compound interest?",
    options: ["Interest on interest", "A fixed fee", "A tax rebate", "A trading signal"],
    answer: "Interest on interest",
  },
  {
    prompt: "What is a bull market?",
    options: ["Rising market", "Falling market", "Flat market", "Closed market"],
    answer: "Rising market",
  },
] as const;

const goals = [
  "Learn to invest",
  "Understand the stock market",
  "Build an emergency fund",
  "Start a business",
  "Understand crypto",
  "Learn macroeconomics",
  "Improve budgeting",
  "Play finance games",
] as const;

const preferences = [
  "I prefer strategy games",
  "I like quick quizzes",
  "I love simulations",
  "I want all of them",
] as const;

export default function OnboardingPage() {
  const router = useRouter();
  const { user } = useUser();
  const [step, setStep] = useState(1);
  const [answers, setAnswers] = useState<Record<number, string>>({});
  const [selectedGoals, setSelectedGoals] = useState<string[]>([]);
  const [gamePreference, setGamePreference] = useState("");
  const [saving, setSaving] = useState(false);

  const score = useMemo(
    () =>
      questions.reduce(
        (total, question, index) => total + (answers[index] === question.answer ? 1 : 0),
        0,
      ),
    [answers],
  );

  const save = async () => {
    setSaving(true);
    const knowledgeLevel = Math.max(1, Math.min(5, score));
    const response = await fetch("/api/user/onboarding", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: user?.primaryEmailAddress?.emailAddress ?? "",
        displayName: user?.fullName ?? user?.username ?? "FinLit Learner",
        avatarUrl: user?.imageUrl,
        knowledgeLevel,
        learningGoals: selectedGoals,
        gamePreference,
      }),
    });

    setSaving(false);
    if (response.ok) {
      router.push("/dashboard");
    }
  };

  return (
    <main className="flex min-h-screen items-center justify-center bg-bg-primary p-4">
      <section className="w-full max-w-3xl rounded-lg border border-accent-border bg-bg-secondary p-6 shadow-2xl">
        <div className="mb-6">
          <p className="text-sm font-bold text-accent-gold">Step {step} of 3</p>
          <h1 className="mt-1 text-3xl font-bold text-white">Tune your FinLit path</h1>
        </div>

        {step === 1 ? (
          <div className="space-y-5">
            {questions.map((question, index) => (
              <div key={question.prompt}>
                <h2 className="mb-2 font-bold text-white">{question.prompt}</h2>
                <div className="grid gap-2 sm:grid-cols-2">
                  {question.options.map((option) => (
                    <button
                      key={option}
                      className={`rounded-lg border p-3 text-left text-sm ${
                        answers[index] === option
                          ? "border-brand-blue bg-brand-blue/20 text-white"
                          : "border-accent-border bg-bg-tertiary text-text-muted"
                      }`}
                      onClick={() => setAnswers((current) => ({ ...current, [index]: option }))}
                    >
                      {option}
                    </button>
                  ))}
                </div>
              </div>
            ))}
            <Button className="w-full" onClick={() => setStep(2)} disabled={Object.keys(answers).length < questions.length}>
              Continue
            </Button>
          </div>
        ) : null}

        {step === 2 ? (
          <div>
            <div className="grid gap-3 sm:grid-cols-2">
              {goals.map((goal) => {
                const selected = selectedGoals.includes(goal);
                return (
                  <button
                    key={goal}
                    className={`rounded-full border px-4 py-3 text-sm font-bold ${
                      selected
                        ? "border-accent-teal bg-accent-teal/20 text-white"
                        : "border-accent-border bg-bg-tertiary text-text-muted"
                    }`}
                    onClick={() =>
                      setSelectedGoals((current) =>
                        selected ? current.filter((item) => item !== goal) : [...current, goal],
                      )
                    }
                  >
                    {goal}
                  </button>
                );
              })}
            </div>
            <div className="mt-6 flex justify-between">
              <Button variant="secondary" onClick={() => setStep(1)}>
                Back
              </Button>
              <Button onClick={() => setStep(3)} disabled={selectedGoals.length === 0}>
                Continue
              </Button>
            </div>
          </div>
        ) : null}

        {step === 3 ? (
          <div>
            <div className="grid gap-3">
              {preferences.map((preference) => (
                <button
                  key={preference}
                  className={`rounded-lg border p-4 text-left font-bold ${
                    gamePreference === preference
                      ? "border-accent-gold bg-accent-gold/20 text-white"
                      : "border-accent-border bg-bg-tertiary text-text-muted"
                  }`}
                  onClick={() => setGamePreference(preference)}
                >
                  {preference}
                </button>
              ))}
            </div>
            <div className="mt-6 flex justify-between">
              <Button variant="secondary" onClick={() => setStep(2)}>
                Back
              </Button>
              <Button onClick={save} disabled={!gamePreference || saving}>
                {saving ? "Saving..." : "Finish"}
              </Button>
            </div>
          </div>
        ) : null}
      </section>
    </main>
  );
}
