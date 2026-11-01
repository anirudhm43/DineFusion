
-- =====================================================
-- DineFusion
-- PHASE 5.4: SQL SET OPERATIONS
-- =====================================================

USE dinefusion_db;


-- -----------------------------------------------------
-- QUERY 1: UNION
-- Requirement: Display all customer and employee names
-- without duplicate names
-- -----------------------------------------------------

SELECT name AS person_name
FROM CUSTOMER

UNION

SELECT name
FROM EMPLOYEE;


-- -----------------------------------------------------
-- QUERY 2: UNION ALL
-- Requirement: Display all customer and employee names
-- including duplicate names
-- -----------------------------------------------------

SELECT name AS person_name
FROM CUSTOMER

UNION ALL

SELECT name
FROM EMPLOYEE;


-- -----------------------------------------------------
-- QUERY 3: UNION WITH ORDER BY
-- Requirement: Combine customer and employee names
-- and sort alphabetically
-- -----------------------------------------------------

SELECT name AS person_name
FROM CUSTOMER

UNION

SELECT name
FROM EMPLOYEE

ORDER BY person_name ASC;


-- -----------------------------------------------------
-- QUERY 4: INTERSECT
-- Requirement: Find customers who have both
-- placed an order and written a review
-- MySQL 8.0.31+
-- -----------------------------------------------------

SELECT customer_id
FROM RESTAURANT_ORDER
WHERE customer_id IS NOT NULL

INTERSECT

SELECT customer_id
FROM REVIEW;


-- -----------------------------------------------------
-- QUERY 5: INTERSECT ALTERNATIVE
-- Requirement: Find customers who have both
-- placed an order and written a review
-- Compatible with older MySQL versions
-- -----------------------------------------------------

SELECT DISTINCT C.customer_id, C.name
FROM CUSTOMER C
WHERE C.customer_id IN (
    SELECT customer_id
    FROM RESTAURANT_ORDER
    WHERE customer_id IS NOT NULL
)
AND C.customer_id IN (
    SELECT customer_id
    FROM REVIEW
);


-- -----------------------------------------------------
-- QUERY 6: EXCEPT
-- Requirement: Find customers who have placed
-- orders but have not written reviews
-- MySQL 8.0.31+
-- -----------------------------------------------------

SELECT customer_id
FROM RESTAURANT_ORDER
WHERE customer_id IS NOT NULL

EXCEPT

SELECT customer_id
FROM REVIEW;


-- -----------------------------------------------------
-- QUERY 7: EXCEPT ALTERNATIVE
-- Requirement: Find customers who have placed
-- orders but have not written reviews
-- Compatible with older MySQL versions
-- -----------------------------------------------------

SELECT DISTINCT C.customer_id, C.name
FROM CUSTOMER C
WHERE EXISTS (
    SELECT 1
    FROM RESTAURANT_ORDER O
    WHERE O.customer_id = C.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM REVIEW R
    WHERE R.customer_id = C.customer_id
);


-- -----------------------------------------------------
-- QUERY 8: UNION BETWEEN DIFFERENT BUSINESS DATA
-- Requirement: Display all names of menu items
-- and ingredients in a single result
-- -----------------------------------------------------

SELECT item_name AS name, 'MENU ITEM' AS record_type
FROM MENU_ITEM

UNION ALL

SELECT ingredient_name, 'INGREDIENT'
FROM INGREDIENT;


-- -----------------------------------------------------
-- QUERY 9: UNION WITH AGGREGATE DATA
-- Requirement: Display customer and employee
-- record counts together
-- -----------------------------------------------------

SELECT
    'CUSTOMER' AS entity_type,
    COUNT(*) AS total_records
FROM CUSTOMER

UNION ALL

SELECT
    'EMPLOYEE',
    COUNT(*)
FROM EMPLOYEE;


-- -----------------------------------------------------
-- QUERY 10: MULTIPLE UNION ALL
-- Requirement: Display names of customers,
-- employees and suppliers together
-- -----------------------------------------------------

SELECT name AS person_or_company_name,
       'CUSTOMER' AS entity_type
FROM CUSTOMER

UNION ALL

SELECT name,
       'EMPLOYEE'
FROM EMPLOYEE

UNION ALL

SELECT supplier_name,
       'SUPPLIER'
FROM SUPPLIER;


-- -----------------------------------------------------
-- END OF PHASE 5.4
-- -----------------------------------------------------
