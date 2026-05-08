import { ExternalLink } from "lucide-react";

const alphaGameUrl = "https://finbizz-89872.web.app/";

export default function AlphaGame() {
  return (
    <div className="flex h-full min-h-[720px] flex-col">
      <div className="flex flex-wrap items-center gap-3 border-b border-accent-border p-4">
        <span className="text-2xl">💼</span>
        <div>
          <h2 className="text-lg font-bold text-white">Alpha: Cashflow Game</h2>
          <p className="text-sm text-text-muted">Build your financial empire across 12 rounds</p>
        </div>
        <span className="ml-auto hidden text-xs text-text-muted lg:block">
          Original game by Bryan Soong (NTU IIC) — CC-BY-NC-4.0
        </span>
        <a
          href={alphaGameUrl}
          target="_blank"
          rel="noreferrer"
          className="inline-flex items-center gap-2 rounded-lg border border-accent-border px-3 py-2 text-sm font-semibold text-accent-teal transition hover:border-accent-teal hover:bg-bg-tertiary"
        >
          <ExternalLink size={16} aria-hidden="true" />
          Open
        </a>
      </div>
      <div className="flex-1 bg-black">
        <iframe
          src={alphaGameUrl}
          title="Alpha cashflow strategy game"
          className="h-full min-h-[720px] w-full border-0"
          allow="fullscreen; gamepad"
          allowFullScreen
          loading="lazy"
          referrerPolicy="strict-origin-when-cross-origin"
        />
      </div>
    </div>
  );
}
