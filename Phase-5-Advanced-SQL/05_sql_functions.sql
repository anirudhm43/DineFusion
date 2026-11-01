
USE dinefusion_db;

-- =====================================================
-- PHASE 5.5: SQL FUNCTIONS
-- Project: DineFusion
-- =====================================================


-- =====================================================
-- SECTION 1: STRING FUNCTIONS
-- =====================================================

-- Q1. Convert customer names to uppercase.
SELECT
    customer_id,
    UPPER(name) AS uppercase_name
FROM CUSTOMER;


-- Q2. Convert customer names to lowercase.
SELECT
    customer_id,
    LOWER(name) AS lowercase_name
FROM CUSTOMER;


-- Q3. Combine customer name and email.
SELECT
    customer_id,
    CONCAT(name, ' - ', email) AS customer_details
FROM CUSTOMER;


-- Q4. Find the length of customer names.
SELECT
    name,
    CHAR_LENGTH(name) AS name_length
FROM CUSTOMER;


-- Q5. Extract the first three characters of each menu item name.
SELECT
    item_name,
    SUBSTRING(item_name, 1, 3) AS short_name
FROM MENU_ITEM;


-- Q6. Remove extra spaces from a string.
SELECT TRIM('   Welcome to DineFusion   ') AS trimmed_text;


-- =====================================================
-- SECTION 2: NUMERIC FUNCTIONS
-- =====================================================

-- Q7. Round menu item prices to the nearest integer.
SELECT
    item_name,
    price,
    ROUND(price) AS rounded_price
FROM MENU_ITEM;


-- Q8. Round menu item prices to one decimal place.
SELECT
    item_name,
    price,
    ROUND(price, 1) AS price_one_decimal
FROM MENU_ITEM;


-- Q9. Find the absolute difference between two values.
SELECT ABS(250 - 300) AS absolute_difference;


-- Q10. Find the ceiling and floor of menu item prices.
SELECT
    item_name,
    price,
    CEIL(price) AS ceiling_price,
    FLOOR(price) AS floor_price
FROM MENU_ITEM;


-- =====================================================
-- SECTION 3: DATE AND TIME FUNCTIONS
-- =====================================================

-- Q11. Display the current date and time.
SELECT NOW() AS current_date_time;


-- Q12. Display only the current date.
SELECT CURRENT_DATE() AS today;


-- Q13. Display order dates in a readable format.
SELECT
    order_id,
    DATE_FORMAT(order_date, '%d-%m-%Y') AS formatted_order_date
FROM RESTAURANT_ORDER;


-- Q14. Calculate the number of days since each order was placed.
SELECT
    order_id,
    order_date,
    DATEDIFF(CURDATE(), order_date) AS days_since_order
FROM RESTAURANT_ORDER;


-- Q15. Extract the year and month from order dates.
SELECT
    order_id,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month
FROM RESTAURANT_ORDER;


-- =====================================================
-- SECTION 4: NULL-HANDLING FUNCTIONS
-- =====================================================

-- Q16. Replace NULL customer IDs with the text 'Guest'.
SELECT
    order_id,
    COALESCE(CAST(customer_id AS CHAR), 'Guest') AS customer_reference
FROM RESTAURANT_ORDER;


-- Q17. Use IFNULL to replace NULL values.
SELECT
    order_id,
    IFNULL(discount, 0) AS discount_amount
FROM RESTAURANT_ORDER;


-- Q18. Use COALESCE to return the first non-NULL value.
SELECT
    COALESCE(NULL, NULL, 'DineFusion') AS first_non_null_value;


-- Q19. Use NULLIF to return NULL when two values are equal.
SELECT
    NULLIF(100, 100) AS result_when_equal,
    NULLIF(100, 200) AS result_when_different;


-- =====================================================
-- SECTION 5: TYPE CONVERSION FUNCTIONS
-- =====================================================

-- Q20. Convert menu item prices into character values.
SELECT
    item_name,
    CAST(price AS CHAR) AS price_as_text
FROM MENU_ITEM;


-- Q21. Convert a numeric string into a decimal value.
SELECT
    CAST('1250.75' AS DECIMAL(10,2)) AS converted_amount;


-- =====================================================
-- SECTION 6: AGGREGATE STRING FUNCTION
-- =====================================================

-- Q22. Display all menu item names in one comma-separated list.
SELECT
    GROUP_CONCAT(item_name SEPARATOR ', ') AS all_menu_items
FROM MENU_ITEM;


-- Q23. Display menu items grouped by category.
SELECT
    C.category_name,
    GROUP_CONCAT(M.item_name SEPARATOR ', ') AS menu_items
FROM MENU_CATEGORY C
LEFT JOIN MENU_ITEM M
    ON C.category_id = M.category_id
GROUP BY C.category_id, C.category_name;


-- =====================================================
-- END OF PHASE 5.5
-- =====================================================
