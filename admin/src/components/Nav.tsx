"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Nav({ items }: { items: string[][] }) {
  const path = usePathname();
  return (
    <nav className="flex gap-1 overflow-x-auto px-4 py-3 scroll-x [scrollbar-width:none] lg:block lg:space-y-0.5 lg:flex-1 lg:overflow-visible lg:px-0 lg:py-0" aria-label="Main">
      {items.map(([href, label]) => {
        const on = href === "/" ? path === "/" : path.startsWith(href);
        return (
          <Link key={href} href={href} aria-current={on ? "page" : undefined}
            className={`shrink-0 whitespace-nowrap block px-3 h-9 leading-9 rounded-btn text-sm transition-colors ${on ? "bg-selected text-fg font-medium" : "text-fg-2 hover:bg-secondary hover:text-fg"}`}>{label}</Link>
        );
      })}
    </nav>
  );
}
