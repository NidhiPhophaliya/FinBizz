import { ExternalLink } from "lucide-react";

const FINCHESS_GAMES = {
  predictor: {
    title: "Stock Price Predictor",
    subtitle: "Predict the next move from live market chart data.",
  },
  portfolio: {
    title: "Portfolio Challenge",
    subtitle: "Build a $100K allocation and compare against the market.",
  },
  quiz: {
    title: "Finance Quiz",
    subtitle: "Answer finance, crypto, economics, and technical-analysis questions.",
  },
  candles: {
    title: "Candlestick Trainer",
    subtitle: "Read candle patterns and learn price-action signals.",
  },
} as const;

export type FinchessGameId = keyof typeof FINCHESS_GAMES;

export default function FinchessGame({ game }: { game: FinchessGameId }) {
  const config = FINCHESS_GAMES[game];
  const src = `/games/finchess/index.html?game=${game}`;

  return (
    <div className="flex h-full min-h-[720px] flex-col">
      <div className="flex flex-wrap items-center gap-3 border-b border-accent-border p-4">
        <span className="text-2xl">♟️</span>
        <div>
          <h2 className="text-lg font-bold text-white">{config.title}</h2>
          <p className="text-sm text-text-muted">{config.subtitle}</p>
        </div>
        <a
          href={src}
          target="_blank"
          rel="noreferrer"
          className="ml-auto inline-flex items-center gap-2 rounded-lg border border-accent-border px-3 py-2 text-sm font-semibold text-accent-teal transition hover:border-accent-teal hover:bg-bg-tertiary"
        >
          <ExternalLink size={16} aria-hidden="true" />
          Open
        </a>
      </div>
      <div className="flex-1 bg-[#0a0e17]">
        <iframe
          src={src}
          title={config.title}
          className="h-full min-h-[720px] w-full border-0"
          loading="lazy"
          referrerPolicy="strict-origin-when-cross-origin"
        />
      </div>
    </div>
  );
}
