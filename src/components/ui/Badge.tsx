import { cn } from "@/lib/utils";

export function Badge({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border border-accent-border bg-bg-tertiary px-2.5 py-1 text-xs font-bold text-text-muted",
        className,
      )}
    >
      {children}
    </span>
  );
}
