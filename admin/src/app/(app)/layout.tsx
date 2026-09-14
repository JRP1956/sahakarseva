import Nav from "@/components/Nav";
import "leaflet/dist/leaflet.css";

const NAV = [["/", "Dashboard"], ["/bookings", "Bookings"], ["/workers", "Workers"], ["/customers", "Customers"], ["/cooperatives", "Cooperatives"],
  ["/services", "Services"], ["/payments", "Payments"], ["/welfare", "Welfare"], ["/forecast", "AI Forecast"]];

export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen">
      <aside className="w-60 shrink-0 border-r border-line bg-card px-4 py-6 flex flex-col sticky top-0 h-screen">
        <div className="px-3 mb-8">
          <div className="font-semibold text-lg tracking-tight">SahakarSeva</div>
          <div className="text-xs text-fg-2">Federation Admin</div>
        </div>
        <Nav items={NAV} />
        <form action="/api/logout" method="post" className="px-3"><button className="text-sm text-fg-2 hover:text-fg transition-colors">Sign out</button></form>
      </aside>
      <main className="flex-1 min-w-0 px-10 py-8 max-w-7xl">{children}</main>
    </div>
  );
}
