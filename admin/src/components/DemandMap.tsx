"use client";
import { CircleMarker, MapContainer, Popup, TileLayer } from "react-leaflet";

export type Point = { lat: number; lng: number; service: string; status: string; is_emergency: boolean };

export default function DemandMap({ points }: { points: Point[] }) {
  return (
    <MapContainer center={[19.13, 72.9]} zoom={11} className="h-96 w-full rounded-lg z-0">
      <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" attribution="© OpenStreetMap" />
      {points.map((p, i) => (
        <CircleMarker key={i} center={[p.lat, p.lng]} radius={6}
          pathOptions={{ color: p.is_emergency ? "#dc2626" : p.status === "rated" || p.status === "paid" ? "#047857" : "#2563eb", fillOpacity: 0.7 }}>
          <Popup>{p.service}{p.is_emergency ? " (emergency)" : ""} — {p.status}</Popup>
        </CircleMarker>
      ))}
    </MapContainer>
  );
}
