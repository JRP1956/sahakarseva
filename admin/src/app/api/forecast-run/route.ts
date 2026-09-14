import { NextResponse } from "next/server";
import { apiFetch } from "@/lib/api";

export async function POST() {
  return NextResponse.json(await apiFetch("/admin/forecast/run", { method: "POST" }));
}
