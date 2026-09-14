import type { Metadata } from "next";
import Link from "next/link";
import "./globals.css";
import "leaflet/dist/leaflet.css";

export const metadata: Metadata = { title: "Federation Admin", description: "Cooperative Gig Services Platform" };

const NAV = [["/", "Dashboard"], ["/workers", "Workers"], ["/customers", "Customers"], ["/bookings", "Bookings"], ["/cooperatives", "Cooperatives"],
  ["/services", "Services"], ["/payments", "Payments"], ["/welfare", "Welfare"], ["/forecast", "AI Forecast"]];

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="bg-gray-50 text-gray-900">
        <div className="flex min-h-screen">
          <aside className="w-56 bg-emerald-900 text-emerald-50 p-4 flex flex-col">
            <div className="font-semibold text-lg mb-6">SahakarSeva</div>
            <nav className="space-y-1 flex-1">
              {NAV.map(([href, label]) => (
                <Link key={href} href={href} className="block px-3 py-2 rounded hover:bg-emerald-800">{label}</Link>
              ))}
            </nav>
            <form action="/api/logout" method="post"><button className="text-sm text-emerald-200">Sign out</button></form>
          </aside>
          <main className="flex-1 p-8 max-w-7xl">{children}</main>
        </div>
      </body>
    </html>
  );
}
