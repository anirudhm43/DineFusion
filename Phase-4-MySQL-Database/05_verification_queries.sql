-- =====================================================
-- DineFusion
-- PHASE 4.5: DATABASE VERIFICATION
-- =====================================================

USE dinefusion_db;

-- -----------------------------------------------------
-- 1. SHOW ALL TABLES
-- -----------------------------------------------------
SHOW TABLES;


-- -----------------------------------------------------
-- 2. CHECK TABLE STRUCTURE
-- -----------------------------------------------------
DESCRIBE RESTAURANT;
DESCRIBE BRANCH;
DESCRIBE CUSTOMER;
DESCRIBE EMPLOYEE;
DESCRIBE DINING_TABLE;
DESCRIBE RESERVATION;
DESCRIBE DINING_SESSION;
DESCRIBE RESTAURANT_ORDER;
DESCRIBE ORDER_ITEM;
DESCRIBE PAYMENT;
DESCRIBE CUISINE;
DESCRIBE MENU_CATEGORY;
DESCRIBE MENU_ITEM;
DESCRIBE MENU_ITEM_CUISINE;
DESCRIBE INGREDIENT;
DESCRIBE MENU_ITEM_INGREDIENT;
DESCRIBE SUPPLIER;
DESCRIBE SUPPLIER_INGREDIENT;
DESCRIBE INVENTORY;
DESCRIBE REVIEW;


-- -----------------------------------------------------
-- 3. COUNT RECORDS IN EACH TABLE
-- -----------------------------------------------------
SELECT 'RESTAURANT' AS table_name, COUNT(*) AS total_records FROM RESTAURANT
UNION ALL
SELECT 'BRANCH', COUNT(*) FROM BRANCH
UNION ALL
SELECT 'CUSTOMER', COUNT(*) FROM CUSTOMER
UNION ALL
SELECT 'EMPLOYEE', COUNT(*) FROM EMPLOYEE
UNION ALL
SELECT 'DINING_TABLE', COUNT(*) FROM DINING_TABLE
UNION ALL
SELECT 'RESERVATION', COUNT(*) FROM RESERVATION
UNION ALL
SELECT 'DINING_SESSION', COUNT(*) FROM DINING_SESSION
UNION ALL
SELECT 'RESTAURANT_ORDER', COUNT(*) FROM RESTAURANT_ORDER
UNION ALL
SELECT 'ORDER_ITEM', COUNT(*) FROM ORDER_ITEM
UNION ALL
SELECT 'PAYMENT', COUNT(*) FROM PAYMENT
UNION ALL
SELECT 'CUISINE', COUNT(*) FROM CUISINE
UNION ALL
SELECT 'MENU_CATEGORY', COUNT(*) FROM MENU_CATEGORY
UNION ALL
SELECT 'MENU_ITEM', COUNT(*) FROM MENU_ITEM
UNION ALL
SELECT 'MENU_ITEM_CUISINE', COUNT(*) FROM MENU_ITEM_CUISINE
UNION ALL
SELECT 'INGREDIENT', COUNT(*) FROM INGREDIENT
UNION ALL
SELECT 'MENU_ITEM_INGREDIENT', COUNT(*) FROM MENU_ITEM_INGREDIENT
UNION ALL
SELECT 'SUPPLIER', COUNT(*) FROM SUPPLIER
UNION ALL
SELECT 'SUPPLIER_INGREDIENT', COUNT(*) FROM SUPPLIER_INGREDIENT
UNION ALL
SELECT 'INVENTORY', COUNT(*) FROM INVENTORY
UNION ALL
SELECT 'REVIEW', COUNT(*) FROM REVIEW;


-- -----------------------------------------------------
-- 4. TEST JOIN:
-- Display branches and their restaurant
-- -----------------------------------------------------
SELECT
    B.branch_id,
    B.branch_name,
    B.city,
    R.restaurant_name
FROM BRANCH B
INNER JOIN RESTAURANT R
    ON B.restaurant_id = R.restaurant_id;


-- -----------------------------------------------------
-- 5. TEST JOIN:
-- Display orders and customer names
-- -----------------------------------------------------
SELECT
    O.order_id,
    C.name AS customer_name,
    O.order_type,
    O.order_status,
    O.total_amount
FROM RESTAURANT_ORDER O
LEFT JOIN CUSTOMER C
    ON O.customer_id = C.customer_id;


-- -----------------------------------------------------
-- 6. TEST JOIN:
-- Display order items and menu item names
-- -----------------------------------------------------
SELECT
    OI.order_id,
    MI.item_name,
    OI.quantity,
    OI.unit_price,
    OI.subtotal
FROM ORDER_ITEM OI
INNER JOIN MENU_ITEM MI
    ON OI.item_id = MI.item_id;


-- -----------------------------------------------------
-- 7. TEST JOIN:
-- Display inventory with branch and ingredient
-- -----------------------------------------------------
SELECT
    B.branch_name,
    I.ingredient_name,
    INV.quantity_available,
    I.unit
FROM INVENTORY INV
INNER JOIN BRANCH B
    ON INV.branch_id = B.branch_id
INNER JOIN INGREDIENT I
    ON INV.ingredient_id = I.ingredient_id;


-- -----------------------------------------------------
-- 8. TEST AGGREGATE:
-- Total orders and revenue by branch
-- -----------------------------------------------------
SELECT
    B.branch_name,
    COUNT(O.order_id) AS total_orders,
    COALESCE(SUM(O.total_amount), 0) AS total_revenue
FROM BRANCH B
LEFT JOIN RESTAURANT_ORDER O
    ON B.branch_id = O.branch_id
GROUP BY B.branch_id, B.branch_name;


-- -----------------------------------------------------
-- 9. TEST FOREIGN KEY RELATIONSHIPS:
-- Show menu items and their cuisines
-- -----------------------------------------------------
SELECT
    MI.item_name,
    C.cuisine_name
FROM MENU_ITEM MI
INNER JOIN MENU_ITEM_CUISINE MIC
    ON MI.item_id = MIC.item_id
INNER JOIN CUISINE C
    ON MIC.cuisine_id = C.cuisine_id;


-- -----------------------------------------------------
-- 10. CHECK DATABASE NAME
-- -----------------------------------------------------
SELECT DATABASE() AS current_database;

-- -----------------------------------------------------
-- END OF VERIFICATION
-- -----------------------------------------------------