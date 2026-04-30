"use client";

import { useEffect } from "react";
import { useToastStore, type ToastMessage } from "@/store/toastStore";

function ToastItem({ toast }: { toast: ToastMessage }) {
  const dismissToast = useToastStore((state) => state.dismissToast);

  useEffect(() => {
    const timer = window.setTimeout(() => dismissToast(toast.id), 3000);
    return () => window.clearTimeout(timer);
  }, [dismissToast, toast.id]);

  return (
    <div className="rounded-full border border-accent-gold bg-bg-secondary px-4 py-3 text-sm text-white shadow-xl">
      <div className="font-bold">{toast.title}</div>
      {toast.description ? (
        <div className="text-xs text-text-muted">{toast.description}</div>
      ) : null}
    </div>
  );
}

export function ToastViewport() {
  const toasts = useToastStore((state) => state.toasts);

  return (
    <div className="fixed bottom-5 left-5 z-[120] flex max-w-sm flex-col gap-2">
      {toasts.map((toast) => (
        <ToastItem key={toast.id} toast={toast} />
      ))}
    </div>
  );
}
