import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { getFinanceMonitorSnapshot } from "@/lib/worldmonitor/finance";

export async function GET() {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const snapshot = await getFinanceMonitorSnapshot();
  return NextResponse.json(snapshot, {
    headers: {
      "Cache-Control": "private, max-age=15, stale-while-revalidate=30",
    },
  });
}
