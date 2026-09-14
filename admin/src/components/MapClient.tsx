"use client";
import dynamic from "next/dynamic";
import type { Point } from "./DemandMap";

const DemandMap = dynamic(() => import("./DemandMap"), { ssr: false, loading: () => <div className="h-96 bg-gray-100 rounded-lg" /> });
export default function MapClient({ points }: { points: Point[] }) { return <DemandMap points={points} />; }
