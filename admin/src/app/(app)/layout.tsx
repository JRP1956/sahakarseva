import Nav from "@/components/Nav";
import "leaflet/dist/leaflet.css";

const NAV = [["/", "Dashboard"], ["/bookings", "Bookings"], ["/workers", "Workers"], ["/customers", "Customers"], ["/cooperatives", "Cooperatives"],
  ["/services", "Services"], ["/payments", "Payments"], ["/welfare", "Welfare"], ["/forecast", "AI Forecast"]];

/* Desktop: fixed sidebar. Under lg: a top bar with the nav as a horizontal scroller. */
export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="lg:flex min-h-screen">
      <aside className="lg:w-60 lg:shrink-0 lg:border-r lg:border-b-0 border-b border-line bg-card lg:px-4 lg:py-6 lg:flex lg:flex-col lg:sticky lg:top-0 lg:h-screen">
        <div className="flex items-baseline justify-between px-4 pt-4 lg:px-3 lg:pt-0 lg:block lg:mb-8">
          <div>
            <div className="font-semibold text-lg tracking-tight">SahakarSeva</div>
            <div className="text-xs text-fg-2">Federation Admin</div>
          </div>
          <form action="/api/logout" method="post" className="lg:hidden"><button className="text-sm text-fg-2 hover:text-fg transition-colors">Sign out</button></form>
        </div>
        <Nav items={NAV} />
        <form action="/api/logout" method="post" className="px-3 hidden lg:block"><button className="text-sm text-fg-2 hover:text-fg transition-colors">Sign out</button></form>
      </aside>
      <main className="flex-1 min-w-0 px-4 py-6 lg:px-10 lg:py-8 max-w-7xl">{children}</main>
    </div>
  );
}
