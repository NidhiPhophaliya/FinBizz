"use client";

import { Sparkles } from "lucide-react";
import AIChatPanel from "@/components/ai/AIChatPanel";
import { useDashboardStore } from "@/store/dashboardStore";

export default function AIChatButton() {
  const isOpen = useDashboardStore((state) => state.isAIChatOpen);
  const setOpen = useDashboardStore((state) => state.setAIChatOpen);

  return (
    <>
      <button
        className="fixed bottom-[140px] right-6 z-50 flex h-14 w-14 items-center justify-center rounded-full border-0 bg-gradient-to-br from-brand-blue to-accent-teal text-white shadow-[0_0_20px_#42a5f550,0_4px_15px_rgba(0,0,0,0.4)] transition hover:scale-105"
        style={{ animation: "glow 2s ease-in-out infinite alternate" }}
        onClick={() => setOpen(true)}
        aria-label="Ask FinLit AI"
        title="Ask FinLit AI"
      >
        <Sparkles size={24} />
      </button>
      <AIChatPanel open={isOpen} onClose={() => setOpen(false)} />
    </>
  );
}
