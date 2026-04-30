"use client";

import { Component, type ErrorInfo, type ReactNode } from "react";

interface ErrorBoundaryProps {
  children: ReactNode;
  label: string;
}

interface ErrorBoundaryState {
  hasError: boolean;
}

export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = { hasError: false };

  static getDerivedStateFromError(): ErrorBoundaryState {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error(`${this.props.label} crashed`, error, info);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="m-4 rounded-lg border border-accent-border bg-bg-secondary p-5 text-text-muted">
          <h2 className="mb-2 text-lg font-bold text-white">{this.props.label} is unavailable</h2>
          <p>Refresh the page or try again after checking your environment configuration.</p>
        </div>
      );
    }

    return this.props.children;
  }
}
