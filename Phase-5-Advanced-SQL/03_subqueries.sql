
-- =====================================================
-- DineFusion
-- PHASE 5.3: NESTED AND CORRELATED SUBQUERIES
-- =====================================================

USE dinefusion_db;


-- -----------------------------------------------------
-- QUERY 1: SIMPLE UNCORRELATED SUBQUERY
-- Requirement: Find menu items priced above
-- the average menu item price
-- -----------------------------------------------------

SELECT
    item_id,
    item_name,
    price
FROM MENU_ITEM
WHERE price > (
    SELECT AVG(price)
    FROM MENU_ITEM
);


-- -----------------------------------------------------
-- QUERY 2: UNCORRELATED SUBQUERY WITH MAX()
-- Requirement: Find the most expensive menu item
-- -----------------------------------------------------

SELECT
    item_name,
    price
FROM MENU_ITEM
WHERE price = (
    SELECT MAX(price)
    FROM MENU_ITEM
);


-- -----------------------------------------------------
-- QUERY 3: UNCORRELATED SUBQUERY WITH IN
-- Requirement: Find customers who have placed orders
-- -----------------------------------------------------

SELECT
    customer_id,
    name,
    email
FROM CUSTOMER
WHERE customer_id IN (
    SELECT customer_id
    FROM RESTAURANT_ORDER
    WHERE customer_id IS NOT NULL
);


-- -----------------------------------------------------
-- QUERY 4: UNCORRELATED SUBQUERY WITH NOT IN
-- Requirement: Find customers who have never
-- placed an order
-- -----------------------------------------------------

SELECT
    customer_id,
    name
FROM CUSTOMER
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM RESTAURANT_ORDER
    WHERE customer_id IS NOT NULL
);


-- -----------------------------------------------------
-- QUERY 5: SUBQUERY WITH EXISTS
-- Requirement: Find customers who have placed
-- at least one order
-- -----------------------------------------------------

SELECT
    C.customer_id,
    C.name
FROM CUSTOMER C
WHERE EXISTS (
    SELECT 1
    FROM RESTAURANT_ORDER O
    WHERE O.customer_id = C.customer_id
);


-- -----------------------------------------------------
-- QUERY 6: SUBQUERY WITH NOT EXISTS
-- Requirement: Find customers who have never
-- placed an order
-- -----------------------------------------------------

SELECT
    C.customer_id,
    C.name
FROM CUSTOMER C
WHERE NOT EXISTS (
    SELECT 1
    FROM RESTAURANT_ORDER O
    WHERE O.customer_id = C.customer_id
);


-- -----------------------------------------------------
-- QUERY 7: CORRELATED SUBQUERY
-- Requirement: Find menu items whose price is
-- greater than the average price of their category
-- -----------------------------------------------------

SELECT
    MI.item_id,
    MI.item_name,
    MI.price,
    MI.category_id
FROM MENU_ITEM MI
WHERE MI.price > (
    SELECT AVG(MI2.price)
    FROM MENU_ITEM MI2
    WHERE MI2.category_id = MI.category_id
);


-- -----------------------------------------------------
-- QUERY 8: CORRELATED SUBQUERY WITH COUNT()
-- Requirement: Find customers who have placed
-- more than one order
-- -----------------------------------------------------

SELECT
    C.customer_id,
    C.name
FROM CUSTOMER C
WHERE (
    SELECT COUNT(*)
    FROM RESTAURANT_ORDER O
    WHERE O.customer_id = C.customer_id
) > 1;


-- -----------------------------------------------------
-- QUERY 9: CORRELATED SUBQUERY WITH MAX()
-- Requirement: Find the most expensive menu item
-- in each category
-- -----------------------------------------------------

SELECT
    MI.item_id,
    MI.item_name,
    MI.price,
    MI.category_id
FROM MENU_ITEM MI
WHERE MI.price = (
    SELECT MAX(MI2.price)
    FROM MENU_ITEM MI2
    WHERE MI2.category_id = MI.category_id
);


-- -----------------------------------------------------
-- QUERY 10: CORRELATED SUBQUERY WITH EXISTS
-- Requirement: Find menu items that have
-- received at least one customer review
-- -----------------------------------------------------

SELECT
    MI.item_id,
    MI.item_name
FROM MENU_ITEM MI
WHERE EXISTS (
    SELECT 1
    FROM REVIEW R
    WHERE R.item_id = MI.item_id
);


-- -----------------------------------------------------
-- QUERY 11: NESTED SUBQUERY
-- Requirement: Find customers who ordered
-- a menu item belonging to the Indian cuisine
-- -----------------------------------------------------

SELECT
    C.customer_id,
    C.name
FROM CUSTOMER C
WHERE C.customer_id IN (
    SELECT O.customer_id
    FROM RESTAURANT_ORDER O
    WHERE O.order_id IN (
        SELECT OI.order_id
        FROM ORDER_ITEM OI
        WHERE OI.item_id IN (
            SELECT MIC.item_id
            FROM MENU_ITEM_CUISINE MIC
            INNER JOIN CUISINE CU
                ON MIC.cuisine_id = CU.cuisine_id
            WHERE CU.cuisine_name = 'Indian'
        )
    )
);


-- -----------------------------------------------------
-- QUERY 12: CORRELATED SUBQUERY WITH AVG()
-- Requirement: Find customers whose order total
-- is greater than their own average order amount
-- -----------------------------------------------------

SELECT
    O.order_id,
    O.customer_id,
    O.total_amount
FROM RESTAURANT_ORDER O
WHERE O.customer_id IS NOT NULL
AND O.total_amount > (
    SELECT AVG(O2.total_amount)
    FROM RESTAURANT_ORDER O2
    WHERE O2.customer_id = O.customer_id
);


-- -----------------------------------------------------
-- END OF PHASE 5.3
-- -----------------------------------------------------
