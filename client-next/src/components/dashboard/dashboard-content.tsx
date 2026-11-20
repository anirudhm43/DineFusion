
"use client";

import { useCallback, useEffect, useState } from "react";
import {
  Area,
  AreaChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import {
  ArrowDownRight,
  ArrowUpRight,
  IndianRupee,
  ShoppingBag,
  Users,
  Clock3,
  RefreshCw,
  TrendingUp,
  CalendarDays,
  AlertCircle,
} from "lucide-react";

import { apiGet } from "@/lib/api";

type DashboardStats = {
  success: boolean;
  totalOrders: number;
  pendingOrders: number;
  totalCustomers: number;
  totalRevenue: number;
};

type Order = {
  id: string;
  customer: string;
  item: string;
  amount: number;
  status: string;
  time: string;
};

type RecentOrdersResponse = {
  success: boolean;
  count: number;
  orders: Order[];
};

type RevenueApiPoint = {
  date: string;
  revenue: number;
};

type RevenueResponse = {
  success: boolean;
  period: string;
  data: RevenueApiPoint[];
};

type RevenuePoint = {
  label: string;
  revenue: number;
};

type RevenuePeriod = "week" | "month" | "year";

function formatCurrency(value: number | null | undefined) {
  if (value === null || value === undefined || !Number.isFinite(value)) {
    return "—";
  }

  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(value);
}

function formatDate(value?: string) {
  if (!value) return "—";

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) return "—";

  return date.toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
}

function formatRevenueLabel(value: string, period: RevenuePeriod) {
  if (!value) return "—";

  let date: Date;

  if (/^\d{4}-\d{2}$/.test(value)) {
    date = new Date(`${value}-01T00:00:00`);
  } else if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    date = new Date(`${value}T00:00:00`);
  } else {
    return value;
  }

  if (Number.isNaN(date.getTime())) return value;

  if (period === "year") {
    return date.toLocaleDateString("en-IN", {
      month: "short",
      year: "2-digit",
    });
  }

  return date.toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
  });
}

function getStatusStyle(status: string) {
  switch (status.toUpperCase()) {
    case "COMPLETED":
      return "bg-emerald-50 text-emerald-700";

    case "READY":
      return "bg-blue-50 text-blue-700";

    case "PREPARING":
      return "bg-amber-50 text-amber-700";

    case "PLACED":
      return "bg-violet-50 text-violet-700";

    case "CANCELLED":
      return "bg-red-50 text-red-700";

    default:
      return "bg-slate-100 text-slate-600";
  }
}

export default function DashboardContent() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [orders, setOrders] = useState<Order[]>([]);
  const [revenue, setRevenue] = useState<RevenuePoint[]>([]);

  // Year is the initial selection because the existing sample
  // orders are from October and November 2026.
  const [period, setPeriod] = useState<RevenuePeriod>("year");

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const loadDashboard = useCallback(async () => {
    setLoading(true);
    setError("");

    const results = await Promise.allSettled([
      apiGet<DashboardStats>("/dashboard/stats"),
      apiGet<RecentOrdersResponse>("/dashboard/recent-orders"),
      apiGet<RevenueResponse>(
        `/dashboard/revenue?period=${period}`,
      ),
    ]);

    const errors: string[] = [];

    // 1. Dashboard statistics
    const statsResult = results[0];

    if (statsResult.status === "fulfilled") {
      if (statsResult.value.success) {
        setStats(statsResult.value);
      } else {
        errors.push("Statistics could not be loaded.");
      }
    } else {
      errors.push("Statistics API is unavailable.");
    }

    // 2. Recent orders
    const ordersResult = results[1];

    if (ordersResult.status === "fulfilled") {
      if (ordersResult.value.success) {
        setOrders(ordersResult.value.orders ?? []);
      } else {
        errors.push("Recent orders could not be loaded.");
      }
    } else {
      errors.push("Recent orders API is unavailable.");
    }

    // 3. Revenue analytics
    const revenueResult = results[2];

    if (revenueResult.status === "fulfilled") {
      if (revenueResult.value.success) {
        const points = (revenueResult.value.data ?? []).map(
          (item) => ({
            label: formatRevenueLabel(item.date, period),
            revenue: Number(item.revenue),
          }),
        );

        setRevenue(points);
      } else {
        setRevenue([]);
        errors.push("Revenue analytics could not be loaded.");
      }
    } else {
      setRevenue([]);
      errors.push("Revenue analytics API is unavailable.");
    }

    setError(errors.join(" "));
    setLoading(false);
  }, [period]);

  useEffect(() => {
    void loadDashboard();
  }, [loadDashboard]);

  const cards = [
    {
      title: "Total Revenue",
      value: formatCurrency(stats?.totalRevenue),
      icon: IndianRupee,
      note: "Successful payment revenue",
      iconStyle: "bg-emerald-50 text-emerald-700",
    },
    {
      title: "Total Orders",
      value: stats?.totalOrders.toLocaleString("en-IN") ?? "—",
      icon: ShoppingBag,
      note: "All restaurant orders",
      iconStyle: "bg-blue-50 text-blue-700",
    },
    {
      title: "Customers",
      value: stats?.totalCustomers.toLocaleString("en-IN") ?? "—",
      icon: Users,
      note: "Registered customers",
      iconStyle: "bg-violet-50 text-violet-700",
    },
    {
      title: "Pending Orders",
      value: stats?.pendingOrders.toLocaleString("en-IN") ?? "—",
      icon: Clock3,
      note: "Awaiting completion",
      iconStyle: "bg-amber-50 text-amber-700",
    },
  ];

  return (
    <div className="space-y-7">

      {/* PAGE HEADER */}

      <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
        <div>
          <p className="text-sm text-slate-500">
            Here's what's happening with your restaurant.
          </p>

          <h1 className="mt-1 text-2xl font-bold tracking-tight text-slate-900">
            Dashboard Overview
          </h1>
        </div>

        <button
          onClick={() => void loadDashboard()}
          disabled={loading}
          className="flex items-center justify-center gap-2 self-start rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-xs font-semibold text-slate-600 transition hover:bg-slate-50 disabled:opacity-50"
        >
          <RefreshCw
            size={14}
            className={loading ? "animate-spin" : ""}
          />

          {loading ? "Refreshing..." : "Refresh data"}
        </button>
      </div>

      {/* API ERROR */}

      {error && (
        <div className="flex items-start gap-3 rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800">
          <AlertCircle size={18} className="mt-0.5 shrink-0" />
          <p>{error}</p>
        </div>
      )}

      {/* STATISTICS CARDS */}

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {cards.map((card) => {
          const Icon = card.icon;

          return (
            <div
              key={card.title}
              className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md"
            >
              <div className="flex items-center justify-between">
                <p className="text-xs font-medium text-slate-500">
                  {card.title}
                </p>

                <div
                  className={`flex h-10 w-10 items-center justify-center rounded-xl ${card.iconStyle}`}
                >
                  <Icon size={19} />
                </div>
              </div>

              <p className="mt-4 text-2xl font-bold tracking-tight text-slate-900">
                {loading && !stats ? "..." : card.value}
              </p>

              <p className="mt-2 text-[11px] text-slate-400">
                {card.note}
              </p>
            </div>
          );
        })}
      </section>

      {/* REVENUE CHART AND INSIGHTS */}

      <section className="grid gap-5 xl:grid-cols-[1.65fr_1fr]">

        {/* REVENUE CHART */}

        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">

          <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
            <div>
              <h3 className="font-bold text-slate-900">
                Revenue Overview
              </h3>

              <p className="mt-1 text-xs text-slate-400">
                Track your restaurant revenue performance
              </p>
            </div>

            <div className="flex flex-wrap gap-1 rounded-xl bg-slate-100 p-1">
              {(["week", "month", "year"] as RevenuePeriod[]).map(
                (item) => (
                  <button
                    key={item}
                    onClick={() => setPeriod(item)}
                    className={`rounded-lg px-3 py-2 text-xs font-semibold capitalize transition ${
                      period === item
                        ? "bg-white text-emerald-700 shadow-sm"
                        : "text-slate-500 hover:text-slate-800"
                    }`}
                  >
                    {item}
                  </button>
                ),
              )}
            </div>
          </div>

          <div className="mt-6 h-[290px] w-full">
            {loading && revenue.length === 0 ? (
              <div className="flex h-full items-center justify-center rounded-xl bg-slate-50">
                <RefreshCw
                  size={22}
                  className="animate-spin text-emerald-600"
                />
                <span className="ml-3 text-sm text-slate-500">
                  Loading revenue data...
                </span>
              </div>
            ) : revenue.length > 0 ? (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart
                  data={revenue}
                  margin={{
                    top: 10,
                    right: 12,
                    left: 0,
                    bottom: 0,
                  }}
                >
                  <defs>
                    <linearGradient
                      id="revenueGradient"
                      x1="0"
                      y1="0"
                      x2="0"
                      y2="1"
                    >
                      <stop
                        offset="0%"
                        stopColor="#059669"
                        stopOpacity={0.22}
                      />

                      <stop
                        offset="100%"
                        stopColor="#059669"
                        stopOpacity={0.01}
                      />
                    </linearGradient>
                  </defs>

                  <CartesianGrid
                    stroke="#e2e8f0"
                    strokeDasharray="4 4"
                    vertical={false}
                  />

                  <XAxis
                    dataKey="label"
                    tick={{
                      fontSize: 11,
                      fill: "#94a3b8",
                    }}
                    axisLine={false}
                    tickLine={false}
                  />

                  <YAxis
                    tick={{
                      fontSize: 11,
                      fill: "#94a3b8",
                    }}
                    axisLine={false}
                    tickLine={false}
                    tickFormatter={(value) => `₹${value}`}
                    width={65}
                  />

                  <Tooltip
                    contentStyle={{
                      borderRadius: "12px",
                      border: "1px solid #e2e8f0",
                      fontSize: "12px",
                    }}
                    formatter={(value) => [
                      formatCurrency(Number(value)),
                      "Revenue",
                    ]}
                  />

                  <Area
                    type="monotone"
                    dataKey="revenue"
                    stroke="#059669"
                    strokeWidth={2.5}
                    fill="url(#revenueGradient)"
                    dot={{
                      r: 4,
                      fill: "#059669",
                      strokeWidth: 2,
                      stroke: "#ffffff",
                    }}
                    activeDot={{
                      r: 6,
                      stroke: "#059669",
                      strokeWidth: 2,
                      fill: "#ffffff",
                    }}
                  />
                </AreaChart>
              </ResponsiveContainer>
            ) : (
              <div className="flex h-full flex-col items-center justify-center rounded-xl bg-slate-50 text-center">
                <TrendingUp
                  size={30}
                  className="text-slate-300"
                />

                <p className="mt-3 text-sm font-semibold text-slate-600">
                  No revenue data available
                </p>

                <p className="mt-1 max-w-xs text-xs leading-5 text-slate-400">
                  No matching orders were found for this period.
                  Try selecting another time range.
                </p>
              </div>
            )}
          </div>

          <div className="mt-3 flex items-center justify-between border-t border-slate-100 pt-4">
            <div className="flex items-center gap-2 text-xs text-slate-500">
              <span className="h-2.5 w-2.5 rounded-full bg-emerald-600" />
              Revenue
            </div>

            <p className="text-sm font-bold text-slate-800">
              {revenue.length > 0
                ? formatCurrency(
                    revenue.reduce(
                      (total, point) => total + point.revenue,
                      0,
                    ),
                  )
                : "—"}
            </p>
          </div>
        </div>

        {/* QUICK INSIGHTS */}

        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <h3 className="font-bold text-slate-900">
            Quick Insights
          </h3>

          <p className="mt-1 text-xs text-slate-400">
            Current restaurant summary
          </p>

          <div className="mt-5 space-y-4">

            <div className="rounded-xl bg-emerald-50 p-4">
              <div className="flex items-center gap-2 text-emerald-700">
                <ArrowUpRight size={17} />

                <p className="text-xs font-semibold">
                  Revenue Overview
                </p>
              </div>

              <p className="mt-2 text-xs leading-5 text-emerald-800">
                Total successful payment revenue is{" "}
                <strong>
                  {formatCurrency(stats?.totalRevenue)}
                </strong>.
              </p>
            </div>

            <div className="rounded-xl bg-blue-50 p-4">
              <div className="flex items-center gap-2 text-blue-700">
                <ShoppingBag size={17} />

                <p className="text-xs font-semibold">
                  Order Activity
                </p>
              </div>

              <p className="mt-2 text-xs leading-5 text-blue-800">
                Your restaurant has received{" "}
                <strong>{stats?.totalOrders ?? "—"}</strong>{" "}
                orders in total.
              </p>
            </div>

            <div className="rounded-xl bg-amber-50 p-4">
              <div className="flex items-center gap-2 text-amber-700">
                <ArrowDownRight size={17} />

                <p className="text-xs font-semibold">
                  Pending Orders
                </p>
              </div>

              <p className="mt-2 text-xs leading-5 text-amber-800">
                <strong>{stats?.pendingOrders ?? "—"}</strong>{" "}
                orders are awaiting completion.
              </p>
            </div>

            <div className="rounded-xl bg-violet-50 p-4">
              <div className="flex items-center gap-2 text-violet-700">
                <CalendarDays size={17} />

                <p className="text-xs font-semibold">
                  Analytics Period
                </p>
              </div>

              <p className="mt-2 text-xs leading-5 text-violet-800">
                Currently viewing{" "}
                <strong className="capitalize">{period}</strong>{" "}
                revenue analytics.
              </p>
            </div>

          </div>
        </div>
      </section>

      {/* RECENT ORDERS */}

      <section className="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">

        <div className="flex flex-col justify-between gap-3 border-b border-slate-100 px-5 py-5 sm:flex-row sm:items-center">
          <div>
            <h3 className="font-bold text-slate-900">
              Recent Orders
            </h3>

            <p className="mt-1 text-xs text-slate-400">
              Latest orders received by your restaurant
            </p>
          </div>

          <span className="self-start rounded-lg bg-slate-100 px-3 py-2 text-xs font-semibold text-slate-600">
            {orders.length} orders
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full min-w-[750px] text-left">

            <thead className="bg-slate-50 text-[10px] uppercase tracking-wider text-slate-400">
              <tr>
                <th className="px-5 py-4 font-semibold">
                  Order ID
                </th>

                <th className="px-5 py-4 font-semibold">
                  Customer
                </th>

                <th className="px-5 py-4 font-semibold">
                  Items
                </th>

                <th className="px-5 py-4 font-semibold">
                  Date
                </th>

                <th className="px-5 py-4 font-semibold">
                  Amount
                </th>

                <th className="px-5 py-4 font-semibold">
                  Status
                </th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-100 text-xs">

              {orders.map((order) => (
                <tr
                  key={order.id}
                  className="transition hover:bg-slate-50"
                >
                  <td className="whitespace-nowrap px-5 py-4 font-semibold text-slate-800">
                    {order.id}
                  </td>

                  <td className="whitespace-nowrap px-5 py-4 font-medium text-slate-700">
                    {order.customer}
                  </td>

                  <td className="max-w-[260px] px-5 py-4 text-slate-500">
                    {order.item}
                  </td>

                  <td className="whitespace-nowrap px-5 py-4 text-slate-500">
                    {formatDate(order.time)}
                  </td>

                  <td className="whitespace-nowrap px-5 py-4 font-semibold text-slate-800">
                    {formatCurrency(order.amount)}
                  </td>

                  <td className="whitespace-nowrap px-5 py-4">
                    <span
                      className={`rounded-full px-2.5 py-1 text-[10px] font-semibold ${getStatusStyle(order.status)}`}
                    >
                      {order.status}
                    </span>
                  </td>
                </tr>
              ))}

              {!loading && orders.length === 0 && (
                <tr>
                  <td
                    colSpan={6}
                    className="px-5 py-12 text-center text-sm text-slate-400"
                  >
                    No recent orders were returned by the API.
                  </td>
                </tr>
              )}

              {loading && orders.length === 0 && (
                <tr>
                  <td
                    colSpan={6}
                    className="px-5 py-12 text-center text-sm text-slate-400"
                  >
                    Loading recent orders...
                  </td>
                </tr>
              )}

            </tbody>
          </table>
        </div>
      </section>

      {/* FOOTER */}

      <div className="flex flex-wrap items-center justify-between gap-2 pb-2 text-[11px] text-slate-400">
        <p>DineFusion Restaurant Management System</p>
        <p>Live data from Express API and MySQL</p>
      </div>

    </div>
  );
}
