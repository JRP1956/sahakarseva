import { Check as CheckIcon, Inbox, X } from "./icons";

export const Card = ({ title, action, children, className = "" }: { title?: string; action?: React.ReactNode; children: React.ReactNode; className?: string }) => (
  <section className={`bg-card border border-line rounded-card p-4 lg:p-6 ${className}`}>
    {(title || action) && (
      <div className="flex items-baseline justify-between gap-4 mb-4">
        {title && <h2 className="text-base font-semibold">{title}</h2>}
        {action}
      </div>
    )}
    {children}
  </section>
);

/* One hero figure per page (lead) plus quiet supporting stats. */
export const Stat = ({ label, value, lead = false, hint }: { label: string; value: string | number; lead?: boolean; hint?: string }) =>
  lead ? (
    <div className="bg-primary text-on-action rounded-card p-6 flex flex-col justify-between min-h-40">
      <div className="text-sm opacity-80">{label}</div>
      <div><div className="text-4xl lg:text-5xl font-semibold tnum leading-none tracking-tight">{value}</div>{hint && <div className="text-sm opacity-80 mt-2">{hint}</div>}</div>
    </div>
  ) : (
    <div className="py-1">
      <div className="text-2xl font-semibold tnum leading-tight">{value}</div>
      <div className="text-sm text-fg-2 mt-1">{label}</div>
    </div>
  );

export const Table = ({ head, rows, empty = "Nothing to show yet." }: { head: string[]; rows: React.ReactNode[][]; empty?: string }) =>
  rows.length === 0 ? <Empty>{empty}</Empty> : (
    <div className="scroll-x -mx-4 lg:-mx-6">
      <table className="w-full text-sm min-w-max">
        <thead className="sticky top-0 bg-card">
          <tr className="text-left text-fg-2 border-b border-line">{head.map((h) => <th key={h} className="py-2 px-4 lg:px-6 font-medium text-xs uppercase tracking-wide">{h}</th>)}</tr>
        </thead>
        <tbody>{rows.map((r, i) => (
          <tr key={i} className="border-b border-line last:border-0 hover:bg-sunken transition-colors">{r.map((c, j) => <td key={j} className="py-3 px-4 lg:px-6 align-top">{c}</td>)}</tr>))}</tbody>
      </table>
    </div>
  );

export const Empty = ({ children }: { children: React.ReactNode }) => (
  <div className="flex flex-col items-center justify-center text-center py-16 text-fg-2">
    <span className="text-2xl mb-3 text-fg-3"><Inbox /></span>
    <p className="text-sm max-w-sm">{children}</p>
  </div>
);

/* status -> feedback tone. Colour never stands alone: the word is always shown. */
const TONE: Record<string, string> = {
  neutral: "bg-secondary text-fg-2", info: "bg-info-bg text-info-fg", success: "bg-success-bg text-success-fg",
  warning: "bg-warning-bg text-warning-fg", error: "bg-error-bg text-error-fg", primary: "bg-primary text-on-action",
};
const STATUS_TONE: Record<string, string> = { requested: "neutral", assigned: "info", accepted: "info", in_progress: "warning", completed: "success", paid: "success", rated: "success", cancelled: "error" };

export const Badge = ({ children, tone = "neutral" }: { children: React.ReactNode; tone?: string }) => (
  <span className={`inline-flex items-center gap-1 text-xs font-medium px-2 py-0.5 rounded-full whitespace-nowrap ${TONE[STATUS_TONE[tone] ?? tone] ?? TONE.neutral}`}>{children}</span>
);

export const Check = ({ on, label }: { on: boolean; label: string }) => (
  <span className={`inline-flex items-center gap-1 text-xs mr-3 ${on ? "text-success-fg" : "text-fg-3"}`}>{on ? <CheckIcon /> : <X />}{label}</span>
);

export const PageHeader = ({ title, sub, action }: { title: React.ReactNode; sub?: React.ReactNode; action?: React.ReactNode }) => (
  <header className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4 sm:gap-6 mb-6 lg:mb-8">
    <div><h1 className="text-3xl lg:text-4xl font-semibold tracking-tight">{title}</h1>{sub && <p className="text-sm text-fg-2 mt-2">{sub}</p>}</div>
    {action}
  </header>
);
export const H1 = ({ children }: { children: React.ReactNode }) => <PageHeader title={children} />;

const BTN = "inline-flex items-center justify-center gap-2 h-9 px-4 rounded-btn text-sm font-medium transition-colors focus-visible:shadow-focus disabled:pointer-events-none [&:disabled:not([aria-busy=true])]:opacity-50";
export const btn = {
  primary: `${BTN} bg-primary text-on-action hover:bg-primary-hover active:bg-primary-active`,
  secondary: `${BTN} bg-transparent border border-line-strong text-fg hover:bg-secondary active:bg-secondary-hover`,
  danger: `${BTN} bg-danger text-on-action hover:bg-danger-hover`,
  link: "text-link underline-offset-4 hover:underline text-sm font-medium inline-flex items-center gap-1",
};

export const Filters = ({ items, current, href, label = (v) => v.replace("_", " ") || "All" }: { items: string[]; current: string; href: (v: string) => string; label?: (v: string) => string }) => (
  <nav aria-label="Filter" className="flex gap-1 mb-6 flex-wrap">{items.map((s) => (
    <a key={s} href={href(s)} aria-current={s === current ? "page" : undefined}
      className={`text-sm px-3 h-8 inline-flex items-center rounded-full border transition-colors ${s === current ? "bg-primary text-on-action border-primary" : "bg-transparent border-line text-fg-2 hover:bg-secondary hover:text-fg"}`}>
      {label(s)}</a>))}</nav>
);

export const Footer = ({ children }: { children: React.ReactNode }) => <p className="text-xs text-fg-3 mt-10 pt-4 border-t border-line">{children}</p>;
