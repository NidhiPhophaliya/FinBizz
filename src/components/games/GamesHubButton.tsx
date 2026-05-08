"use client";

import { Gamepad2 } from "lucide-react";
import GamesHubModal from "@/components/games/GamesHubModal";
import { useDashboardStore } from "@/store/dashboardStore";

export default function GamesHubButton() {
  const open = useDashboardStore((state) => state.isGamesHubOpen);
  const setOpen = useDashboardStore((state) => state.setGamesHubOpen);

  return (
    <>
      <button
        className="inline-flex h-9 items-center gap-2 rounded-lg border border-[#31424a] bg-[#141b25] px-3 text-sm font-semibold text-[#d8efe8] transition hover:border-[#5fa99d] hover:bg-[#182433] focus:outline-none focus:ring-2 focus:ring-[#86d7c7] focus:ring-offset-2 focus:ring-offset-[#0f111a]"
        onClick={() => setOpen(true)}
      >
        <Gamepad2 size={17} />
        <span className="hidden sm:inline">Games</span>
      </button>
      <GamesHubModal open={open} onClose={() => setOpen(false)} />
    </>
  );
}
