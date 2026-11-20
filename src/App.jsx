
import { useEffect, useMemo, useState } from "react";

import {
  LayoutDashboard,
  ShoppingBag,
  Utensils,
  Users,
  CalendarDays,
  Package,
  CreditCard,
  Settings,
  Search,
  Bell,
  ChevronDown,
  ArrowUpRight,
  CheckCircle2,
  ChefHat,
  Menu,
  X,
  Clock,
  Filter,
  RefreshCw,
  Eye,
  Receipt,
  TrendingUp,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";

import {
  ResponsiveContainer,
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
} from "recharts";

// ==========================================
// API CONFIGURATION
// ==========================================

const API_BASE_URL = "http://localhost:5000/api";

// ==========================================
// GENERATE REVENUE CHART DATA
// ==========================================

function generateRevenueChartData(period, apiData = []) {
  const safeData = Array.isArray(apiData) ? apiData : [];

  const revenueMap = new Map(
    safeData.map((item) => [
      item.date,
      Number(item.revenue) || 0,
    ])
  );

  const now = new Date();
  const year = now.getFullYear();
  const month = now.getMonth();

  if (period === "week") {
    const today = new Date(year, month, now.getDate());
    const monday = new Date(today);

    monday.setDate(
      today.getDate() - ((today.getDay() + 6) % 7)
    );

    return Array.from({ length: 7 }, (_, index) => {
      const date = new Date(monday);
      date.setDate(monday.getDate() + index);

      const key = [
        date.getFullYear(),
        String(date.getMonth() + 1).padStart(2, "0"),
        String(date.getDate()).padStart(2, "0"),
      ].join("-");

      return {
        day: date.toLocaleDateString("en-IN", {
          weekday: "short",
        }),
        revenue: revenueMap.get(key) || 0,
      };
    });
  }

  if (period === "month") {
    const daysInMonth = new Date(
      year,
      month + 1,
      0
    ).getDate();

    return Array.from({ length: daysInMonth }, (_, index) => {
      const day = index + 1;

      const key = `${year}-${String(month + 1).padStart(
        2,
        "0"
      )}-${String(day).padStart(2, "0")}`;

      return {
        day: String(day),
        revenue: revenueMap.get(key) || 0,
      };
    });
  }

  return Array.from({ length: 12 }, (_, index) => {
    const key = `${year}-${String(index + 1).padStart(
      2,
      "0"
    )}`;

    return {
      day: new Date(year, index, 1).toLocaleDateString(
        "en-IN",
        { month: "short" }
      ),
      revenue: revenueMap.get(key) || 0,
    };
  });
}

// ==========================================
// NAVIGATION
// ==========================================

const navigation = [
  { label: "Overview", icon: LayoutDashboard },
  { label: "Orders", icon: ShoppingBag },
  { label: "Menu", icon: Utensils },
  { label: "Customers", icon: Users },
  { label: "Reservations", icon: CalendarDays },
  { label: "Inventory", icon: Package },
  { label: "Payments", icon: CreditCard },
];

// ==========================================
// CURRENCY FORMATTER
// ==========================================

function formatCurrency(amount) {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(Number(amount) || 0);
}

// ==========================================
// SIDEBAR
// ==========================================

function Sidebar({ active, setActive, open, setOpen }) {
  return (
    <aside
      className={`fixed inset-y-0 left-0 z-30 flex w-64 flex-col bg-[#171c2e] text-white transition-transform lg:translate-x-0 ${
        open ? "translate-x-0" : "-translate-x-full"
      }`}
    >
      <div className="flex h-20 items-center gap-3 border-b border-white/10 px-6">
        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-400 text-[#171c2e]">
          <ChefHat size={23} />
        </div>

        <div>
          <h1 className="text-xl font-bold tracking-wide">
            DineFusion
          </h1>

          <p className="text-[10px] uppercase tracking-[2px] text-slate-400">
            Restaurant management
          </p>
        </div>

        <button
          className="ml-auto lg:hidden"
          onClick={() => setOpen(false)}
          aria-label="Close sidebar"
        >
          <X />
        </button>
      </div>

      <div className="px-5 pt-8 pb-3 text-[10px] font-semibold uppercase tracking-[2px] text-slate-500">
        Workspace
      </div>

      <nav className="flex-1 space-y-1 px-3">
        {navigation.map(({ label, icon: Icon }) => (
          <button
            key={label}
            onClick={() => {
              setActive(label);
              setOpen(false);
            }}
            className={`flex w-full items-center gap-3 rounded-xl px-4 py-3 text-sm transition ${
              active === label
                ? "bg-amber-400 font-semibold text-[#171c2e] shadow-lg shadow-amber-400/10"
                : "text-slate-300 hover:bg-white/5 hover:text-white"
            }`}
          >
            <Icon size={18} />
            {label}
          </button>
        ))}
      </nav>

      <div className="border-t border-white/10 p-4">
        <button
          onClick={() => {
            setActive("Settings");
            setOpen(false);
          }}
          className="flex w-full items-center gap-3 rounded-xl px-4 py-3 text-sm text-slate-300 hover:bg-white/5"
        >
          <Settings size={18} />
          Settings
        </button>

        <div className="mt-4 flex items-center gap-3 rounded-xl bg-white/5 p-3">
          <div className="flex h-9 w-9 items-center justify-center rounded-full bg-amber-400 font-bold text-[#171c2e]">
            A
          </div>

          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-medium">
              Administrator
            </p>

            <p className="text-xs text-slate-400">
              DineFusion Central
            </p>
          </div>

          <ChevronDown size={16} className="text-slate-400" />
        </div>
      </div>
    </aside>
  );
}

// ==========================================
// STATISTICS CARD
// ==========================================

function StatCard({ title, value, icon: Icon }) {
  return (
    <div className="rounded-2xl border border-slate-100 bg-white p-5 shadow-sm">
      <div className="flex items-center justify-between">
        <span className="text-sm text-slate-500">
          {title}
        </span>

        <div className="rounded-xl bg-amber-50 p-2.5 text-amber-600">
          <Icon size={19} />
        </div>
      </div>

      <div className="mt-4 text-2xl font-bold tracking-tight text-slate-800">
        {value}
      </div>

      <div className="mt-2 text-xs text-slate-400">
        Live database statistics
      </div>
    </div>
  );
}

// ==========================================
// ORDER STATUS BADGE
// ==========================================

function StatusBadge({ status }) {
  const normalizedStatus = status?.toUpperCase();

  const styles = {
    COMPLETED: "bg-emerald-50 text-emerald-700",
    PREPARING: "bg-amber-50 text-amber-700",
    READY: "bg-blue-50 text-blue-700",
    PLACED: "bg-purple-50 text-purple-700",
    CANCELLED: "bg-rose-50 text-rose-700",
  };

  const displayStatus = normalizedStatus
    ? normalizedStatus.charAt(0) +
      normalizedStatus.slice(1).toLowerCase()
    : "Unknown";

  return (
    <span
      className={`rounded-full px-3 py-1.5 text-xs font-semibold ${
        styles[normalizedStatus] ||
        "bg-slate-100 text-slate-600"
      }`}
    >
      {displayStatus}
    </span>
  );
}

// ==========================================
// FORMAT ORDER DATE AND TIME
// ==========================================

function formatOrderTime(dateValue) {
  if (!dateValue) return "N/A";

  const date = new Date(dateValue);

  if (Number.isNaN(date.getTime())) {
    return "N/A";
  }

  return date.toLocaleString("en-IN", {
    timeZone: "Asia/Kolkata",
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: true,
  });
}

// ==========================================
// ORDER SUMMARY CARD
// ==========================================

function OrderSummaryCard({ title, count, icon: Icon }) {
  return (
    <div className="rounded-2xl border border-slate-100 bg-white p-5 shadow-sm">
      <div className="flex items-center justify-between">
        <p className="text-sm text-slate-500">{title}</p>

        <div className="rounded-xl bg-amber-50 p-2.5 text-amber-600">
          <Icon size={19} />
        </div>
      </div>

      <p className="mt-4 text-2xl font-bold text-slate-800">
        {count}
      </p>
    </div>
  );
}

// ==========================================
// ORDER DETAILS MODAL
// ==========================================

function OrderDetailsModal({
  order,
  loading,
  error,
  onClose,
  onStatusChange,
  statusUpdating,
  statusUpdateError,
  statusUpdateMessage,
}) {
  const [newStatus, setNewStatus] = useState("");

  useEffect(() => {
    setNewStatus(order?.status || "");
  }, [order?.status]);

  if (!loading && !error && !order) {
    return null;
  }

  const items = Array.isArray(order?.items)
    ? order.items
    : [];

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto bg-slate-950/50 p-4"
      onClick={onClose}
    >
      <div
        className="my-8 w-full max-w-2xl rounded-2xl bg-white p-6 shadow-xl"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="flex items-start justify-between">
          <div>
            <p className="text-xs font-medium uppercase tracking-wider text-slate-400">
              Order details
            </p>

            <h3 className="mt-1 text-xl font-bold text-slate-800">
              {order?.id || "Order information"}
            </h3>
          </div>

          <button
            onClick={onClose}
            className="rounded-lg p-2 text-slate-400 hover:bg-slate-100"
            aria-label="Close order details"
          >
            <X size={20} />
          </button>
        </div>

        {loading ? (
          <div className="flex flex-col items-center justify-center py-16 text-slate-400">
            <RefreshCw size={26} className="mb-3 animate-spin" />
            <p className="text-sm">Loading complete order details...</p>
          </div>
        ) : error ? (
          <div className="mt-6 rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm text-rose-700">
            {error}
          </div>
        ) : order ? (
          <>
            <div className="mt-5 grid gap-4 sm:grid-cols-2">
              <div className="rounded-xl bg-slate-50 p-4">
                <p className="text-xs text-slate-400">Customer</p>
                <p className="mt-1 font-semibold text-slate-800">
                  {order.customer || "N/A"}
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-4">
                <p className="text-xs text-slate-400">Order type</p>
                <p className="mt-1 font-semibold text-slate-800">
                  {order.orderType || "N/A"}
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-4">
                <p className="text-xs text-slate-400">Order date</p>
                <p className="mt-1 font-semibold text-slate-800">
                  {formatOrderTime(order.orderDate)}
                </p>
              </div>

              <div className="rounded-xl bg-slate-50 p-4">
                <p className="text-xs text-slate-400">Current status</p>
                <div className="mt-2">
                  <StatusBadge status={order.status} />
                </div>
              </div>
            </div>

            {/* ORDER ITEMS */}

            <div className="mt-6">
              <h4 className="font-bold text-slate-800">
                Ordered items
              </h4>

              <div className="mt-3 overflow-x-auto rounded-xl border border-slate-100">
                <table className="w-full min-w-[420px] text-sm">
                  <thead className="bg-slate-50 text-xs text-slate-500">
                    <tr>
                      <th className="px-4 py-3 text-left font-semibold">
                        Item
                      </th>
                      <th className="px-4 py-3 text-center font-semibold">
                        Qty
                      </th>
                      <th className="px-4 py-3 text-right font-semibold">
                        Unit price
                      </th>
                      <th className="px-4 py-3 text-right font-semibold">
                        Subtotal
                      </th>
                    </tr>
                  </thead>

                  <tbody className="divide-y divide-slate-100">
                    {items.length > 0 ? (
                      items.map((item, index) => (
                        <tr
                          key={item.orderItemId || item.itemId || index}
                        >
                          <td className="px-4 py-3 font-medium text-slate-700">
                            {item.name || "Menu item"}
                          </td>

                          <td className="px-4 py-3 text-center text-slate-600">
                            {item.quantity ?? 0}
                          </td>

                          <td className="px-4 py-3 text-right text-slate-600">
                            {formatCurrency(item.unitPrice)}
                          </td>

                          <td className="px-4 py-3 text-right font-semibold text-slate-700">
                            {formatCurrency(item.subtotal)}
                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td
                          colSpan="4"
                          className="px-4 py-6 text-center text-slate-400"
                        >
                          No item details available.
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            {/* BILL BREAKDOWN */}

            <div className="mt-5 rounded-xl bg-slate-50 p-4">
              <h4 className="mb-3 font-bold text-slate-800">
                Bill summary
              </h4>

              <div className="space-y-2 text-sm">
                <div className="flex justify-between text-slate-500">
                  <span>Subtotal</span>
                  <span>{formatCurrency(order.subtotal)}</span>
                </div>

                <div className="flex justify-between text-slate-500">
                  <span>Tax</span>
                  <span>{formatCurrency(order.tax)}</span>
                </div>

                <div className="flex justify-between text-slate-500">
                  <span>Discount</span>
                  <span>{formatCurrency(order.discount)}</span>
                </div>

                <div className="mt-3 flex justify-between border-t border-slate-200 pt-3">
                  <span className="font-bold text-slate-700">
                    Total amount
                  </span>

                  <span className="text-lg font-bold text-slate-900">
                    {formatCurrency(order.totalAmount)}
                  </span>
                </div>
              </div>
            </div>

            {/* PAYMENT DETAILS */}

            <div className="mt-5">
              <h4 className="font-bold text-slate-800">
                Payment information
              </h4>

              {order.payment ? (
                <div className="mt-3 rounded-xl border border-slate-100 p-4">
                  <div className="grid gap-3 sm:grid-cols-2">
                    <div>
                      <p className="text-xs text-slate-400">
                        Payment method
                      </p>
                      <p className="mt-1 text-sm font-semibold text-slate-700">
                        {order.payment.method || "N/A"}
                      </p>
                    </div>

                    <div>
                      <p className="text-xs text-slate-400">
                        Payment status
                      </p>
                      <p className="mt-1 text-sm font-semibold text-slate-700">
                        {order.payment.status || "N/A"}
                      </p>
                    </div>

                    <div>
                      <p className="text-xs text-slate-400">
                        Payment amount
                      </p>
                      <p className="mt-1 text-sm font-semibold text-slate-700">
                        {formatCurrency(order.payment.amount)}
                      </p>
                    </div>

                    <div>
                      <p className="text-xs text-slate-400">
                        Payment date
                      </p>
                      <p className="mt-1 text-sm font-semibold text-slate-700">
                        {formatOrderTime(order.payment.paymentDate)}
                      </p>
                    </div>
                  </div>

                  {order.payment.transactionReference && (
                    <div className="mt-3 border-t border-slate-100 pt-3">
                      <p className="text-xs text-slate-400">
                        Transaction reference
                      </p>
                      <p className="mt-1 break-all text-sm font-medium text-slate-700">
                        {order.payment.transactionReference}
                      </p>
                    </div>
                  )}
                </div>
              ) : (
                <p className="mt-3 rounded-xl bg-slate-50 p-4 text-sm text-slate-500">
                  No payment record is associated with this order.
                </p>
              )}
            </div>

            {/* UPDATE ORDER STATUS */}

            <div className="mt-6 rounded-xl border border-amber-100 bg-amber-50/50 p-4">
              <h4 className="font-bold text-slate-800">
                Update order status
              </h4>

              <p className="mt-1 text-xs text-slate-500">
                Select a new status and save the change to the database.
              </p>

              <div className="mt-3 flex flex-col gap-3 sm:flex-row">
                <select
                  value={newStatus}
                  onChange={(event) => setNewStatus(event.target.value)}
                  disabled={statusUpdating}
                  className="min-w-0 flex-1 rounded-xl border border-slate-200 bg-white px-3 py-3 text-sm outline-none focus:border-amber-400 disabled:opacity-60"
                >
                  <option value="PLACED">Placed</option>
                  <option value="PREPARING">Preparing</option>
                  <option value="READY">Ready</option>
                  <option value="COMPLETED">Completed</option>
                  <option value="CANCELLED">Cancelled</option>
                </select>

                <button
                  onClick={() => onStatusChange(newStatus)}
                  disabled={
                    statusUpdating ||
                    newStatus === order.status
                  }
                  className="flex items-center justify-center gap-2 rounded-xl bg-[#171c2e] px-5 py-3 text-sm font-semibold text-white hover:bg-slate-700 disabled:cursor-not-allowed disabled:opacity-50"
                >
                  {statusUpdating ? (
                    <>
                      <RefreshCw size={15} className="animate-spin" />
                      Updating...
                    </>
                  ) : (
                    "Save status"
                  )}
                </button>
              </div>

              {statusUpdateError && (
                <p className="mt-3 text-sm text-rose-600">
                  {statusUpdateError}
                </p>
              )}

              {statusUpdateMessage && (
                <p className="mt-3 text-sm font-medium text-emerald-700">
                  {statusUpdateMessage}
                </p>
              )}
            </div>
          </>
        ) : null}

        <button
          onClick={onClose}
          className="mt-6 w-full rounded-xl bg-[#171c2e] px-4 py-3 text-sm font-semibold text-white hover:bg-slate-700"
        >
          Close
        </button>
      </div>
    </div>
  );
}

// ==========================================
// MAIN DASHBOARD COMPONENT
// ==========================================

function Dashboard({ active, setActive }) {
  const [period, setPeriod] = useState("week");
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");

  // Revenue analytics
  const [revenueData, setRevenueData] = useState([]);
  const [revenueLoading, setRevenueLoading] = useState(true);
  const [revenueError, setRevenueError] = useState("");

  // Dashboard statistics
  const [stats, setStats] = useState(null);
  const [statsLoading, setStatsLoading] = useState(true);
  const [statsError, setStatsError] = useState("");
  const [statsRefreshKey, setStatsRefreshKey] = useState(0);

  // Complete order list
  const [orders, setOrders] = useState([]);
  const [ordersLoading, setOrdersLoading] = useState(true);
  const [ordersError, setOrdersError] = useState("");
  const [ordersRefreshKey, setOrdersRefreshKey] = useState(0);

  // Server-side pagination
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalOrders, setTotalOrders] = useState(0);
  const pageLimit = 10;

  // Independent recent orders for Overview
  const [recentOrders, setRecentOrders] = useState([]);
  const [recentOrdersLoading, setRecentOrdersLoading] = useState(true);
  const [recentOrdersError, setRecentOrdersError] = useState("");

  // Selected order details
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [detailsLoading, setDetailsLoading] = useState(false);
  const [detailsError, setDetailsError] = useState("");

  // Status update
  const [statusUpdating, setStatusUpdating] = useState(false);
  const [statusUpdateError, setStatusUpdateError] = useState("");
  const [statusUpdateMessage, setStatusUpdateMessage] = useState("");

  // ==========================================
  // FETCH DASHBOARD STATISTICS
  // ==========================================

  useEffect(() => {
    let cancelled = false;

    async function fetchDashboardStats() {
      try {
        setStatsLoading(true);
        setStatsError("");

        const response = await fetch(
          `${API_BASE_URL}/dashboard/stats`
        );

        const data = await response.json();

        if (!response.ok || !data.success) {
          throw new Error(
            data.message || "Failed to fetch dashboard statistics"
          );
        }

        if (!cancelled) {
          setStats(data);
        }
      } catch (error) {
        if (!cancelled) {
          setStatsError(error.message);
        }
      } finally {
        if (!cancelled) {
          setStatsLoading(false);
        }
      }
    }

    fetchDashboardStats();

    return () => {
      cancelled = true;
    };
  }, [statsRefreshKey]);

  // ==========================================
  // FETCH REVENUE ANALYTICS
  // ==========================================

  useEffect(() => {
    let cancelled = false;

    async function fetchRevenue() {
      try {
        setRevenueLoading(true);
        setRevenueError("");

        const response = await fetch(
          `${API_BASE_URL}/dashboard/revenue?period=${period}`
        );

        const result = await response.json();

        if (!response.ok || !result.success) {
          throw new Error(
            result.message || "Failed to fetch revenue analytics"
          );
        }

        if (!cancelled) {
          setRevenueData(
            generateRevenueChartData(
              period,
              result.data || []
            )
          );
        }
      } catch (error) {
        if (!cancelled) {
          setRevenueError(error.message);
          setRevenueData([]);
        }
      } finally {
        if (!cancelled) {
          setRevenueLoading(false);
        }
      }
    }

    fetchRevenue();

    return () => {
      cancelled = true;
    };
  }, [period]);

  // ==========================================
  // FETCH COMPLETE ORDER LIST
  // Server-side search, filtering, pagination
  // ==========================================

  useEffect(() => {
    let cancelled = false;

    async function fetchOrders() {
      try {
        setOrdersLoading(true);
        setOrdersError("");

        const query = new URLSearchParams({
          page: String(currentPage),
          limit: String(pageLimit),
          search: search.trim(),
          status: statusFilter,
        });

        const response = await fetch(
          `${API_BASE_URL}/orders?${query.toString()}`
        );

        const data = await response.json();

        if (!response.ok || !data.success) {
          throw new Error(
            data.message || "Failed to fetch orders"
          );
        }

        if (!cancelled) {
          const fetchedOrders = Array.isArray(data.orders)
            ? data.orders
            : [];

          setOrders(fetchedOrders);
          setTotalOrders(
            Number(data.pagination?.total ?? data.count ?? fetchedOrders.length)
          );
          setTotalPages(
            Math.max(1, Number(data.pagination?.totalPages || 1))
          );
        }
      } catch (error) {
        if (!cancelled) {
          setOrdersError(error.message);
          setOrders([]);
          setTotalOrders(0);
          setTotalPages(1);
        }
      } finally {
        if (!cancelled) {
          setOrdersLoading(false);
        }
      }
    }

    fetchOrders();

    return () => {
      cancelled = true;
    };
  }, [
    currentPage,
    pageLimit,
    search,
    statusFilter,
    ordersRefreshKey,
  ]);

  // ==========================================
  // FETCH RECENT ORDERS FOR OVERVIEW
  // ==========================================

  useEffect(() => {
    let cancelled = false;

    async function fetchRecentOrders() {
      try {
        setRecentOrdersLoading(true);
        setRecentOrdersError("");

        const response = await fetch(
          `${API_BASE_URL}/dashboard/recent-orders`
        );

        const data = await response.json();

        if (!response.ok || !data.success) {
          throw new Error(
            data.message || "Failed to fetch recent orders"
          );
        }

        if (!cancelled) {
          const fetchedOrders = Array.isArray(data.orders)
            ? data.orders
            : Array.isArray(data.data)
              ? data.data
              : [];

          setRecentOrders(fetchedOrders);
        }
      } catch (error) {
        if (!cancelled) {
          setRecentOrdersError(error.message);
          setRecentOrders([]);
        }
      } finally {
        if (!cancelled) {
          setRecentOrdersLoading(false);
        }
      }
    }

    fetchRecentOrders();

    return () => {
      cancelled = true;
    };
  }, [ordersRefreshKey]);

  // ==========================================
  // ORDER SUMMARY COUNTS
  // Status counts reflect the currently loaded
  // page; total is the full matching result count.
  // ==========================================

  const orderCounts = useMemo(
    () => ({
      total: totalOrders,

      placed: orders.filter(
        (order) => order.status?.toUpperCase() === "PLACED"
      ).length,

      preparing: orders.filter(
        (order) => order.status?.toUpperCase() === "PREPARING"
      ).length,

      completed: orders.filter(
        (order) => order.status?.toUpperCase() === "COMPLETED"
      ).length,
    }),
    [orders, totalOrders]
  );

  // ==========================================
  // VIEW COMPLETE ORDER DETAILS
  // ==========================================

  async function handleViewOrder(orderId) {
    setSelectedOrder(null);
    setDetailsLoading(true);
    setDetailsError("");
    setStatusUpdateError("");
    setStatusUpdateMessage("");

    try {
      const response = await fetch(
        `${API_BASE_URL}/orders/${orderId}`
      );

      const data = await response.json();

      if (!response.ok || !data.success) {
        throw new Error(
          data.message || "Failed to fetch order details"
        );
      }

      setSelectedOrder(data.order || data);
    } catch (error) {
      setDetailsError(error.message);
    } finally {
      setDetailsLoading(false);
    }
  }

  // ==========================================
  // UPDATE ORDER STATUS
  // ==========================================

  async function handleStatusUpdate(newStatus) {
    if (!selectedOrder || statusUpdating) return;

    if (newStatus === selectedOrder.status) return;

    setStatusUpdating(true);
    setStatusUpdateError("");
    setStatusUpdateMessage("");

    try {
      const response = await fetch(
        `${API_BASE_URL}/orders/${selectedOrder.orderId}/status`,
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            status: newStatus,
          }),
        }
      );

      const data = await response.json();

      if (!response.ok || !data.success) {
        throw new Error(
          data.message || "Failed to update order status"
        );
      }

      const updatedStatus = data.currentStatus || newStatus;

      setSelectedOrder((previous) => ({
        ...previous,
        status: updatedStatus,
      }));

      setStatusUpdateMessage(
        `Order status successfully updated to ${updatedStatus}.`
      );

      // Refresh complete orders, recent orders and statistics.
      setOrdersRefreshKey((previous) => previous + 1);
      setStatsRefreshKey((previous) => previous + 1);
    } catch (error) {
      setStatusUpdateError(error.message);
    } finally {
      setStatusUpdating(false);
    }
  }

  // ==========================================
  // ORDERS PAGE
  // ==========================================

  if (active === "Orders") {
    return (
      <>
        <div className="mb-7 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
          <div>
            <p className="text-sm text-slate-500">
              Restaurant operations
            </p>

            <h2 className="mt-1 text-2xl font-bold text-slate-800">
              Orders Management
            </h2>

            <p className="mt-1 text-sm text-slate-500">
              View, search, filter and manage restaurant orders.
            </p>
          </div>

          <button
            onClick={() => {
              setOrdersRefreshKey((previous) => previous + 1);
              setStatsRefreshKey((previous) => previous + 1);
            }}
            disabled={ordersLoading}
            className="flex items-center justify-center gap-2 rounded-xl bg-[#171c2e] px-5 py-3 text-sm font-semibold text-white shadow-sm hover:bg-slate-700 disabled:cursor-not-allowed disabled:opacity-60"
          >
            <RefreshCw
              size={16}
              className={ordersLoading ? "animate-spin" : ""}
            />
            Refresh Orders
          </button>
        </div>

        {/* ORDER SUMMARY */}

        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
          <OrderSummaryCard
            title="Matching Orders"
            count={ordersLoading ? "..." : orderCounts.total}
            icon={ShoppingBag}
          />

          <OrderSummaryCard
            title="Placed (This Page)"
            count={ordersLoading ? "..." : orderCounts.placed}
            icon={Clock}
          />

          <OrderSummaryCard
            title="Preparing (This Page)"
            count={ordersLoading ? "..." : orderCounts.preparing}
            icon={Utensils}
          />

          <OrderSummaryCard
            title="Completed (This Page)"
            count={ordersLoading ? "..." : orderCounts.completed}
            icon={CheckCircle2}
          />
        </div>

        {/* ORDERS TABLE */}

        <div className="mt-6 overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-sm">
          <div className="flex flex-col justify-between gap-4 border-b border-slate-100 p-5 lg:flex-row lg:items-center">
            <div>
              <h3 className="font-bold text-slate-800">
                Restaurant Orders
              </h3>

              <p className="mt-1 text-xs text-slate-400">
                Complete order history from the live database
              </p>
            </div>

            <div className="flex flex-col gap-3 sm:flex-row">
              <div className="relative">
                <Search
                  size={16}
                  className="absolute top-1/2 left-3 -translate-y-1/2 text-slate-400"
                />

                <input
                  value={search}
                  onChange={(event) => {
                    setSearch(event.target.value);
                    setCurrentPage(1);
                  }}
                  placeholder="Search ID or customer..."
                  className="w-full rounded-xl border border-slate-200 py-2.5 pr-4 pl-9 text-sm outline-none focus:border-amber-400 sm:w-60"
                />
              </div>

              <div className="relative">
                <Filter
                  size={15}
                  className="absolute top-1/2 left-3 -translate-y-1/2 text-slate-400"
                />

                <select
                  value={statusFilter}
                  onChange={(event) => {
                    setStatusFilter(event.target.value);
                    setCurrentPage(1);
                  }}
                  className="w-full appearance-none rounded-xl border border-slate-200 bg-white py-2.5 pr-8 pl-9 text-sm text-slate-600 outline-none focus:border-amber-400 sm:w-44"
                >
                  <option value="ALL">All statuses</option>
                  <option value="PLACED">Placed</option>
                  <option value="PREPARING">Preparing</option>
                  <option value="READY">Ready</option>
                  <option value="COMPLETED">Completed</option>
                  <option value="CANCELLED">Cancelled</option>
                </select>
              </div>
            </div>
          </div>

          {ordersError && (
            <div className="m-5 rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm text-rose-700">
              Unable to load orders: {ordersError}
            </div>
          )}

          <div className="overflow-x-auto">
            <table className="w-full min-w-[850px] text-left text-sm">
              <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-400">
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
                    Amount
                  </th>

                  <th className="px-5 py-4 font-semibold">
                    Status
                  </th>

                  <th className="px-5 py-4 font-semibold">
                    Date / Time
                  </th>

                  <th className="px-5 py-4 text-center font-semibold">
                    Action
                  </th>
                </tr>
              </thead>

              <tbody className="divide-y divide-slate-100">
                {ordersLoading ? (
                  <tr>
                    <td
                      colSpan="7"
                      className="p-10 text-center text-slate-400"
                    >
                      <RefreshCw
                        size={20}
                        className="mx-auto mb-2 animate-spin"
                      />
                      Loading orders from database...
                    </td>
                  </tr>
                ) : ordersError ? (
                  <tr>
                    <td
                      colSpan="7"
                      className="p-10 text-center text-slate-400"
                    >
                      Orders could not be loaded. Please try refreshing.
                    </td>
                  </tr>
                ) : orders.length > 0 ? (
                  orders.map((order) => (
                    <tr
                      key={order.orderId || order.id}
                      className="transition hover:bg-slate-50/70"
                    >
                      <td className="px-5 py-4 font-semibold text-slate-700">
                        {order.id || order.orderId}
                      </td>

                      <td className="px-5 py-4 text-slate-600">
                        {order.customer || "N/A"}
                      </td>

                      <td className="max-w-xs px-5 py-4 text-slate-600">
                        {order.item || "N/A"}
                      </td>

                      <td className="px-5 py-4 font-semibold text-slate-800">
                        {formatCurrency(order.amount)}
                      </td>

                      <td className="px-5 py-4">
                        <StatusBadge status={order.status} />
                      </td>

                      <td className="px-5 py-4 text-slate-500">
                        {formatOrderTime(order.time)}
                      </td>

                      <td className="px-5 py-4 text-center">
                        <button
                          onClick={() =>
                            handleViewOrder(order.orderId)
                          }
                          className="inline-flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-xs font-semibold text-slate-600 transition hover:border-amber-400 hover:bg-amber-50 hover:text-amber-700"
                        >
                          <Eye size={15} />
                          View
                        </button>
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td
                      colSpan="7"
                      className="p-10 text-center text-slate-400"
                    >
                      No orders match your search or selected status.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* PAGINATION */}

          <div className="flex flex-col justify-between gap-4 border-t border-slate-100 px-5 py-4 sm:flex-row sm:items-center">
            <div className="text-xs text-slate-400">
              {ordersLoading
                ? "Fetching orders..."
                : `Showing ${
                    totalOrders === 0
                      ? 0
                      : (currentPage - 1) * pageLimit + 1
                  }–${Math.min(
                    currentPage * pageLimit,
                    totalOrders
                  )} of ${totalOrders} matching orders`}
            </div>

            <div className="flex items-center justify-between gap-3">
              <span className="text-xs text-slate-500">
                Page {currentPage} of {totalPages}
              </span>

              <div className="flex gap-2">
                <button
                  onClick={() =>
                    setCurrentPage((page) => Math.max(1, page - 1))
                  }
                  disabled={currentPage <= 1 || ordersLoading}
                  className="rounded-lg border border-slate-200 p-2 text-slate-600 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
                  aria-label="Previous page"
                >
                  <ChevronLeft size={17} />
                </button>

                <button
                  onClick={() =>
                    setCurrentPage((page) =>
                      Math.min(totalPages, page + 1)
                    )
                  }
                  disabled={
                    currentPage >= totalPages || ordersLoading
                  }
                  className="rounded-lg border border-slate-200 p-2 text-slate-600 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
                  aria-label="Next page"
                >
                  <ChevronRight size={17} />
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* API INFORMATION */}

        <div className="mt-5 rounded-xl border border-blue-100 bg-blue-50 p-4">
          <div className="flex items-start gap-3">
            <Receipt
              size={19}
              className="mt-0.5 shrink-0 text-blue-600"
            />

            <div>
              <p className="text-sm font-semibold text-blue-900">
                Order management API
              </p>

              <p className="mt-1 text-xs leading-5 text-blue-800">
                Orders are retrieved using server-side search,
                status filtering and pagination. Open an order
                to view its complete details, payment information
                and update its status.
              </p>
            </div>
          </div>
        </div>

        {/* ORDER DETAILS MODAL */}

        <OrderDetailsModal
          order={selectedOrder}
          loading={detailsLoading}
          error={detailsError}
          onClose={() => {
            setSelectedOrder(null);
            setDetailsError("");
            setStatusUpdateError("");
            setStatusUpdateMessage("");
          }}
          onStatusChange={handleStatusUpdate}
          statusUpdating={statusUpdating}
          statusUpdateError={statusUpdateError}
          statusUpdateMessage={statusUpdateMessage}
        />
      </>
    );
  }

  // ==========================================
  // OTHER NAVIGATION PLACEHOLDERS
  // ==========================================

  if (active !== "Overview") {
    return (
      <div className="rounded-2xl border border-slate-100 bg-white p-10 text-center shadow-sm">
        <div className="mx-auto mb-4 flex h-14 w-14 items-center justify-center rounded-2xl bg-amber-50 text-amber-600">
          <Utensils size={26} />
        </div>

        <h2 className="text-xl font-bold text-slate-800">
          {active}
        </h2>

        <p className="mt-2 text-sm text-slate-500">
          This section will be implemented and connected to the
          database in the next development steps.
        </p>
      </div>
    );
  }

  // ==========================================
  // OVERVIEW DASHBOARD
  // ==========================================

  return (
    <>
      <div className="mb-7 flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
        <div>
          <p className="text-sm text-slate-500">
            {new Date().toLocaleDateString("en-IN", {
              weekday: "long",
              year: "numeric",
              month: "long",
              day: "numeric",
              timeZone: "Asia/Kolkata",
            })}
          </p>

          <h2 className="mt-1 text-2xl font-bold text-slate-800">
            Dashboard Overview
          </h2>

          <p className="mt-1 text-sm text-slate-500">
            Here's what's happening at your restaurant today.
          </p>
        </div>

        <button
          onClick={() => window.print()}
          className="flex items-center justify-center gap-2 rounded-xl bg-[#171c2e] px-5 py-3 text-sm font-semibold text-white shadow-sm hover:bg-slate-700"
        >
          <ArrowUpRight size={17} />
          Generate Report
        </button>
      </div>

      {/* LIVE DATABASE STATISTICS */}

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard
          title="Total Revenue"
          value={
            statsLoading
              ? "Loading..."
              : statsError
                ? "Unavailable"
                : formatCurrency(stats?.totalRevenue)
          }
          icon={CreditCard}
        />

        <StatCard
          title="Total Orders"
          value={
            statsLoading
              ? "Loading..."
              : statsError
                ? "Unavailable"
                : Number(stats?.totalOrders || 0).toLocaleString("en-IN")
          }
          icon={ShoppingBag}
        />

        <StatCard
          title="Customers"
          value={
            statsLoading
              ? "Loading..."
              : statsError
                ? "Unavailable"
                : Number(stats?.totalCustomers || 0).toLocaleString("en-IN")
          }
          icon={Users}
        />

        <StatCard
          title="Pending Orders"
          value={
            statsLoading
              ? "Loading..."
              : statsError
                ? "Unavailable"
                : Number(stats?.pendingOrders || 0).toLocaleString("en-IN")
          }
          icon={Clock}
        />
      </div>

      {statsError && (
        <div className="mt-4 rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm text-rose-700">
          Unable to load live dashboard statistics: {statsError}
        </div>
      )}

      {/* REVENUE ANALYTICS */}

      <div className="mt-6 grid gap-5 xl:grid-cols-3">
        <div className="rounded-2xl border border-slate-100 bg-white p-5 shadow-sm xl:col-span-2">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <div>
              <h3 className="font-bold text-slate-800">
                Revenue Analytics
              </h3>

              <p className="mt-1 text-xs text-slate-400">
                Revenue performance · Live MySQL data
              </p>
            </div>

            <select
              value={period}
              onChange={(event) => setPeriod(event.target.value)}
              className="rounded-lg border border-slate-200 bg-white px-3 py-2 text-xs text-slate-600 outline-none"
            >
              <option value="week">This week</option>
              <option value="month">This month</option>
              <option value="year">This year</option>
            </select>
          </div>

          {revenueError && (
            <div className="mt-4 rounded-xl border border-rose-200 bg-rose-50 p-3 text-sm text-rose-700">
              Unable to load revenue analytics: {revenueError}
            </div>
          )}

          <div className="mt-6 h-64 w-full">
            {revenueLoading ? (
              <div className="flex h-full items-center justify-center text-sm text-slate-400">
                Loading revenue analytics...
              </div>
            ) : revenueError ? (
              <div className="flex h-full items-center justify-center text-sm text-slate-400">
                Revenue data is unavailable.
              </div>
            ) : (
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={revenueData}>
                  <defs>
                    <linearGradient
                      id="revenueFill"
                      x1="0"
                      y1="0"
                      x2="0"
                      y2="1"
                    >
                      <stop
                        offset="0%"
                        stopColor="#e9a93b"
                        stopOpacity={0.25}
                      />

                      <stop
                        offset="95%"
                        stopColor="#e9a93b"
                        stopOpacity={0}
                      />
                    </linearGradient>
                  </defs>

                  <CartesianGrid
                    stroke="#edf0f5"
                    vertical={false}
                  />

                  <XAxis
                    dataKey="day"
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "#94a3b8", fontSize: 12 }}
                    dy={10}
                  />

                  <YAxis
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: "#94a3b8", fontSize: 11 }}
                    tickFormatter={(value) =>
                      value >= 1000
                        ? `₹${(value / 1000).toFixed(1)}k`
                        : `₹${value}`
                    }
                  />

                  <Tooltip
                    formatter={(value) => [
                      formatCurrency(value),
                      "Revenue",
                    ]}
                  />

                  <Area
                    type="monotone"
                    dataKey="revenue"
                    stroke="#d99a2b"
                    strokeWidth={3}
                    fill="url(#revenueFill)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            )}
          </div>
        </div>

        {/* ORDER SUMMARY */}

        <div className="rounded-2xl border border-slate-100 bg-white p-5 shadow-sm">
          <h3 className="font-bold text-slate-800">
            Order Summary
          </h3>

          <p className="mt-1 text-xs text-slate-400">
            Illustrative distribution · Not connected yet
          </p>

          <div className="mt-7 space-y-6">
            {[
              ["Completed", 68, "bg-emerald-500"],
              ["Preparing", 20, "bg-amber-400"],
              ["Ready", 8, "bg-blue-500"],
              ["Cancelled", 4, "bg-rose-400"],
            ].map(([name, value, color]) => (
              <div key={name}>
                <div className="mb-2 flex justify-between text-sm">
                  <span className="text-slate-600">{name}</span>

                  <span className="font-semibold text-slate-800">
                    {value}%
                  </span>
                </div>

                <div className="h-2 overflow-hidden rounded-full bg-slate-100">
                  <div
                    className={`h-full rounded-full ${color}`}
                    style={{ width: `${value}%` }}
                  />
                </div>
              </div>
            ))}
          </div>

          <div className="mt-8 rounded-xl bg-amber-50 p-4">
            <div className="flex items-center gap-2 text-amber-700">
              <TrendingUp size={18} />

              <span className="text-sm font-semibold">
                Service performance
              </span>
            </div>

            <p className="mt-2 text-xs leading-5 text-amber-800">
              Monitor order progress and ensure pending orders
              are processed efficiently.
            </p>
          </div>
        </div>
      </div>

      {/* RECENT ORDERS */}

      <div className="mt-6 overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-sm">
        <div className="flex flex-col justify-between gap-3 border-b border-slate-100 p-5 sm:flex-row sm:items-center">
          <div>
            <h3 className="font-bold text-slate-800">
              Recent Orders
            </h3>

            <p className="mt-1 text-xs text-slate-400">
              Latest restaurant transactions · Live database data
            </p>
          </div>

          <button
            onClick={() => setActive("Orders")}
            className="text-sm font-semibold text-amber-600 hover:text-amber-700"
          >
            View all orders →
          </button>
        </div>

        {recentOrdersError && (
          <div className="m-5 rounded-xl border border-rose-200 bg-rose-50 p-4 text-sm text-rose-700">
            Unable to load recent orders: {recentOrdersError}
          </div>
        )}

        <div className="overflow-x-auto">
          <table className="w-full min-w-[750px] text-left text-sm">
            <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-400">
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
                  Amount
                </th>

                <th className="px-5 py-4 font-semibold">
                  Status
                </th>

                <th className="px-5 py-4 font-semibold">
                  Date / Time
                </th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-100">
              {recentOrdersLoading ? (
                <tr>
                  <td
                    colSpan="6"
                    className="p-8 text-center text-slate-400"
                  >
                    Loading recent orders...
                  </td>
                </tr>
              ) : recentOrdersError ? (
                <tr>
                  <td
                    colSpan="6"
                    className="p-8 text-center text-slate-400"
                  >
                    Recent orders could not be loaded.
                  </td>
                </tr>
              ) : recentOrders.length > 0 ? (
                recentOrders.slice(0, 5).map((order) => (
                  <tr
                    key={order.orderId || order.id}
                    className="hover:bg-slate-50/70"
                  >
                    <td className="px-5 py-4 font-semibold text-slate-700">
                      {order.id || order.orderId}
                    </td>

                    <td className="px-5 py-4 text-slate-600">
                      {order.customer || "N/A"}
                    </td>

                    <td className="max-w-xs px-5 py-4 text-slate-600">
                      {order.item || "N/A"}
                    </td>

                    <td className="px-5 py-4 font-semibold text-slate-800">
                      {formatCurrency(order.amount)}
                    </td>

                    <td className="px-5 py-4">
                      <StatusBadge status={order.status} />
                    </td>

                    <td className="px-5 py-4 text-slate-400">
                      {formatOrderTime(order.time)}
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td
                    colSpan="6"
                    className="p-8 text-center text-slate-400"
                  >
                    No recent orders found in the database.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        <div className="border-t border-slate-100 px-5 py-4 text-xs text-slate-400">
          {recentOrdersLoading
            ? "Fetching recent orders..."
            : `Showing ${Math.min(recentOrders.length, 5)} recent orders`}
        </div>
      </div>
    </>
  );
}

// ==========================================
// ROOT APPLICATION
// ==========================================

export default function App() {
  const [active, setActive] = useState("Overview");
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className="min-h-screen bg-[#f6f7fb]">
      <Sidebar
        active={active}
        setActive={setActive}
        open={sidebarOpen}
        setOpen={setSidebarOpen}
      />

      <main className="min-h-screen lg:pl-64">
        {/* TOP HEADER */}

        <header className="sticky top-0 z-20 flex h-20 items-center justify-between border-b border-slate-100 bg-white/90 px-5 backdrop-blur-xl sm:px-8">
          <div className="flex items-center gap-3">
            <button
              className="rounded-lg p-2 text-slate-600 hover:bg-slate-100 lg:hidden"
              onClick={() => setSidebarOpen(true)}
              aria-label="Open sidebar"
            >
              <Menu size={22} />
            </button>

            <div>
              <p className="text-xs text-slate-400">
                DineFusion / {active}
              </p>

              <p className="text-sm font-semibold text-slate-700">
                Restaurant Management
              </p>
            </div>
          </div>

          <div className="flex items-center gap-3 sm:gap-5">
            <button
              className="relative rounded-xl p-2.5 text-slate-500 hover:bg-slate-100"
              aria-label="Notifications"
            >
              <Bell size={19} />

              <span className="absolute top-2 right-2 h-2 w-2 rounded-full bg-rose-500 ring-2 ring-white" />
            </button>

            <div className="hidden items-center gap-2 sm:flex">
              <div className="flex h-9 w-9 items-center justify-center rounded-full bg-[#171c2e] text-sm font-bold text-amber-300">
                A
              </div>

              <div>
                <p className="text-xs font-semibold text-slate-700">
                  Admin User
                </p>

                <p className="text-[10px] text-slate-400">
                  Administrator
                </p>
              </div>

              <ChevronDown
                size={15}
                className="text-slate-400"
              />
            </div>
          </div>
        </header>

        {/* MAIN CONTENT */}

        <div className="mx-auto max-w-[1600px] p-5 sm:p-8">
          <Dashboard
            active={active}
            setActive={setActive}
          />

          <footer className="mt-8 pb-3 text-center text-xs text-slate-400">
            © 2026 DineFusion · Restaurant Management System
          </footer>
        </div>
      </main>
    </div>
  );
}
