import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = { title: "SahakarSeva Federation Admin", description: "Cooperative Gig Services Platform" };

// follow the OS theme; the token layer switches at [data-theme="dark"]
const THEME = `(function(){var m=matchMedia('(prefers-color-scheme: dark)');function s(){document.documentElement.dataset.theme=m.matches?'dark':'light'}s();m.addEventListener('change',s)})()`;

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head><script dangerouslySetInnerHTML={{ __html: THEME }} /></head>
      <body>{children}</body>
    </html>
  );
}
