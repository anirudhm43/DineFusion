
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  LayoutDashboard,
  ShoppingBag,
  Utensils,
  Users,
  CalendarDays,
  Package,
  CreditCard,
  ChartNoAxesCombined,
  Building2,
  Search,
  Settings,
  ChefHat,
} from "lucide-react";

const navigation = [
  {
    title: "OVERVIEW",
    items: [
      { name: "Dashboard", href: "/", icon: LayoutDashboard },
      { name: "Orders", href: "/orders", icon: ShoppingBag },
      { name: "Menu Management", href: "/menu", icon: Utensils },
    ],
  },
  {
    title: "MANAGEMENT",
    items: [
      { name: "Customers", href: "/customers", icon: Users },
      { name: "Reservations", href: "/reservations", icon: CalendarDays },
      { name: "Inventory", href: "/inventory", icon: Package },
      { name: "Payments", href: "/payments", icon: CreditCard },
    ],
  },
  {
    title: "INSIGHTS",
    items: [
      { name: "Analytics", href: "/analytics", icon: ChartNoAxesCombined },
      { name: "Branches", href: "/branches", icon: Building2 },
      { name: "AI Menu Search", href: "/ai-search", icon: Search },
    ],
  },
];

export default function AppSidebar() {
  const pathname = usePathname();

  return (
    <aside className="hidden min-h-screen w-[250px] shrink-0 flex-col border-r border-slate-200 bg-white lg:flex">
      <div className="flex h-[76px] items-center gap-3 border-b border-slate-100 px-6">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-600 text-white">
          <ChefHat size={23} />
        </div>
        <div>
          <h1 className="text-lg font-bold tracking-tight text-slate-900">
            DineFusion
          </h1>
          <p className="text-[10px] font-semibold uppercase tracking-[2px] text-slate-400">
            Restaurant Suite
          </p>
        </div>
      </div>

      <nav className="flex-1 space-y-7 overflow-y-auto px-4 py-7">
        {navigation.map((section) => (
          <div key={section.title}>
            <p className="mb-3 px-3 text-[10px] font-bold tracking-[1.5px] text-slate-400">
              {section.title}
            </p>

            <div className="space-y-1">
              {section.items.map((item) => {
                const active = pathname === item.href;
                const Icon = item.icon;

                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={`flex items-center gap-3 rounded-xl px-3 py-2.5 text-[13px] font-medium transition ${
                      active
                        ? "bg-emerald-50 text-emerald-700"
                        : "text-slate-500 hover:bg-slate-50 hover:text-slate-900"
                    }`}
                  >
                    <Icon size={18} strokeWidth={1.8} />
                    {item.name}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      <div className="border-t border-slate-100 p-4">
        <Link
          href="/settings"
          className={`flex items-center gap-3 rounded-xl px-3 py-2.5 text-[13px] font-medium ${
            pathname === "/settings"
              ? "bg-emerald-50 text-emerald-700"
              : "text-slate-500 hover:bg-slate-50"
          }`}
        >
          <Settings size={18} />
          Settings
        </Link>

        <div className="mt-4 rounded-xl bg-slate-50 p-3">
          <p className="text-xs font-semibold text-slate-700">
            DineFusion Admin
          </p>
          <p className="mt-1 text-[10px] text-slate-400">
            Restaurant Management
          </p>
        </div>
      </div>
    </aside>
  );
}
