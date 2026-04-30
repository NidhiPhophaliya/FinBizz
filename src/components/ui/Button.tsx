import type { ButtonHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "ghost" | "gold";
}

const variants: Record<NonNullable<ButtonProps["variant"]>, string> = {
  primary:
    "bg-brand-blue text-white hover:shadow-[0_0_18px_#42a5f560] disabled:bg-accent-border",
  secondary:
    "border border-accent-border bg-bg-tertiary text-text-primary hover:border-brand-blue",
  ghost: "text-text-muted hover:bg-bg-tertiary hover:text-white",
  gold: "bg-accent-gold text-bg-primary hover:shadow-[0_0_18px_#ffd78060]",
};

export function Button({
  className,
  variant = "primary",
  type = "button",
  ...props
}: ButtonProps) {
  return (
    <button
      type={type}
      className={cn(
        "inline-flex min-h-10 items-center justify-center gap-2 rounded-lg px-4 py-2 text-sm font-bold transition focus:outline-none focus:ring-2 focus:ring-brand-blue focus:ring-offset-2 focus:ring-offset-bg-primary disabled:cursor-not-allowed disabled:opacity-60",
        variants[variant],
        className,
      )}
      {...props}
    />
  );
}
