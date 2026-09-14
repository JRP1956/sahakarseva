export const Card = ({ title, children, className = "" }: { title?: string; children: React.ReactNode; className?: string }) => (
  <section className={`bg-white rounded-xl shadow-sm border p-5 ${className}`}>
    {title && <h2 className="font-semibold mb-3">{title}</h2>}
    {children}
  </section>
);

export const Tile = ({ label, value }: { label: string; value: string | number }) => (
  <div className="bg-white rounded-xl shadow-sm border p-5">
    <div className="text-3xl font-semibold">{value}</div>
    <div className="text-sm text-gray-500">{label}</div>
  </div>
);

export const Table = ({ head, rows }: { head: string[]; rows: React.ReactNode[][] }) => (
  <div className="overflow-x-auto">
    <table className="w-full text-sm">
      <thead><tr className="text-left text-gray-500 border-b">{head.map((h) => <th key={h} className="py-2 pr-4 font-medium">{h}</th>)}</tr></thead>
      <tbody>{rows.map((r, i) => <tr key={i} className="border-b last:border-0">{r.map((c, j) => <td key={j} className="py-2 pr-4 align-top">{c}</td>)}</tr>)}</tbody>
    </table>
  </div>
);

const STATUS: Record<string, string> = { requested: "bg-gray-100", assigned: "bg-blue-100 text-blue-800", accepted: "bg-indigo-100 text-indigo-800",
  in_progress: "bg-amber-100 text-amber-800", completed: "bg-emerald-100 text-emerald-800", paid: "bg-emerald-200 text-emerald-900",
  rated: "bg-emerald-300 text-emerald-900", cancelled: "bg-red-100 text-red-800" };

export const Badge = ({ children, tone = "" }: { children: React.ReactNode; tone?: string }) => (
  <span className={`inline-block text-xs px-2 py-0.5 rounded-full ${STATUS[tone] ?? tone ?? "bg-gray-100"}`}>{children}</span>
);

export const Check = ({ on, label }: { on: boolean; label: string }) => (
  <span className={`text-xs mr-2 ${on ? "text-emerald-700" : "text-gray-300 line-through"}`}>{on ? "✓" : "✗"} {label}</span>
);

export const H1 = ({ children }: { children: React.ReactNode }) => <h1 className="text-2xl font-semibold mb-6">{children}</h1>;
