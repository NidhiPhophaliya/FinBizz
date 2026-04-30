"use client";

import { formatDistanceToNow } from "date-fns";

export interface NewsArticle {
  title: string;
  url: string;
  source?: { name?: string };
  publishedAt?: string;
  category?: string;
}

export default function NewsCard({
  article,
  category,
}: {
  article: NewsArticle;
  category: string;
}) {
  const highImpact = /fed|rate|inflation|war|crash|oil|jobs/i.test(article.title);
  const time = article.publishedAt
    ? formatDistanceToNow(new Date(article.publishedAt), { addSuffix: true })
    : "recently";

  const openArticle = () => {
    window.open(article.url, "_blank", "noopener,noreferrer");
    void fetch("/api/user/news-interaction", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        articleUrl: article.url,
        headline: article.title,
        category,
        timeSpentSeconds: 30,
      }),
    });
  };

  return (
    <button
      className="w-full border-b border-accent-border p-3 text-left transition hover:bg-bg-tertiary"
      onClick={openArticle}
    >
      <div className="mb-2 flex items-center gap-2">
        {highImpact ? <span className="text-xs font-bold text-red-400">ALERT</span> : null}
        <span className="rounded-full bg-bg-primary px-2 py-0.5 text-[10px] uppercase text-accent-teal">
          {category}
        </span>
      </div>
      <h3 className="line-clamp-2 text-[13px] font-bold leading-5 text-white">{article.title}</h3>
      <p className="mt-2 text-xs text-text-muted">
        {article.source?.name ?? "Market desk"} · {time}
      </p>
    </button>
  );
}
