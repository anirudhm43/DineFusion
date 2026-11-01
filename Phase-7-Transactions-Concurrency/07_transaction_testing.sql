/*
DINEFUSION PHASE 7 - FILE 07
TRANSACTION TESTING AND VERIFICATION

Run after the relevant setup files.
Run this complete file in ONE connection.
*/

USE dinefusion_db;

-- 1. Storage engine for project tables.
SELECT TABLE_NAME, ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'dinefusion_db'
ORDER BY TABLE_NAME;

-- 2. Project base tables that are not InnoDB.
-- Empty result means all base tables use InnoDB.
SELECT TABLE_NAME, ENGINE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'dinefusion_db'
  AND TABLE_TYPE = 'BASE TABLE'
  AND ENGINE <> 'InnoDB';

-- 3. Current transaction isolation level.
SELECT @@transaction_isolation AS transaction_isolation;

-- 4. Autocommit setting.
SELECT @@autocommit AS autocommit_enabled;

-- 5. File 01 demonstration records.
SELECT * FROM phase7_transaction_demo ORDER BY demo_id;

-- 6. File 04 concurrency demonstration records.
SELECT * FROM phase7_concurrency_demo ORDER BY demo_id;

-- 7. Active InnoDB transactions; may return no rows.
SELECT * FROM information_schema.INNODB_TRX;

-- 8. Original DineFusion inventory is not modified by these demos.
SELECT * FROM INVENTORY ORDER BY inventory_id;

-- 9. Inspect order and payment records.
SELECT
    o.order_id,
    o.order_status,
    o.total_amount,
    p.payment_status,
    p.amount AS payment_amount
FROM RESTAURANT_ORDER AS o
LEFT JOIN PAYMENT AS p ON p.order_id = o.order_id
ORDER BY o.order_id;
