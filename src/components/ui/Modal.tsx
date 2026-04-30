"use client";

import { X } from "lucide-react";
import { Button } from "@/components/ui/Button";
import { cn } from "@/lib/utils";

interface ModalProps {
  open: boolean;
  title: string;
  children: React.ReactNode;
  onClose: () => void;
  className?: string;
}

export function Modal({ open, title, children, onClose, className }: ModalProps) {
  if (!open) {
    return null;
  }

  return (
    <div className="fixed inset-0 z-[90] flex items-center justify-center bg-black/70 p-4">
      <section
        className={cn(
          "max-h-[90vh] w-full max-w-3xl overflow-hidden rounded-lg border border-accent-border bg-bg-secondary shadow-2xl",
          className,
        )}
      >
        <header className="flex h-14 items-center justify-between border-b border-accent-border px-5">
          <h2 className="text-lg font-bold text-white">{title}</h2>
          <Button variant="ghost" className="h-9 w-9 p-0" onClick={onClose} aria-label="Close">
            <X size={18} />
          </Button>
        </header>
        {children}
      </section>
    </div>
  );
}
