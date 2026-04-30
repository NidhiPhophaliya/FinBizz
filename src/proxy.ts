import { clerkMiddleware, createRouteMatcher } from "@clerk/nextjs/server";

const isProtectedRoute = createRouteMatcher([
  "/dashboard(.*)",
  "/games(.*)",
  "/onboarding(.*)",
  "/api/ai(.*)",
  "/api/user(.*)",
  "/api/games(.*)",
  "/api/flashcard(.*)",
  "/api/news(.*)",
  "/api/markets(.*)",
  "/api/commodities(.*)",
  "/api/finance-monitor(.*)",
]);

export default clerkMiddleware(async (auth, req) => {
  if (isProtectedRoute(req)) {
    await auth.protect();
  }
});

export const config = {
  matcher: ["/((?!.*\\..*|_next).*)", "/", "/(api|trpc)(.*)"],
};
