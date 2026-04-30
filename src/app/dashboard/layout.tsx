import AIChatButton from "@/components/ai/AIChatButton";
import MarketCardsStrip from "@/components/dashboard/MarketCardsStrip";
import RightNewsPanel from "@/components/dashboard/RightNewsPanel";
import TopNavBar from "@/components/dashboard/TopNavBar";
import { ToastViewport } from "@/components/ui/Toast";

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex h-screen w-screen flex-col overflow-hidden bg-[#0f111a]">
      {/* Top nav — includes time range pills + 2D/3D toggle */}
      <TopNavBar />

      {/* Main body */}
      <div className="relative flex min-h-0 flex-1 overflow-hidden">
        {/* Map area — takes all remaining space */}
        <main className="relative min-h-0 flex-1 overflow-hidden">
          {children}
        </main>

        {/* Right news panel */}
        <RightNewsPanel />
      </div>

      {/* Bottom market ticker strip */}
      <MarketCardsStrip />

      {/* Floating AI button */}
      <AIChatButton />
      <ToastViewport />
    </div>
  );
}
