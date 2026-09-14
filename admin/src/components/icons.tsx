// lucide icons as inline SVG (currentColor). Add here; never use emoji.
const P = { width: "1em", height: "1em", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", strokeWidth: 2, strokeLinecap: "round" as const, strokeLinejoin: "round" as const, "aria-hidden": true };
export const Check = () => <svg {...P}><path d="M20 6 9 17l-5-5" /></svg>;
export const X = () => <svg {...P}><path d="M18 6 6 18M6 6l12 12" /></svg>;
export const Alert = () => <svg {...P}><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3M12 9v4M12 17h.01" /></svg>;
export const Star = () => <svg {...P} fill="currentColor" stroke="none"><path d="M11.5 2.6a.6.6 0 0 1 1 0l2.6 5.5 6 .8a.6.6 0 0 1 .3 1l-4.4 4.2 1.1 6a.6.6 0 0 1-.9.6L12 17.9l-5.3 2.9a.6.6 0 0 1-.9-.6l1.1-6L2.5 9.9a.6.6 0 0 1 .3-1l6-.8z" /></svg>;
export const ArrowRight = () => <svg {...P}><path d="M5 12h14M12 5l7 7-7 7" /></svg>;
export const Loader = () => <svg {...P} className="spin"><path d="M21 12a9 9 0 1 1-6.2-8.6" /></svg>;
export const Zap = () => <svg {...P}><path d="M4 14a1 1 0 0 1-.8-1.6l9-12a1 1 0 0 1 1.8.7L13 9h7a1 1 0 0 1 .8 1.6l-9 12a1 1 0 0 1-1.8-.7L11 14z" /></svg>;
export const Inbox = () => <svg {...P}><path d="M22 12h-6l-2 3h-4l-2-3H2" /><path d="M5.5 5.1 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.5-6.9A2 2 0 0 0 16.8 4H7.2a2 2 0 0 0-1.7 1.1" /></svg>;
