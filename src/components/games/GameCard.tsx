import type { ComponentType } from "react";
import type { LucideProps } from "lucide-react";
import { ArrowRight } from "lucide-react";

export interface GameCardProps {
  icon: ComponentType<LucideProps>;
  title: string;
  tagline: string;
  difficulty: string;
  reward: string;
  category: string;
  accent: string;
  onPlay: () => void;
}

export default function GameCard({
  icon: Icon,
  title,
  tagline,
  difficulty,
  reward,
  category,
  accent,
  onPlay,
}: GameCardProps) {
  return (
    <article className="group relative overflow-hidden rounded-lg border border-white/[0.07] bg-[#151924] transition duration-200 hover:-translate-y-0.5 hover:border-white/[0.14] hover:bg-[#181d29]">
      <div
        className="absolute inset-x-0 top-0 h-px opacity-80"
        style={{ background: `linear-gradient(90deg, transparent, ${accent}, transparent)` }}
      />
      <button
        className="flex h-full w-full flex-col p-4 text-left focus:outline-none focus:ring-2 focus:ring-[#86d7c7] focus:ring-offset-2 focus:ring-offset-[#0c1018]"
        onClick={onPlay}
      >
        <div className="flex items-start justify-between gap-4">
          <div className="flex min-w-0 items-center gap-3">
            <span
              className="flex h-10 w-10 shrink-0 items-center justify-center rounded-md border border-white/[0.08] bg-[#0e131d]"
              style={{ color: accent }}
            >
              <Icon size={20} strokeWidth={1.9} />
            </span>
            <div className="min-w-0">
              <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[#7f8a9c]">
                {category}
              </p>
              <h3 className="mt-1 truncate text-base font-semibold text-[#f5f7fb]">{title}</h3>
            </div>
          </div>
          <ArrowRight
            className="mt-2 shrink-0 text-[#667085] transition group-hover:translate-x-0.5 group-hover:text-[#d7dde8]"
            size={18}
          />
        </div>
        <p className="mt-4 min-h-[48px] text-sm leading-6 text-[#a5afbf]">{tagline}</p>
        <div className="mt-5 flex flex-wrap gap-x-4 gap-y-2 border-t border-white/[0.06] pt-3 text-xs">
          <span className="text-[#d7dde8]">{difficulty}</span>
          <span className="text-[#7f8a9c]">{reward}</span>
        </div>
      </button>
    </article>
  );
}
