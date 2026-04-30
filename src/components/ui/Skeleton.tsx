import { cn } from "@/lib/utils";

export function Skeleton({ className }: { className?: string }) {
  return (
    <div
      className={cn("animate-pulse rounded bg-bg-tertiary", className)}
      style={{
        background:
          "linear-gradient(90deg, #272937 25%, #36384a 50%, #272937 75%)",
        backgroundSize: "200% 100%",
        animation: "shimmer 1.5s infinite",
      }}
    />
  );
}
