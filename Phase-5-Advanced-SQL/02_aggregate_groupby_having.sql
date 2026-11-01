
-- =====================================================
-- DineFusion
-- PHASE 5.2: AGGREGATE FUNCTIONS, GROUP BY AND HAVING
-- =====================================================

USE dinefusion_db;


-- -----------------------------------------------------
-- QUERY 1: COUNT()
-- Requirement: Find the total number of customers
-- -----------------------------------------------------

SELECT
    COUNT(*) AS total_customers
FROM CUSTOMER;


-- -----------------------------------------------------
-- QUERY 2: SUM()
-- Requirement: Calculate total restaurant revenue
-- -----------------------------------------------------

SELECT
    SUM(total_amount) AS total_revenue
FROM RESTAURANT_ORDER
WHERE order_status <> 'CANCELLED';


-- -----------------------------------------------------
-- QUERY 3: AVG()
-- Requirement: Calculate average menu item price
-- -----------------------------------------------------

SELECT
    AVG(price) AS average_menu_price
FROM MENU_ITEM;


-- -----------------------------------------------------
-- QUERY 4: MAX() AND MIN()
-- Requirement: Find the highest and lowest menu prices
-- -----------------------------------------------------

SELECT
    MAX(price) AS highest_price,
    MIN(price) AS lowest_price
FROM MENU_ITEM;


-- -----------------------------------------------------
-- QUERY 5: GROUP BY
-- Requirement: Count orders for each order type
-- -----------------------------------------------------

SELECT
    order_type,
    COUNT(*) AS total_orders
FROM RESTAURANT_ORDER
GROUP BY order_type;


-- -----------------------------------------------------
-- QUERY 6: GROUP BY WITH SUM()
-- Requirement: Calculate total revenue for each branch
-- -----------------------------------------------------

SELECT
    B.branch_id,
    B.branch_name,
    SUM(O.total_amount) AS total_revenue
FROM BRANCH B
INNER JOIN RESTAURANT_ORDER O
    ON B.branch_id = O.branch_id
WHERE O.order_status <> 'CANCELLED'
GROUP BY B.branch_id, B.branch_name;


-- -----------------------------------------------------
-- QUERY 7: GROUP BY WITH AVG()
-- Requirement: Calculate average menu price
-- for each menu category
-- -----------------------------------------------------

SELECT
    MC.category_name,
    AVG(MI.price) AS average_price
FROM MENU_CATEGORY MC
INNER JOIN MENU_ITEM MI
    ON MC.category_id = MI.category_id
GROUP BY MC.category_id, MC.category_name;


-- -----------------------------------------------------
-- QUERY 8: GROUP BY WITH COUNT()
-- Requirement: Count menu items in each category
-- -----------------------------------------------------

SELECT
    MC.category_name,
    COUNT(MI.item_id) AS total_menu_items
FROM MENU_CATEGORY MC
LEFT JOIN MENU_ITEM MI
    ON MC.category_id = MI.category_id
GROUP BY MC.category_id, MC.category_name;


-- -----------------------------------------------------
-- QUERY 9: HAVING
-- Requirement: Find branches with revenue above 400
-- -----------------------------------------------------

SELECT
    B.branch_name,
    SUM(O.total_amount) AS total_revenue
FROM BRANCH B
INNER JOIN RESTAURANT_ORDER O
    ON B.branch_id = O.branch_id
WHERE O.order_status <> 'CANCELLED'
GROUP BY B.branch_id, B.branch_name
HAVING SUM(O.total_amount) > 400;


-- -----------------------------------------------------
-- QUERY 10: GROUP BY WITH HAVING
-- Requirement: Find menu categories having
-- more than one menu item
-- -----------------------------------------------------

SELECT
    MC.category_name,
    COUNT(MI.item_id) AS total_menu_items
FROM MENU_CATEGORY MC
INNER JOIN MENU_ITEM MI
    ON MC.category_id = MI.category_id
GROUP BY MC.category_id, MC.category_name
HAVING COUNT(MI.item_id) > 1;


-- -----------------------------------------------------
-- QUERY 11: WHERE AND HAVING TOGETHER
-- Requirement: Find order types with more than
-- one order, excluding cancelled orders
-- -----------------------------------------------------

SELECT
    order_type,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue
FROM RESTAURANT_ORDER
WHERE order_status <> 'CANCELLED'
GROUP BY order_type
HAVING COUNT(*) > 1;


-- -----------------------------------------------------
-- QUERY 12: MULTIPLE AGGREGATE FUNCTIONS
-- Requirement: Display order count, average order
-- amount, minimum amount and maximum amount
-- for each branch
-- -----------------------------------------------------

SELECT
    B.branch_name,
    COUNT(O.order_id) AS total_orders,
    AVG(O.total_amount) AS average_order_amount,
    MIN(O.total_amount) AS minimum_order_amount,
    MAX(O.total_amount) AS maximum_order_amount,
    SUM(O.total_amount) AS total_revenue
FROM BRANCH B
LEFT JOIN RESTAURANT_ORDER O
    ON B.branch_id = O.branch_id
GROUP BY B.branch_id, B.branch_name;


-- -----------------------------------------------------
-- QUERY 13: COUNT DISTINCT
-- Requirement: Count the different customers
-- who have placed orders
-- -----------------------------------------------------

SELECT
    COUNT(DISTINCT customer_id) AS unique_customers
FROM RESTAURANT_ORDER
WHERE customer_id IS NOT NULL;


-- -----------------------------------------------------
-- QUERY 14: GROUP BY WITH ORDER BY
-- Requirement: Display menu categories from
-- highest average price to lowest average price
-- -----------------------------------------------------

SELECT
    MC.category_name,
    AVG(MI.price) AS average_price
FROM MENU_CATEGORY MC
INNER JOIN MENU_ITEM MI
    ON MC.category_id = MI.category_id
GROUP BY MC.category_id, MC.category_name
ORDER BY average_price DESC;


-- -----------------------------------------------------
-- END OF PHASE 5.2
-- -----------------------------------------------------
