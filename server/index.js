
require("dotenv").config();

const express = require("express");
const cors = require("cors");
const mysql = require("mysql2/promise");

const app = express();

// ==========================================
// MIDDLEWARE
// ==========================================


const allowedOrigins = new Set(
  [
    "http://localhost:5173", // Existing Vite frontend
    "http://localhost:3000", // New Next.js frontend
    ...(process.env.CLIENT_ORIGINS || "").split(","),
    process.env.CLIENT_ORIGIN || ""
  ]
    .map((origin) => origin.trim())
    .filter(Boolean)
);

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests without an Origin header (e.g. PowerShell)
      if (!origin || allowedOrigins.has(origin)) {
        return callback(null, true);
      }

      return callback(
        new Error(`CORS blocked this origin: ${origin}`)
      );
    }
  })
);

app.use(express.json({
  limit: "10kb"
}));
app.use(express.json({
  limit: "10kb"
}));
// ==========================================
// MYSQL CONNECTION POOL
// ==========================================

const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: Number(process.env.DB_PORT || 3306),
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// ==========================================
// 1. HEALTH CHECK API
// ==========================================

app.get("/api/health", async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT DATABASE() AS database_name"
    );

    res.json({
      success: true,
      message: "DineFusion API is running",
      database: rows[0].database_name
    });

  } catch (error) {
    console.error("Health check error:", error.message);

    res.status(500).json({
      success: false,
      message: "Database connection failed"
    });
  }
});

// ==========================================
// 2. DASHBOARD STATISTICS API
// ==========================================

app.get("/api/dashboard/stats", async (req, res) => {
  try {
    const [[orders]] = await db.query(`
      SELECT
        COUNT(*) AS totalOrders,
        SUM(
          CASE
            WHEN order_status IN ('PLACED', 'PREPARING', 'READY')
            THEN 1
            ELSE 0
          END
        ) AS pendingOrders
      FROM RESTAURANT_ORDER
    `);

    const [[customers]] = await db.query(`
      SELECT COUNT(*) AS totalCustomers
      FROM CUSTOMER
    `);

    const [[revenue]] = await db.query(`
      SELECT COALESCE(SUM(amount), 0) AS totalRevenue
      FROM PAYMENT
      WHERE payment_status = 'SUCCESS'
    `);

    res.json({
      success: true,
      totalOrders: Number(orders.totalOrders),
      pendingOrders: Number(orders.pendingOrders || 0),
      totalCustomers: Number(customers.totalCustomers),
      totalRevenue: Number(revenue.totalRevenue)
    });

  } catch (error) {
    console.error("Dashboard stats error:", error.message);

    res.status(500).json({
      success: false,
      message: "Could not fetch dashboard statistics"
    });
  }
});

// ==========================================
// 3. RECENT ORDERS API
// ==========================================

app.get("/api/dashboard/recent-orders", async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
        ro.order_id,
        ro.order_date,
        ro.order_status,
        ro.total_amount,
        COALESCE(c.name, 'Walk-in Customer') AS customer_name,

        COALESCE(
          GROUP_CONCAT(
            CONCAT(
              mi.item_name,
              CASE
                WHEN oi.quantity > 1
                THEN CONCAT(' x ', oi.quantity)
                ELSE ''
              END
            )
            ORDER BY oi.order_item_id
            SEPARATOR ', '
          ),
          'No items'
        ) AS items

      FROM RESTAURANT_ORDER ro

      LEFT JOIN CUSTOMER c
        ON ro.customer_id = c.customer_id

      LEFT JOIN ORDER_ITEM oi
        ON ro.order_id = oi.order_id

      LEFT JOIN MENU_ITEM mi
        ON oi.item_id = mi.item_id

      GROUP BY
        ro.order_id,
        ro.order_date,
        ro.order_status,
        ro.total_amount,
        c.name

      ORDER BY
        ro.order_date DESC,
        ro.order_id DESC

      LIMIT 10
    `);

    const recentOrders = rows.map((order) => ({
      id: `#DF-${String(order.order_id).padStart(4, "0")}`,
      customer: order.customer_name,
      item: order.items,
      amount: Number(order.total_amount),
      status: order.order_status,
      time: order.order_date
    }));

    res.json({
      success: true,
      count: recentOrders.length,
      orders: recentOrders
    });

  } catch (error) {
    console.error("Recent orders error:", error.message);

    res.status(500).json({
      success: false,
      message: "Could not fetch recent orders"
    });
  }
});

// ==========================================
// 4. COMPLETE ORDER LIST API
// Supports search, status filter, pagination
// ==========================================

app.get("/api/orders", async (req, res) => {
  try {
    const page = Number(req.query.page || 1);
    const limit = Number(req.query.limit || 10);

    if (
      !Number.isInteger(page) ||
      !Number.isInteger(limit) ||
      page < 1 ||
      limit < 1 ||
      limit > 100
    ) {
      return res.status(400).json({
        success: false,
        message: "Invalid pagination. Page must be >= 1 and limit must be between 1 and 100."
      });
    }

    const offset = (page - 1) * limit;

    const search = String(req.query.search || "").trim();
    const status = String(req.query.status || "").trim().toUpperCase();

    const conditions = [];
    const params = [];

    if (status && status !== "ALL") {
      conditions.push("ro.order_status = ?");
      params.push(status);
    }

    if (search) {
      const normalizedId = search
        .replace(/^#?DF-/i, "")
        .replace(/^0+/, "");

      if (/^\d+$/.test(normalizedId)) {
        conditions.push(`
          (
            ro.order_id = ?
            OR c.name LIKE ?
          )
        `);

        params.push(Number(normalizedId), `%${search}%`);
      } else {
        conditions.push(`
          (
            CAST(ro.order_id AS CHAR) LIKE ?
            OR c.name LIKE ?
          )
        `);

        params.push(`%${search}%`, `%${search}%`);
      }
    }

    const whereClause = conditions.length
      ? `WHERE ${conditions.join(" AND ")}`
      : "";

    const [countRows] = await db.query(
      `
        SELECT COUNT(*) AS total
        FROM RESTAURANT_ORDER ro
        LEFT JOIN CUSTOMER c
          ON ro.customer_id = c.customer_id
        ${whereClause}
      `,
      params
    );

    const total = Number(countRows[0].total);

    const [rows] = await db.query(
      `
        SELECT
          ro.order_id,
          ro.branch_id,
          ro.customer_id,
          ro.order_type,
          ro.order_status,
          ro.order_date,
          ro.subtotal,
          ro.tax,
          ro.discount,
          ro.total_amount,

          COALESCE(c.name, 'Walk-in Customer') AS customer_name,

          COALESCE(items.item_summary, 'No items') AS items,

          p.payment_status,
          p.payment_method

        FROM RESTAURANT_ORDER ro

        LEFT JOIN CUSTOMER c
          ON ro.customer_id = c.customer_id

        LEFT JOIN (
          SELECT
            oi.order_id,
            GROUP_CONCAT(
              CONCAT(
                mi.item_name,
                ' x ',
                oi.quantity
              )
              ORDER BY oi.order_item_id
              SEPARATOR ', '
            ) AS item_summary

          FROM ORDER_ITEM oi

          LEFT JOIN MENU_ITEM mi
            ON oi.item_id = mi.item_id

          GROUP BY oi.order_id
        ) items
          ON ro.order_id = items.order_id

        LEFT JOIN PAYMENT p
          ON ro.order_id = p.order_id

        ${whereClause}

        ORDER BY
          ro.order_date DESC,
          ro.order_id DESC

        LIMIT ? OFFSET ?
      `,
      [...params, limit, offset]
    );

    const orders = rows.map((order) => ({
      orderId: order.order_id,
      id: `#DF-${String(order.order_id).padStart(4, "0")}`,
      branchId: order.branch_id,
      customerId: order.customer_id,
      customer: order.customer_name,
      orderType: order.order_type,
      item: order.items,
      subtotal: Number(order.subtotal),
      tax: Number(order.tax),
      discount: Number(order.discount),
      amount: Number(order.total_amount),
      status: order.order_status,
      paymentStatus: order.payment_status,
      paymentMethod: order.payment_method,
      time: order.order_date
    }));

    res.json({
      success: true,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      },
      count: orders.length,
      orders
    });

  } catch (error) {
    console.error("Order listing error:", error.message);

    res.status(500).json({
      success: false,
      message: "Could not fetch orders"
    });
  }
});

// ==========================================
// 5. INDIVIDUAL ORDER DETAILS API
// ==========================================

app.get("/api/orders/:id", async (req, res) => {
  try {
    const orderId = Number(req.params.id);

    if (!Number.isInteger(orderId) || orderId <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid order ID"
      });
    }

    // Fetch main order and customer details
    const [orderRows] = await db.query(
      `
        SELECT
          ro.*,
          COALESCE(c.name, 'Walk-in Customer') AS customer_name
        FROM RESTAURANT_ORDER ro
        LEFT JOIN CUSTOMER c
          ON ro.customer_id = c.customer_id
        WHERE ro.order_id = ?
      `,
      [orderId]
    );

    if (orderRows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Order not found"
      });
    }

    const order = orderRows[0];

    // Fetch individual order items
    const [itemRows] = await db.query(
      `
        SELECT
          oi.order_item_id,
          oi.item_id,
          mi.item_name,
          oi.quantity,
          oi.unit_price,
          oi.subtotal
        FROM ORDER_ITEM oi
        LEFT JOIN MENU_ITEM mi
          ON oi.item_id = mi.item_id
        WHERE oi.order_id = ?
        ORDER BY oi.order_item_id
      `,
      [orderId]
    );

    // Fetch payment details
    const [paymentRows] = await db.query(
      `
        SELECT
          payment_id,
          payment_method,
          payment_status,
          amount,
          payment_date,
          transaction_reference
        FROM PAYMENT
        WHERE order_id = ?
      `,
      [orderId]
    );

    res.json({
      success: true,
      order: {
        orderId: order.order_id,
        id: `#DF-${String(order.order_id).padStart(4, "0")}`,
        branchId: order.branch_id,
        customerId: order.customer_id,
        customer: order.customer_name,
        sessionId: order.session_id,
        orderType: order.order_type,
        status: order.order_status,
        orderDate: order.order_date,

        subtotal: Number(order.subtotal),
        tax: Number(order.tax),
        discount: Number(order.discount),
        totalAmount: Number(order.total_amount),

        items: itemRows.map((item) => ({
          orderItemId: item.order_item_id,
          itemId: item.item_id,
          name: item.item_name || "Unknown Item",
          quantity: item.quantity,
          unitPrice: Number(item.unit_price),
          subtotal: Number(item.subtotal)
        })),

        payment: paymentRows.length
          ? {
              paymentId: paymentRows[0].payment_id,
              method: paymentRows[0].payment_method,
              status: paymentRows[0].payment_status,
              amount: Number(paymentRows[0].amount),
              paymentDate: paymentRows[0].payment_date,
              transactionReference:
                paymentRows[0].transaction_reference
            }
          : null
      }
    });

  } catch (error) {
    console.error("Order details error:", error.message);

    res.status(500).json({
      success: false,
      message: "Could not fetch order details"
    });
  }
});

// ==========================================
// 6. ORDER STATUS UPDATE API
// Uses a transaction and row-level locking
// ==========================================

app.patch("/api/orders/:id/status", async (req, res) => {
  let connection;
  let transactionStarted = false;

  try {
    const orderId = Number(req.params.id);

    const allowedStatuses = [
      "PLACED",
      "PREPARING",
      "READY",
      "COMPLETED",
      "CANCELLED"
    ];

    const newStatus = String(req.body.status || "")
      .trim()
      .toUpperCase();

    // Validate order ID
    if (!Number.isInteger(orderId) || orderId <= 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid order ID"
      });
    }

    // Validate requested status
    if (!allowedStatuses.includes(newStatus)) {
      return res.status(400).json({
        success: false,
        message:
          "Invalid status. Allowed values: " +
          allowedStatuses.join(", ")
      });
    }

    connection = await db.getConnection();

    await connection.beginTransaction();
    transactionStarted = true;

    // Lock the order row to prevent concurrent updates
    const [rows] = await connection.query(
      `
        SELECT order_id, order_status
        FROM RESTAURANT_ORDER
        WHERE order_id = ?
        FOR UPDATE
      `,
      [orderId]
    );

    if (rows.length === 0) {
      await connection.rollback();
      transactionStarted = false;

      return res.status(404).json({
        success: false,
        message: "Order not found"
      });
    }

    const oldStatus = rows[0].order_status;

    // Avoid unnecessary database updates
    if (oldStatus === newStatus) {
      await connection.commit();
      transactionStarted = false;

      return res.json({
        success: true,
        message: "Order already has this status",
        orderId,
        previousStatus: oldStatus,
        currentStatus: newStatus
      });
    }

    // Update order status
    await connection.query(
      `
        UPDATE RESTAURANT_ORDER
        SET order_status = ?
        WHERE order_id = ?
      `,
      [newStatus, orderId]
    );

    await connection.commit();
    transactionStarted = false;

    res.json({
      success: true,
      message: "Order status updated successfully",
      orderId,
      previousStatus: oldStatus,
      currentStatus: newStatus
    });

  } catch (error) {
    if (connection && transactionStarted) {
      await connection.rollback();
    }

    console.error("Order status update error:", error.message);

    res.status(500).json({
      success: false,
      message: "Could not update order status"
    });

  } finally {
    if (connection) {
      connection.release();
    }
  }
});


// ==========================================
// 6. REVENUE ANALYTICS API
// ==========================================

app.get("/api/dashboard/revenue", async (req, res) => {
  try {
    const period = req.query.period || "week";

    let dateFormat;
    let dateCondition;

    if (period === "week") {
      dateFormat = "%Y-%m-%d";

      dateCondition = `
        ro.order_date >= DATE_SUB(
          CURDATE(),
          INTERVAL WEEKDAY(CURDATE()) DAY
        )
        AND ro.order_date < DATE_ADD(
          DATE_SUB(
            CURDATE(),
            INTERVAL WEEKDAY(CURDATE()) DAY
          ),
          INTERVAL 7 DAY
        )
      `;
    } else if (period === "month") {
      dateFormat = "%Y-%m-%d";

      dateCondition = `
        YEAR(ro.order_date) = YEAR(CURDATE())
        AND MONTH(ro.order_date) = MONTH(CURDATE())
      `;
    } else if (period === "year") {
      dateFormat = "%Y-%m";

      dateCondition = `
        YEAR(ro.order_date) = YEAR(CURDATE())
      `;
    } else {
      return res.status(400).json({
        success: false,
        message: "Invalid period. Use week, month or year."
      });
    }

    const [rows] = await db.query(`
      SELECT
        DATE_FORMAT(ro.order_date, '${dateFormat}') AS date_key,
        SUM(ro.total_amount) AS revenue

      FROM RESTAURANT_ORDER ro

      WHERE
        ${dateCondition}
        AND ro.order_status != 'CANCELLED'

      GROUP BY date_key
      ORDER BY date_key ASC
    `);

    const revenue = rows.map((row) => ({
      date: row.date_key,
      revenue: Number(row.revenue)
    }));

    res.json({
      success: true,
      period,
      data: revenue
    });

  } catch (error) {
    console.error("Revenue analytics error:", error.message);

    res.status(500).json({
      success: false,
      message: "Could not fetch revenue analytics"
    });
  }
});

// ==========================================
// 7. START SERVER
// ==========================================

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`DineFusion API running on port ${PORT}`);
});
