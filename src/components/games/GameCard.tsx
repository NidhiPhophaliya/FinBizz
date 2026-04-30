import { Button } from "@/components/ui/Button";

export interface GameCardProps {
  icon: string;
  title: string;
  tagline: string;
  difficulty: string;
  reward: string;
  accent: string;
  onPlay: () => void;
}

export default function GameCard({
  icon,
  title,
  tagline,
  difficulty,
  reward,
  accent,
  onPlay,
}: GameCardProps) {
  return (
    <article className="flex min-h-[280px] flex-col rounded-2xl border border-accent-border bg-bg-secondary p-5">
      <div className="text-center text-7xl">{icon}</div>
      <h3 className="mt-4 text-lg font-bold text-white">{title}</h3>
      <p className="mt-2 flex-1 text-sm leading-6 text-text-muted">{tagline}</p>
      <div className="mb-4 flex flex-wrap gap-2 text-xs">
        <span className="rounded-full bg-bg-tertiary px-2 py-1 text-accent-teal">{difficulty}</span>
        <span className="rounded-full bg-bg-tertiary px-2 py-1 text-accent-gold">{reward}</span>
      </div>
      <Button className="w-full" style={{ background: accent }} onClick={onPlay}>
        Play
      </Button>
    </article>
  );
}
