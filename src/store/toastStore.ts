import { create } from "zustand";

export interface ToastMessage {
  id: string;
  title: string;
  description?: string;
}

interface ToastStore {
  toasts: ToastMessage[];
  pushToast: (toast: Omit<ToastMessage, "id">) => void;
  dismissToast: (id: string) => void;
}

export const useToastStore = create<ToastStore>((set) => ({
  toasts: [],
  pushToast: (toast) =>
    set((state) => ({
      toasts: [...state.toasts, { id: crypto.randomUUID(), ...toast }].slice(-4),
    })),
  dismissToast: (id) =>
    set((state) => ({
      toasts: state.toasts.filter((toast) => toast.id !== id),
    })),
}));
