import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        "bg-primary": "#1d1f29",
        "bg-secondary": "#222431",
        "bg-tertiary": "#272937",
        "accent-border": "#36384a",
        "brand-blue": "#42a5f5",
        "accent-gold": "#ffd780",
        "accent-teal": "#7ee4e3",
        "accent-green": "#99ff88",
        "text-primary": "#ffffff",
        "text-muted": "#a7b1c1",
      },
      fontFamily: {
        display: ["Space Grotesk", "sans-serif"],
        mono: ["JetBrains Mono", "monospace"],
      },
      animation: {
        "pulse-slow": "pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        glow: "glow 2s ease-in-out infinite alternate",
        "slide-up": "slideUp 0.4s ease-out",
        "fade-in": "fadeIn 0.3s ease-out",
      },
    },
  },
  plugins: [],
};

export default config;
