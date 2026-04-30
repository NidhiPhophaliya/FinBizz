"use client";

import { motion } from "framer-motion";
import { Minus, Send, X } from "lucide-react";
import { FormEvent, useState } from "react";
import ReactMarkdown from "react-markdown";
import FlashcardDeck from "@/components/ai/FlashcardDeck";

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

const prompts = [
  "What is a P/E ratio?",
  "Explain compound interest",
  "What does the Fed rate affect?",
  "How do I start investing?",
  "What are trade routes?",
] as const;

export default function AIChatPanel({ open, onClose }: { open: boolean; onClose: () => void }) {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState("");
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const send = async (message: string) => {
    if (!message.trim() || loading) {
      return;
    }

    const nextMessages: ChatMessage[] = [...messages, { role: "user", content: message }];
    setMessages(nextMessages);
    setInput("");
    setLoading(true);

    try {
      const res = await fetch("/api/ai/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message, sessionId, history: messages }),
      });
      const data = (await res.json()) as { reply?: string; sessionId?: string; error?: string };
      setSessionId(data.sessionId ?? sessionId);
      setMessages([
        ...nextMessages,
        {
          role: "assistant",
          content: data.reply ?? data.error ?? "AI service unavailable. Please try again.",
        },
      ]);
    } finally {
      setLoading(false);
    }
  };

  const submit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    void send(input);
  };

  return (
    <motion.aside
      className="fixed inset-0 z-[80] flex flex-col border-accent-border bg-bg-secondary shadow-2xl md:inset-auto md:bottom-[140px] md:right-[88px] md:h-[600px] md:w-[420px] md:rounded-t-2xl md:border"
      animate={{ y: open ? 0 : 620, opacity: open ? 1 : 0, pointerEvents: open ? "auto" : "none" }}
      initial={false}
      transition={{ type: "spring", damping: 28, stiffness: 260 }}
    >
      <header className="flex h-14 items-center justify-between border-b border-accent-border px-4">
        <h2 className="font-bold text-white">✨ FinLit AI</h2>
        <div className="flex gap-1">
          <button className="rounded p-2 text-text-muted hover:bg-bg-tertiary" aria-label="Minimize">
            <Minus size={16} />
          </button>
          <button className="rounded p-2 text-text-muted hover:bg-bg-tertiary" onClick={onClose} aria-label="Close AI chat">
            <X size={16} />
          </button>
        </div>
      </header>

      <div className="flex-1 overflow-y-auto p-4">
        {messages.length === 0 ? (
          <div className="space-y-4">
            <div className="flex gap-2 overflow-x-auto pb-1">
              {prompts.map((prompt) => (
                <button
                  key={prompt}
                  className="shrink-0 rounded-full border border-brand-blue bg-bg-tertiary px-3 py-2 text-xs font-bold text-white"
                  onClick={() => void send(prompt)}
                >
                  {prompt}
                </button>
              ))}
            </div>
            <FlashcardDeck />
          </div>
        ) : (
          <div className="space-y-3">
            {messages.map((message, index) => (
              <div
                key={`${message.role}-${index}`}
                className={`max-w-[85%] rounded-lg p-3 text-sm leading-6 ${
                  message.role === "user"
                    ? "ml-auto bg-bg-tertiary text-accent-teal"
                    : "bg-bg-primary text-white"
                }`}
              >
                <ReactMarkdown>{message.content}</ReactMarkdown>
              </div>
            ))}
            {loading ? (
              <div className="inline-flex rounded-lg bg-bg-primary p-3 text-white">
                <span className="animate-pulse">Typing...</span>
              </div>
            ) : null}
          </div>
        )}
      </div>

      <form className="flex gap-2 border-t border-accent-border p-3" onSubmit={submit}>
        <input
          className="min-w-0 flex-1 rounded-lg border border-accent-border bg-bg-tertiary px-3 text-sm text-white outline-none focus:border-brand-blue"
          value={input}
          onChange={(event) => setInput(event.target.value)}
          placeholder="Ask about finance..."
        />
        <button className="rounded-lg bg-brand-blue px-3 text-white" type="submit" aria-label="Send message">
          <Send size={18} />
        </button>
      </form>
    </motion.aside>
  );
}
