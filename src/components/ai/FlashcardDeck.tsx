"use client";

import { useMemo, useState } from "react";
import { Button } from "@/components/ui/Button";
import { flashcards, type FlashcardDeckKey } from "@/data/flashcards";
import { useToastStore } from "@/store/toastStore";

const decks: { key: FlashcardDeckKey; label: string }[] = [
  { key: "basics", label: "Basics" },
  { key: "investing", label: "Investing" },
  { key: "trading", label: "Trading" },
  { key: "macroeconomics", label: "Macro" },
  { key: "crypto", label: "Crypto" },
];

export default function FlashcardDeck() {
  const [deck, setDeck] = useState<FlashcardDeckKey>("basics");
  const [index, setIndex] = useState(0);
  const [flipped, setFlipped] = useState(false);
  const pushToast = useToastStore((state) => state.pushToast);
  const cards = useMemo(() => flashcards.filter((card) => card.deck === deck), [deck]);
  const card = cards[index % cards.length];

  const updateProgress = async (correct: boolean) => {
    await fetch("/api/flashcard/progress", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ cardId: card.id, deck: card.deck, correct }),
    });
    pushToast({ title: correct ? "✅ Flashcard progress saved" : "Review scheduled" });
    setFlipped(false);
    setIndex((value) => value + 1);
  };

  return (
    <section>
      <div className="mb-3 flex gap-2 overflow-x-auto">
        {decks.map((item) => (
          <button
            key={item.key}
            className={`rounded-full px-3 py-1.5 text-xs font-bold ${
              deck === item.key ? "bg-brand-blue text-white" : "bg-bg-tertiary text-text-muted"
            }`}
            onClick={() => {
              setDeck(item.key);
              setIndex(0);
              setFlipped(false);
            }}
          >
            {item.label}
          </button>
        ))}
      </div>
      <button
        className="h-[200px] w-full rounded-xl border border-accent-border bg-bg-tertiary p-5 text-left"
        onClick={() => setFlipped((value) => !value)}
      >
        <div className="text-xs font-bold uppercase text-accent-gold">
          {flipped ? "Back" : "Front"}
        </div>
        <div className="mt-4 text-lg font-bold leading-7 text-white">
          {flipped ? card.back : card.front}
        </div>
      </button>
      <div className="mt-3 grid grid-cols-2 gap-2">
        <Button variant="secondary" onClick={() => void updateProgress(false)}>
          Review again
        </Button>
        <Button onClick={() => void updateProgress(true)}>Got it ✓</Button>
      </div>
    </section>
  );
}
