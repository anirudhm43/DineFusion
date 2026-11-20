
"use client";

import { useCallback, useEffect, useState } from "react";
import {
  Search,
  RefreshCw,
  ChevronLeft,
  ChevronRight,
  Eye,
  X,
  ShoppingBag,
  IndianRupee,
  Clock3,
  CheckCircle2,
  AlertCircle,
  Loader2,
  Package,
} from "lucide-react";
import { apiGet, apiPatch } from "@/lib/api";

type OrderStatus =
  | "PLACED"
  | "PREPARING"
  | "READY"
  | "COMPLETED"
  | "CANCELLED";

type PaymentStatus = "SUCCESS" | "PENDING" | "FAILED" | string;

type Order = {
  orderId: number;
  id: string;
  branchId: number;
  customerId: number | null;
  customer: string;
  orderType: string;
  item: string;
  subtotal: number;
  tax: number;
  discount: number;
  amount: number;
  status: OrderStatus;
  paymentStatus: PaymentStatus;
  paymentMethod: string | null;
  time: string;
};

type OrdersResponse = {
  success: boolean;
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
  count: number;
  orders: Order[];
};

type OrderItem = {
  orderItemId: number;
  itemId: number;
  name: string;
  quantity: number;
  unitPrice: number;
  subtotal: number;
};

type OrderDetails = {
  orderId: number;
  id: string;
  branchId: number;
  customerId: number | null;
  customer: string;
  sessionId: number | null;
  orderType: string;
  status: OrderStatus;
  orderDate: string;
  subtotal: number;
  tax: number;
  discount: number;
  totalAmount: number;
  items: OrderItem[];
  payment: {
    paymentId: number;
    method: string;
    status: string;
    amount: number;
    paymentDate: string | null;
    transactionReference: string | null;
  } | null;
};

type OrderDetailsResponse = {
  success: boolean;
  order: OrderDetails;
};

type StatusUpdateResponse = {
  success: boolean;
  message: string;
  orderId: number;
  previousStatus: string;
  currentStatus: string;
};

const statuses: OrderStatus[] = [
  "PLACED",
  "PREPARING",
  "READY",
  "COMPLETED",
  "CANCELLED",
];

const currency = (value: number) =>
  new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 2,
  }).format(value);

const dateTime = (value: string) =>
  new Date(value).toLocaleString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });

function statusStyle(status: string) {
  switch (status) {
    case "COMPLETED":
      return "bg-emerald-50 text-emerald-700 ring-emerald-600/20";
    case "READY":
      return "bg-blue-50 text-blue-700 ring-blue-600/20";
    case "PREPARING":
      return "bg-amber-50 text-amber-700 ring-amber-600/20";
    case "PLACED":
      return "bg-violet-50 text-violet-700 ring-violet-600/20";
    case "CANCELLED":
      return "bg-rose-50 text-rose-700 ring-rose-600/20";
    default:
      return "bg-slate-100 text-slate-600 ring-slate-500/20";
  }
}

function paymentStyle(status: string) {
  if (status === "SUCCESS") {
    return "text-emerald-700 bg-emerald-50";
  }

  if (status === "PENDING") {
    return "text-amber-700 bg-amber-50";
  }

  return "text-rose-700 bg-rose-50";
}

export default function OrdersContent() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalOrders, setTotalOrders] = useState(0);

  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("ALL");

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [updatingId, setUpdatingId] = useState<number | null>(null);
  const [notice, setNotice] = useState("");

  const [selectedOrder, setSelectedOrder] = useState<OrderDetails | null>(
    null
  );
  const [detailsLoading, setDetailsLoading] = useState(false);
  const [detailsError, setDetailsError] = useState("");

  const loadOrders = useCallback(async () => {
    setLoading(true);
    setError("");

    try {
      const params = new URLSearchParams({
        page: String(page),
        limit: "10",
        search,
        status: statusFilter,
      });

      const response = await apiGet<OrdersResponse>(
        `/orders?${params.toString()}`
      );

      setOrders(response.orders);
      setTotalOrders(response.pagination.total);
      setTotalPages(Math.max(1, response.pagination.totalPages));
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "Unable to load orders."
      );
    } finally {
      setLoading(false);
    }
  }, [page, search, statusFilter]);

  useEffect(() => {
    void loadOrders();
  }, [loadOrders]);

  function handleSearch(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setPage(1);
    setSearch(searchInput.trim());
  }

  function handleStatusFilter(value: string) {
    setStatusFilter(value);
    setPage(1);
  }

  async function openOrderDetails(orderId: number) {
    setSelectedOrder(null);
    setDetailsError("");
    setDetailsLoading(true);

    try {
      const response = await apiGet<OrderDetailsResponse>(
        `/orders/${orderId}`
      );
      setSelectedOrder(response.order);
    } catch (err) {
      setDetailsError(
        err instanceof Error ? err.message : "Unable to load order details."
      );
    } finally {
      setDetailsLoading(false);
    }
  }

  async function updateOrderStatus(
    orderId: number,
    newStatus: OrderStatus
  ) {
    const existingOrder = orders.find(
      (order) => order.orderId === orderId
    );

    if (!existingOrder || existingOrder.status === newStatus) {
      return;
    }

    const confirmed = window.confirm(
      `Change order ${existingOrder.id} from ${existingOrder.status} to ${newStatus}?`
    );

    if (!confirmed) {
      return;
    }

    setUpdatingId(orderId);
    setNotice("");
    setError("");

    try {
      const response = await apiPatch<StatusUpdateResponse>(
        `/orders/${orderId}/status`,
        { status: newStatus }
      );

      if (!response.success) {
        throw new Error("The order status could not be updated.");
      }

      setNotice(`${existingOrder.id}: ${response.message}`);

      if (selectedOrder?.orderId === orderId) {
        setSelectedOrder({
          ...selectedOrder,
          status: newStatus,
        });
      }

      await loadOrders();
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "Unable to update order."
      );
    } finally {
      setUpdatingId(null);
    }
  }

  const completedCount = orders.filter(
    (order) => order.status === "COMPLETED"
  ).length;

  const pendingCount = orders.filter(
    (order) =>
      order.status === "PLACED" || order.status === "PREPARING"
  ).length;

  return (
    <div className="space-y-6">
      {/* Page heading */}
      <div className="flex flex-col justify-between gap-4 sm:flex-row sm:items-center">
        <div>
          <p className="text-sm font-medium text-emerald-700">
            OPERATIONS / ORDERS
          </p>
          <h1 className="mt-1 text-2xl font-bold tracking-tight text-slate-900">
            Orders
          </h1>
          <p className="mt-1 text-sm text-slate-500">
            Manage restaurant orders, track progress and update order status.
          </p>
        </div>

        <button
          onClick={() => void loadOrders()}
          disabled={loading}
          className="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50 disabled:opacity-50"
        >
          <RefreshCw size={16} className={loading ? "animate-spin" : ""} />
          Refresh
        </button>
      </div>

      {/* Summary cards */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-slate-500">
              Total Orders
            </p>
            <div className="rounded-xl bg-blue-50 p-2.5 text-blue-600">
              <ShoppingBag size={19} />
            </div>
          </div>
          <p className="mt-3 text-2xl font-bold text-slate-900">
            {totalOrders}
          </p>
          <p className="mt-1 text-xs text-slate-400">
            Matching your current filters
          </p>
        </div>

        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-slate-500">
              Active on This Page
            </p>
            <div className="rounded-xl bg-amber-50 p-2.5 text-amber-600">
              <Clock3 size={19} />
            </div>
          </div>
          <p className="mt-3 text-2xl font-bold text-slate-900">
            {pendingCount}
          </p>
          <p className="mt-1 text-xs text-slate-400">
            Placed or preparing
          </p>
        </div>

        <div className="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-slate-500">
              Completed on This Page
            </p>
            <div className="rounded-xl bg-emerald-50 p-2.5 text-emerald-600">
              <CheckCircle2 size={19} />
            </div>
          </div>
          <p className="mt-3 text-2xl font-bold text-slate-900">
            {completedCount}
          </p>
          <p className="mt-1 text-xs text-slate-400">
            Successfully completed
          </p>
        </div>
      </div>

      {/* Search and filter */}
      <div className="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
        <div className="flex flex-col gap-3 md:flex-row">
          <form
            onSubmit={handleSearch}
            className="flex flex-1 items-center gap-2 rounded-xl border border-slate-200 px-3 focus-within:border-emerald-500 focus-within:ring-2 focus-within:ring-emerald-100"
          >
            <Search size={18} className="shrink-0 text-slate-400" />
            <input
              value={searchInput}
              onChange={(event) => setSearchInput(event.target.value)}
              placeholder="Search by order ID or customer name..."
              className="h-11 w-full bg-transparent text-sm text-slate-700 outline-none placeholder:text-slate-400"
            />
            <button
              type="submit"
              className="rounded-lg bg-emerald-600 px-4 py-2 text-xs font-semibold text-white transition hover:bg-emerald-700"
            >
              Search
            </button>
          </form>

          <select
            value={statusFilter}
            onChange={(event) => handleStatusFilter(event.target.value)}
            className="h-11 rounded-xl border border-slate-200 bg-white px-4 text-sm text-slate-700 outline-none focus:border-emerald-500"
          >
            <option value="ALL">All statuses</option>
            {statuses.map((status) => (
              <option key={status} value={status}>
                {status}
              </option>
            ))}
          </select>
        </div>

        {(search || statusFilter !== "ALL") && (
          <div className="mt-3 flex flex-wrap items-center gap-2 text-xs text-slate-500">
            <span>Active filters:</span>
            {search && (
              <span className="rounded-full bg-slate-100 px-3 py-1">
                Search: {search}
              </span>
            )}
            {statusFilter !== "ALL" && (
              <span className="rounded-full bg-slate-100 px-3 py-1">
                Status: {statusFilter}
              </span>
            )}
            <button
              onClick={() => {
                setSearchInput("");
                setSearch("");
                setStatusFilter("ALL");
                setPage(1);
              }}
              className="font-semibold text-emerald-700 hover:text-emerald-800"
            >
              Clear filters
            </button>
          </div>
        )}
      </div>

      {/* Feedback */}
      {notice && (
        <div className="flex items-center gap-2 rounded-xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
          <CheckCircle2 size={17} />
          {notice}
          <button
            onClick={() => setNotice("")}
            className="ml-auto"
            aria-label="Dismiss notification"
          >
            <X size={16} />
          </button>
        </div>
      )}

      {error && (
        <div className="flex items-center gap-2 rounded-xl border border-rose-200 bg-rose-50 px-4 py-3 text-sm text-rose-700">
          <AlertCircle size={17} />
          {error}
        </div>
      )}

      {/* Orders table */}
      <div className="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
        <div className="flex flex-col justify-between gap-2 border-b border-slate-100 px-5 py-4 sm:flex-row sm:items-center">
          <div>
            <h2 className="font-semibold text-slate-900">All Orders</h2>
            <p className="mt-1 text-xs text-slate-400">
              Order records from your restaurant database
            </p>
          </div>
          <span className="text-xs font-medium text-slate-500">
            {totalOrders} records
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full min-w-[1050px] text-left">
            <thead className="bg-slate-50 text-[11px] uppercase tracking-wider text-slate-500">
              <tr>
                <th className="px-5 py-4 font-semibold">Order</th>
                <th className="px-5 py-4 font-semibold">Customer</th>
                <th className="px-5 py-4 font-semibold">Items</th>
                <th className="px-5 py-4 font-semibold">Order Type</th>
                <th className="px-5 py-4 font-semibold">Amount</th>
                <th className="px-5 py-4 font-semibold">Payment</th>
                <th className="px-5 py-4 font-semibold">Status</th>
                <th className="px-5 py-4 text-right font-semibold">Actions</th>
              </tr>
            </thead>

            <tbody className="divide-y divide-slate-100">
              {loading ? (
                <tr>
                  <td colSpan={8} className="px-5 py-16 text-center">
                    <Loader2
                      className="mx-auto animate-spin text-emerald-600"
                      size={26}
                    />
                    <p className="mt-3 text-sm text-slate-500">
                      Loading orders...
                    </p>
                  </td>
                </tr>
              ) : orders.length === 0 ? (
                <tr>
                  <td colSpan={8} className="px-5 py-16 text-center">
                    <Package
                      className="mx-auto text-slate-300"
                      size={30}
                    />
                    <p className="mt-3 font-medium text-slate-700">
                      No orders found
                    </p>
                    <p className="mt-1 text-xs text-slate-400">
                      Try changing your search or status filter.
                    </p>
                  </td>
                </tr>
              ) : (
                orders.map((order) => (
                  <tr
                    key={order.orderId}
                    className="transition hover:bg-slate-50/70"
                  >
                    <td className="px-5 py-4">
                      <p className="text-sm font-bold text-slate-900">
                        {order.id}
                      </p>
                      <p className="mt-1 text-xs text-slate-400">
                        {dateTime(order.time)}
                      </p>
                    </td>

                    <td className="px-5 py-4">
                      <p className="text-sm font-semibold text-slate-800">
                        {order.customer}
                      </p>
                      <p className="mt-1 text-xs text-slate-400">
                        Customer #{order.customerId ?? "N/A"}
                      </p>
                    </td>

                    <td className="max-w-[230px] px-5 py-4">
                      <p className="truncate text-sm text-slate-600">
                        {order.item}
                      </p>
                    </td>

                    <td className="px-5 py-4">
                      <span className="rounded-lg bg-slate-100 px-2.5 py-1.5 text-xs font-medium text-slate-600">
                        {order.orderType.replace("_", " ")}
                      </span>
                    </td>

                    <td className="px-5 py-4">
                      <p className="text-sm font-bold text-slate-900">
                        {currency(order.amount)}
                      </p>
                    </td>

                    <td className="px-5 py-4">
                      <span
                        className={`rounded-full px-2.5 py-1.5 text-[11px] font-semibold ${paymentStyle(order.paymentStatus)}`}
                      >
                        {order.paymentStatus || "UNKNOWN"}
                      </span>
                      <p className="mt-1 text-[11px] text-slate-400">
                        {order.paymentMethod || "N/A"}
                      </p>
                    </td>

                    <td className="px-5 py-4">
                      <div className="flex flex-col items-start gap-2">
                        <span
                          className={`rounded-full px-2.5 py-1.5 text-[11px] font-semibold ring-1 ring-inset ${statusStyle(order.status)}`}
                        >
                          {order.status}
                        </span>

                        <select
                          aria-label={`Update status for ${order.id}`}
                          value={order.status}
                          disabled={updatingId === order.orderId}
                          onChange={(event) =>
                            void updateOrderStatus(
                              order.orderId,
                              event.target.value as OrderStatus
                            )
                          }
                          className="max-w-[130px] rounded-lg border border-slate-200 bg-white px-2 py-1.5 text-[11px] text-slate-600 outline-none focus:border-emerald-500 disabled:opacity-50"
                        >
                          {statuses.map((status) => (
                            <option key={status} value={status}>
                              {status}
                            </option>
                          ))}
                        </select>
                      </div>
                    </td>

                    <td className="px-5 py-4 text-right">
                      <button
                        onClick={() => void openOrderDetails(order.orderId)}
                        className="inline-flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-2 text-xs font-semibold text-slate-600 transition hover:border-emerald-200 hover:bg-emerald-50 hover:text-emerald-700"
                      >
                        <Eye size={14} />
                        View
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="flex flex-col justify-between gap-3 border-t border-slate-100 px-5 py-4 sm:flex-row sm:items-center">
          <p className="text-xs text-slate-500">
            {totalOrders === 0
              ? "No records"
              : `Showing ${(page - 1) * 10 + 1}–${Math.min(
                  page * 10,
                  totalOrders
                )} of ${totalOrders} orders`}
          </p>

          <div className="flex items-center gap-2">
            <button
              onClick={() => setPage((current) => Math.max(1, current - 1))}
              disabled={page <= 1 || loading}
              className="inline-flex items-center gap-1 rounded-lg border border-slate-200 px-3 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <ChevronLeft size={15} />
              Previous
            </button>

            <span className="px-2 text-xs font-medium text-slate-600">
              Page {page} of {totalPages}
            </span>

            <button
              onClick={() =>
                setPage((current) => Math.min(totalPages, current + 1))
              }
              disabled={page >= totalPages || loading}
              className="inline-flex items-center gap-1 rounded-lg border border-slate-200 px-3 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-40"
            >
              Next
              <ChevronRight size={15} />
            </button>
          </div>
        </div>
      </div>

      {/* Order details modal */}
      {(detailsLoading || detailsError || selectedOrder) && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/40 p-4 backdrop-blur-[2px]"
          onMouseDown={(event) => {
            if (event.target === event.currentTarget) {
              setSelectedOrder(null);
              setDetailsError("");
            }
          }}
        >
          <div className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-2xl bg-white shadow-2xl">
            <div className="sticky top-0 flex items-center justify-between border-b border-slate-100 bg-white px-6 py-4">
              <div>
                <h2 className="text-lg font-bold text-slate-900">
                  Order Details
                </h2>
                <p className="mt-1 text-xs text-slate-400">
                  Complete order and payment information
                </p>
              </div>
              <button
                onClick={() => {
                  setSelectedOrder(null);
                  setDetailsError("");
                }}
                className="rounded-lg p-2 text-slate-400 hover:bg-slate-100 hover:text-slate-700"
                aria-label="Close order details"
              >
                <X size={20} />
              </button>
            </div>

            {detailsLoading ? (
              <div className="p-16 text-center">
                <Loader2
                  className="mx-auto animate-spin text-emerald-600"
                  size={28}
                />
                <p className="mt-3 text-sm text-slate-500">
                  Loading order details...
                </p>
              </div>
            ) : detailsError ? (
              <div className="p-8 text-center text-sm text-rose-600">
                {detailsError}
              </div>
            ) : selectedOrder ? (
              <div className="space-y-6 p-6">
                <div className="flex flex-wrap items-start justify-between gap-3">
                  <div>
                    <p className="text-xs font-medium text-slate-400">
                      ORDER REFERENCE
                    </p>
                    <h3 className="mt-1 text-2xl font-bold text-slate-900">
                      {selectedOrder.id}
                    </h3>
                    <p className="mt-1 text-sm text-slate-500">
                      {dateTime(selectedOrder.orderDate)}
                    </p>
                  </div>

                  <span
                    className={`rounded-full px-3 py-1.5 text-xs font-semibold ring-1 ring-inset ${statusStyle(selectedOrder.status)}`}
                  >
                    {selectedOrder.status}
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="rounded-xl bg-slate-50 p-4">
                    <p className="text-xs text-slate-400">Customer</p>
                    <p className="mt-1 font-semibold text-slate-800">
                      {selectedOrder.customer}
                    </p>
                  </div>
                  <div className="rounded-xl bg-slate-50 p-4">
                    <p className="text-xs text-slate-400">Order Type</p>
                    <p className="mt-1 font-semibold text-slate-800">
                      {selectedOrder.orderType.replace("_", " ")}
                    </p>
                  </div>
                  <div className="rounded-xl bg-slate-50 p-4">
                    <p className="text-xs text-slate-400">Branch</p>
                    <p className="mt-1 font-semibold text-slate-800">
                      Branch #{selectedOrder.branchId}
                    </p>
                  </div>
                  <div className="rounded-xl bg-slate-50 p-4">
                    <p className="text-xs text-slate-400">Customer ID</p>
                    <p className="mt-1 font-semibold text-slate-800">
                      {selectedOrder.customerId ?? "N/A"}
                    </p>
                  </div>
                </div>

                <div>
                  <h4 className="font-semibold text-slate-900">
                    Ordered Items
                  </h4>
                  <div className="mt-3 overflow-hidden rounded-xl border border-slate-200">
                    <div className="grid grid-cols-[1fr_55px_90px_100px] gap-2 bg-slate-50 px-4 py-3 text-[10px] font-bold uppercase tracking-wider text-slate-500">
                      <span>Item</span>
                      <span className="text-center">Qty</span>
                      <span className="text-right">Price</span>
                      <span className="text-right">Subtotal</span>
                    </div>

                    {selectedOrder.items.map((item) => (
                      <div
                        key={item.orderItemId}
                        className="grid grid-cols-[1fr_55px_90px_100px] gap-2 border-t border-slate-100 px-4 py-3 text-xs"
                      >
                        <span className="font-medium text-slate-700">
                          {item.name}
                        </span>
                        <span className="text-center text-slate-500">
                          {item.quantity}
                        </span>
                        <span className="text-right text-slate-500">
                          {currency(item.unitPrice)}
                        </span>
                        <span className="text-right font-semibold text-slate-800">
                          {currency(item.subtotal)}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="rounded-xl border border-slate-200 p-4">
                  <h4 className="mb-3 font-semibold text-slate-900">
                    Bill Summary
                  </h4>
                  <div className="space-y-2 text-sm">
                    <div className="flex justify-between text-slate-500">
                      <span>Subtotal</span>
                      <span>{currency(selectedOrder.subtotal)}</span>
                    </div>
                    <div className="flex justify-between text-slate-500">
                      <span>Tax</span>
                      <span>{currency(selectedOrder.tax)}</span>
                    </div>
                    <div className="flex justify-between text-slate-500">
                      <span>Discount</span>
                      <span>-{currency(selectedOrder.discount)}</span>
                    </div>
                    <div className="flex justify-between border-t border-slate-100 pt-3 font-bold text-slate-900">
                      <span>Total Amount</span>
                      <span>{currency(selectedOrder.totalAmount)}</span>
                    </div>
                  </div>
                </div>

                <div className="rounded-xl border border-slate-200 p-4">
                  <h4 className="mb-3 font-semibold text-slate-900">
                    Payment Information
                  </h4>

                  {selectedOrder.payment ? (
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <p className="text-xs text-slate-400">Method</p>
                        <p className="mt-1 font-semibold text-slate-700">
                          {selectedOrder.payment.method}
                        </p>
                      </div>
                      <div>
                        <p className="text-xs text-slate-400">Payment Status</p>
                        <span
                          className={`mt-1 inline-block rounded-full px-2.5 py-1 text-xs font-semibold ${paymentStyle(selectedOrder.payment.status)}`}
                        >
                          {selectedOrder.payment.status}
                        </span>
                      </div>
                      <div>
                        <p className="text-xs text-slate-400">Paid Amount</p>
                        <p className="mt-1 font-semibold text-slate-700">
                          {currency(selectedOrder.payment.amount)}
                        </p>
                      </div>
                      <div>
                        <p className="text-xs text-slate-400">
                          Transaction Reference
                        </p>
                        <p className="mt-1 break-all font-medium text-slate-700">
                          {selectedOrder.payment.transactionReference || "N/A"}
                        </p>
                      </div>
                    </div>
                  ) : (
                    <p className="text-sm text-slate-500">
                      No payment record is available for this order.
                    </p>
                  )}
                </div>

                <div>
                  <label className="mb-2 block text-sm font-semibold text-slate-700">
                    Update Order Status
                  </label>
                  <select
                    value={selectedOrder.status}
                    disabled={updatingId === selectedOrder.orderId}
                    onChange={(event) =>
                      void updateOrderStatus(
                        selectedOrder.orderId,
                        event.target.value as OrderStatus
                      )
                    }
                    className="h-11 w-full rounded-xl border border-slate-200 bg-white px-3 text-sm outline-none focus:border-emerald-500 disabled:opacity-50"
                  >
                    {statuses.map((status) => (
                      <option key={status} value={status}>
                        {status}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            ) : null}
          </div>
        </div>
      )}
    </div>
  );
}
