import { cn } from "@/lib/utils";

export function ProgressBar({
  value,
  className,
}: {
  value: number;
  className?: string;
}) {
  const clamped = Math.max(0, Math.min(value, 100));

  return (
    <div className={cn("h-3 overflow-hidden rounded-full bg-bg-tertiary", className)}>
      <div
        className="h-full rounded-full bg-gradient-to-r from-brand-blue via-accent-teal to-accent-green transition-all"
        style={{ width: `${clamped}%` }}
      />
    </div>
  );
}
