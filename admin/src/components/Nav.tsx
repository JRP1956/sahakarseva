"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Nav({ items }: { items: string[][] }) {
  const path = usePathname();
  return (
    <nav className="space-y-0.5 flex-1">
      {items.map(([href, label]) => {
        const on = href === "/" ? path === "/" : path.startsWith(href);
        return (
          <Link key={href} href={href} aria-current={on ? "page" : undefined}
            className={`block px-3 h-9 leading-9 rounded-btn text-sm transition-colors ${on ? "bg-selected text-fg font-medium" : "text-fg-2 hover:bg-secondary hover:text-fg"}`}>{label}</Link>
        );
      })}
    </nav>
  );
}
