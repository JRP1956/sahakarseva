"use client";
import { CircleMarker, MapContainer, Popup, TileLayer } from "react-leaflet";

export type Point = { lat: number; lng: number; service: string; status: string; is_emergency: boolean };

// ponytail: leaflet paints outside the CSS cascade, so token colours are read once at mount; markers keep the
// old colour if the OS theme flips while the map is open. Upgrade: re-read on a matchMedia change event.
const tone = (name: string) => getComputedStyle(document.documentElement).getPropertyValue(name).trim();

export default function DemandMap({ points }: { points: Point[] }) {
  const c = { open: tone("--color-action-primary"), done: tone("--color-feedback-success-icon"), urgent: tone("--color-feedback-error-icon") };
  return (
    <MapContainer center={[19.13, 72.9]} zoom={11} className="h-72 lg:h-96 w-full rounded-card z-0">
      <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" attribution="© OpenStreetMap" />
      {points.map((p, i) => (
        <CircleMarker key={i} center={[p.lat, p.lng]} radius={6}
          pathOptions={{ color: p.is_emergency ? c.urgent : p.status === "rated" || p.status === "paid" ? c.done : c.open, fillOpacity: 0.7 }}>
          <Popup>{p.service}{p.is_emergency ? " (emergency)" : ""}, {p.status}</Popup>
        </CircleMarker>
      ))}
    </MapContainer>
  );
}
