-- DineFusion
-- Phase 5.1: SQL JOINS

USE dinefusion_db;

-- Query 1: INNER JOIN
-- Display orders with customer names

SELECT
    O.order_id,
    C.name AS customer_name,
    O.order_type,
    O.order_status,
    O.total_amount
FROM RESTAURANT_ORDER O
INNER JOIN CUSTOMER C
    ON O.customer_id = C.customer_id;
    
-- Query 2: LEFT JOIN

SELECT
    C.customer_id,
    C.name,
    O.order_id,
    O.total_amount
FROM CUSTOMER C
LEFT JOIN RESTAURANT_ORDER O
    ON C.customer_id = O.customer_id;
    
-- Query 3: RIGHT JOIN

SELECT
    C.name AS customer_name,
    O.order_id,
    O.order_type,
    O.total_amount
FROM CUSTOMER C
RIGHT JOIN RESTAURANT_ORDER O
    ON C.customer_id = O.customer_id;
    
-- Query 4: Multiple-table JOIN

SELECT
    O.order_id,
    C.name AS customer_name,
    MI.item_name,
    OI.quantity,
    OI.subtotal
FROM RESTAURANT_ORDER O
INNER JOIN CUSTOMER C
    ON O.customer_id = C.customer_id
INNER JOIN ORDER_ITEM OI
    ON O.order_id = OI.order_id
INNER JOIN MENU_ITEM MI
    ON OI.item_id = MI.item_id;