"use client";
import dynamic from "next/dynamic";
import type { Point } from "./DemandMap";

const DemandMap = dynamic(() => import("./DemandMap"), { ssr: false, loading: () => <div className="h-96 skeleton" aria-busy="true" /> });
export default function MapClient({ points }: { points: Point[] }) { return <DemandMap points={points} />; }
