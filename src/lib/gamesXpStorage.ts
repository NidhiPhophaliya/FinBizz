import { levelFromXP } from "@/lib/utils";

const MAX_EVENTS = 50;
const STORAGE_KEY_PREFIX = "finlit:games-xp:";

export interface GameXpEvent {
  gameName: string;
  xpAwarded: number;
  score?: number;
  savedAt: string;
}

export interface GameXpRecord {
  email: string;
  totalXp: number;
  level: number;
  events: GameXpEvent[];
  updatedAt: string;
}

export function normalizeGameXpEmail(email: string) {
  return email.trim().toLowerCase();
}

export function gameXpStorageKey(email: string) {
  return `${STORAGE_KEY_PREFIX}${normalizeGameXpEmail(email)}`;
}

export function levelFromLocalGameXp(xp: number) {
  return levelFromXP(xp);
}

export function loadGameXp(email: string): GameXpRecord | null {
  if (typeof window === "undefined") {
    return null;
  }

  const normalizedEmail = normalizeGameXpEmail(email);
  if (!normalizedEmail) {
    return null;
  }

  try {
    const raw = window.localStorage.getItem(gameXpStorageKey(normalizedEmail));
    if (!raw) {
      return null;
    }

    const parsed = JSON.parse(raw) as Partial<GameXpRecord>;
    const totalXp = Number.isFinite(parsed.totalXp) ? Math.max(0, Math.round(parsed.totalXp ?? 0)) : 0;
    const events = Array.isArray(parsed.events)
      ? parsed.events
          .filter((event): event is GameXpEvent => {
            return (
              typeof event?.gameName === "string" &&
              typeof event?.savedAt === "string" &&
              typeof event?.xpAwarded === "number" &&
              Number.isFinite(event.xpAwarded)
            );
          })
          .slice(-MAX_EVENTS)
      : [];

    return {
      email: normalizedEmail,
      totalXp,
      level: levelFromLocalGameXp(totalXp),
      events,
      updatedAt: typeof parsed.updatedAt === "string" ? parsed.updatedAt : new Date().toISOString(),
    };
  } catch {
    return null;
  }
}

export function recordGameXp(
  email: string,
  event: Omit<GameXpEvent, "savedAt"> & { savedAt?: string },
): GameXpRecord | null {
  if (typeof window === "undefined") {
    return null;
  }

  const normalizedEmail = normalizeGameXpEmail(email);
  if (!normalizedEmail || !Number.isFinite(event.xpAwarded)) {
    return null;
  }

  try {
    const current = loadGameXp(normalizedEmail);
    const savedAt = event.savedAt ?? new Date().toISOString();
    const xpAwarded = Math.max(0, Math.round(event.xpAwarded));
    const totalXp = (current?.totalXp ?? 0) + xpAwarded;
    const next: GameXpRecord = {
      email: normalizedEmail,
      totalXp,
      level: levelFromLocalGameXp(totalXp),
      events: [
        ...(current?.events ?? []),
        {
          gameName: event.gameName,
          xpAwarded,
          score: typeof event.score === "number" && Number.isFinite(event.score) ? event.score : undefined,
          savedAt,
        },
      ].slice(-MAX_EVENTS),
      updatedAt: savedAt,
    };

    window.localStorage.setItem(gameXpStorageKey(normalizedEmail), JSON.stringify(next));
    return next;
  } catch {
    return null;
  }
}
