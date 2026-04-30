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
        className="inline-flex h-9 items-center gap-2 rounded-lg px-3 text-sm font-bold text-white shadow-[0_0_15px_#ffd78060,0_0_30px_#42a5f530] transition hover:scale-105"
        style={{
          background: "linear-gradient(135deg, #ffd780, #42a5f5, #7ee4e3)",
          backgroundSize: "200%",
          animation: "backgroundShift 4s ease infinite",
        }}
        onClick={() => setOpen(true)}
      >
        <Gamepad2 size={17} />
        <span className="hidden sm:inline">GAMES HUB</span>
      </button>
      <GamesHubModal open={open} onClose={() => setOpen(false)} />
    </>
  );
}
