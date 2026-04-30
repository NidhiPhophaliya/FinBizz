# FinLit

FinLit is a financial literacy web app with a live-style global finance map, Clerk auth, Supabase persistence, an AI assistant, flashcards, progress tracking, and playable finance games.

## Tech Stack

| Area | Tools |
|---|---|
| App | Next.js 16, React 19, TypeScript |
| Styling | Tailwind CSS v4, FinLit CSS variables |
| Auth | Clerk |
| Database | Supabase Postgres + RLS |
| Maps | deck.gl, MapLibre, react-map-gl |
| Data UI | SWR, Recharts |
| Games | React state/reducer gameplay |
| AI | Hugging Face Inference API |
| Finance monitoring | World Monitor bootstrap adapter, Finnhub fallback |

## Local Development

1. Install dependencies:

```bash
npm install
```

2. Copy `.env.example` to `.env.local` and fill Clerk, Supabase, NewsAPI, Finnhub, Alpha Vantage, and Hugging Face keys as available.

3. Start the app:

```bash
npm run dev
```

4. Open `http://localhost:3000`.

Development fallbacks are included for market/news/AI routes when keys are empty, but persistence requires Supabase env vars.
`WORLD_MONITOR_API_KEY` enables server-side access to the World Monitor bootstrap API for live finance radar data. Without it, FinLit falls back to the configured Finnhub/Alpha keys and then to static development data.

## Required Environment Variables

See `.env.example` for the complete list. Never commit real values from `.env.local`.

## Supabase Setup

Create a free Supabase project, then run the SQL from the PRD in the Supabase SQL editor. Ensure Row Level Security is enabled on every table. The app uses the service role only in server route handlers and never imports it into client components.

Important tables:

- `users`
- `flashcard_progress`
- `game_sessions`
- `ai_chat_history`
- `news_interactions`
- `watchlist`
- `learning_milestones`

## Clerk Setup

Create a Clerk app, enable email plus Google/GitHub OAuth, and set these URLs:

- Sign in: `/sign-in`
- Sign up: `/sign-up`
- After sign in: `/dashboard`
- After sign up: `/onboarding`

Protected traffic is handled in `src/proxy.ts`, and every protected API route also calls `auth()`.

## Alpha Flutter Game

To enable Alpha:

1. Clone `https://github.com/vrevolverrr/alpha`
2. Run `flutter build web --release --base-href /games/alpha/`
3. Copy `build/web/` into `public/games/alpha/`
4. Replace the placeholder in `src/components/games/AlphaGame.tsx` with an iframe pointing at `/games/alpha/index.html`

Attribution: Original game by Bryan Soong (NTU IIC), CC-BY-NC-4.0.

## Deployment

Deploy to Vercel:

```bash
vercel
```

Set all environment variables in the Vercel dashboard. `vercel.json` includes cross-origin headers for the Alpha Flutter build path.

## Attribution

World Monitor finance monitoring patterns and public API shape are used with attribution. World Monitor is AGPL-3.0 for non-commercial use; commercial use requires a separate license from the maintainer. Alpha attribution is listed above.
