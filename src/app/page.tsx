"use client";

import { SignInButton, useUser } from "@clerk/nextjs";
import { Play, X } from "lucide-react";
import Link from "next/link";
import { useState } from "react";

const stats = ["92 Stock Exchanges", "435+ News Feeds", "6 Finance Games"] as const;

export default function Home() {
  const [demoOpen, setDemoOpen] = useState(false);
  const { isLoaded, isSignedIn } = useUser();

  return (
    <main className="relative flex min-h-screen items-center justify-center overflow-hidden bg-bg-primary px-5 text-text-primary">
      <svg
        className="pointer-events-none absolute inset-0 h-full w-full opacity-[0.06]"
        aria-hidden="true"
      >
        <defs>
          <pattern id="finlit-grid" width="28" height="28" patternUnits="userSpaceOnUse">
            <circle cx="1.5" cy="1.5" r="1.5" fill="#ffffff" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#finlit-grid)" />
      </svg>

      <div className="absolute left-5 top-5 flex items-center gap-3 sm:left-8 sm:top-7">
        <div className="text-[2rem] font-bold leading-none tracking-normal">
          <span className="text-brand-blue">FIN</span>
          <span className="text-accent-gold">LIT</span>
        </div>
        <div className="flex items-center gap-1.5 text-[11px] font-bold text-accent-green">
          <span className="h-2 w-2 animate-pulse rounded-full bg-accent-green" />
          LIVE
        </div>
      </div>

      <section className="relative z-10 flex max-w-5xl flex-col items-center text-center">
        <h1 className="max-w-4xl text-5xl font-bold leading-tight tracking-normal text-white sm:text-6xl lg:text-[4rem]">
          Master the Language of{" "}
          <span className="relative inline-block">
            Money
            <span
              className="absolute -bottom-1 left-0 h-1 w-full origin-left rounded-full bg-brand-blue"
              style={{ animation: "underlineDraw 0.85s ease-out 0.25s both" }}
            />
          </span>
        </h1>
        <p className="mt-6 max-w-[520px] text-[1.1rem] leading-8 text-text-muted">
          Live global markets. AI-powered guidance. Games that make finance click.
        </p>
        <div className="mt-9 flex w-full max-w-md flex-col gap-3 sm:flex-row sm:justify-center">
          {isLoaded && isSignedIn ? (
            <Link
              href="/dashboard"
              className="rounded-lg bg-brand-blue px-6 py-3 font-bold text-white transition hover:animate-[glow_1.8s_ease-in-out_infinite_alternate] focus:outline-none focus:ring-2 focus:ring-brand-blue focus:ring-offset-2 focus:ring-offset-bg-primary"
            >
              Go to Dashboard
            </Link>
          ) : (
            <SignInButton mode="modal">
              <button className="rounded-lg bg-brand-blue px-6 py-3 font-bold text-white transition hover:animate-[glow_1.8s_ease-in-out_infinite_alternate] focus:outline-none focus:ring-2 focus:ring-brand-blue focus:ring-offset-2 focus:ring-offset-bg-primary">
                Get Started Free
              </button>
            </SignInButton>
          )}
          <button
            className="inline-flex items-center justify-center gap-2 rounded-lg border border-accent-border px-6 py-3 font-bold text-text-muted transition hover:border-brand-blue hover:text-white focus:outline-none focus:ring-2 focus:ring-brand-blue focus:ring-offset-2 focus:ring-offset-bg-primary"
            onClick={() => setDemoOpen(true)}
          >
            <Play size={18} />
            Watch Demo
          </button>
        </div>
      </section>

      <div className="absolute bottom-6 left-1/2 z-10 flex w-[calc(100%-2rem)] -translate-x-1/2 flex-wrap justify-center gap-3">
        {stats.map((stat) => (
          <span
            key={stat}
            className="rounded-full border border-accent-border bg-bg-secondary px-4 py-2 text-sm font-bold text-accent-gold"
          >
            {stat}
          </span>
        ))}
      </div>

      {demoOpen ? (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 px-4">
          <div className="w-full max-w-xl rounded-lg border border-accent-border bg-bg-secondary p-6 shadow-2xl">
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-xl font-bold text-white">FinLit Demo</h2>
              <button
                aria-label="Close demo"
                className="rounded-md p-2 text-text-muted hover:bg-bg-tertiary hover:text-white"
                onClick={() => setDemoOpen(false)}
              >
                <X size={18} />
              </button>
            </div>
            <div className="rounded-lg border border-accent-border bg-bg-primary p-5 text-left text-text-muted">
              <p className="text-white">A quick tour is included in the dashboard experience.</p>
              <p className="mt-3">
                Sign in to explore the live map, news, AI flashcards, and finance games.
              </p>
            </div>
          </div>
        </div>
      ) : null}
    </main>
  );
}
