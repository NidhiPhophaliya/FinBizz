import { auth } from "@clerk/nextjs/server";
import { NextResponse } from "next/server";
import { getSupabaseAdmin } from "@/lib/supabase/admin";

interface WatchlistBody {
  symbol?: string;
  assetType?: "stock" | "crypto" | "commodity" | "index";
}

export async function GET() {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  const { data, error } = await getSupabaseAdmin().from("watchlist").select("*").eq("user_id", userId);
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
  return NextResponse.json(data);
}

export async function POST(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  const body = (await req.json()) as WatchlistBody;
  const { error } = await getSupabaseAdmin().from("watchlist").upsert({
    user_id: userId,
    symbol: (body.symbol ?? "").toUpperCase(),
    asset_type: body.assetType ?? "stock",
  });
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
  return NextResponse.json({ success: true });
}

export async function DELETE(req: Request) {
  const { userId } = await auth();
  if (!userId) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }
  const body = (await req.json()) as WatchlistBody;
  await getSupabaseAdmin()
    .from("watchlist")
    .delete()
    .eq("user_id", userId)
    .eq("symbol", (body.symbol ?? "").toUpperCase());
  return NextResponse.json({ success: true });
}
