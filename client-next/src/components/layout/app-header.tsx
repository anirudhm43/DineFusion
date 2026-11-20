
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Bell,
  ChevronDown,
  Search,
  UserRound,
} from "lucide-react";

const mobileLinks = [
  { name: "Dashboard", href: "/" },
  { name: "Orders", href: "/orders" },
  { name: "Menu", href: "/menu" },
  { name: "Analytics", href: "/analytics" },
];

export default function AppHeader() {
  const pathname = usePathname();

  const currentPage =
    mobileLinks.find((item) => item.href === pathname)?.name ||
    (pathname === "/" ? "Dashboard" : "Management");

  return (
    <header className="sticky top-0 z-30 border-b border-slate-200 bg-white/95 backdrop-blur">
      <div className="flex h-[76px] items-center justify-between gap-4 px-5 md:px-8">
        <div>
          <p className="text-xs text-slate-400">
            Restaurant Management
          </p>
          <h2 className="mt-1 text-lg font-bold text-slate-900">
            {currentPage}
          </h2>
        </div>

        <div className="flex items-center gap-3">
          <div className="hidden h-10 w-64 items-center gap-2 rounded-xl border border-slate-200 bg-slate-50 px-3 md:flex">
            <Search size={16} className="text-slate-400" />
            <input
              type="search"
              placeholder="Search anything..."
              className="w-full bg-transparent text-xs outline-none placeholder:text-slate-400"
            />
            <span className="rounded border border-slate-200 bg-white px-1.5 py-0.5 text-[10px] text-slate-400">
              /
            </span>
          </div>

          <button
            aria-label="Notifications"
            className="relative flex h-10 w-10 items-center justify-center rounded-xl border border-slate-200 text-slate-500 hover:bg-slate-50"
          >
            <Bell size={18} />
            <span className="absolute right-2 top-2 h-2 w-2 rounded-full bg-emerald-500 ring-2 ring-white" />
          </button>

          <div className="hidden h-10 items-center gap-2 rounded-xl border border-slate-200 px-2.5 sm:flex">
            <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-emerald-100 text-emerald-700">
              <UserRound size={15} />
            </div>

            <div>
              <p className="text-xs font-semibold text-slate-800">
                Admin
              </p>
              <p className="text-[10px] text-slate-400">
                Administrator
              </p>
            </div>

            <ChevronDown size={14} className="text-slate-400" />
          </div>
        </div>
      </div>

      <nav className="flex gap-2 overflow-x-auto px-5 pb-3 lg:hidden">
        {mobileLinks.map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className={`whitespace-nowrap rounded-lg px-3 py-2 text-xs font-medium ${
              pathname === item.href
                ? "bg-emerald-50 text-emerald-700"
                : "text-slate-500 hover:bg-slate-50"
            }`}
          >
            {item.name}
          </Link>
        ))}
      </nav>
    </header>
  );
}
