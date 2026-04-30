export default function AlphaGame() {
  return (
    <div className="flex h-full min-h-[520px] flex-col">
      <div className="flex items-center gap-3 border-b border-accent-border p-4">
        <span className="text-2xl">💼</span>
        <div>
          <h2 className="text-lg font-bold text-white">Alpha: Cashflow Game</h2>
          <p className="text-sm text-text-muted">Build your financial empire across 12 rounds</p>
        </div>
        <span className="ml-auto hidden text-xs text-text-muted md:block">
          Original game by Bryan Soong (NTU IIC) — CC-BY-NC-4.0
        </span>
      </div>
      <div className="flex flex-1 items-center justify-center p-8 text-center">
        <div>
          <p className="mb-4 text-6xl">🚧</p>
          <h3 className="mb-2 text-xl font-bold text-white">Coming Soon</h3>
          <p className="text-text-muted">Copy the Flutter Web build to public/games/alpha to enable this iframe.</p>
        </div>
      </div>
    </div>
  );
}
