
USE dinefusion_db;

-- =====================================================
-- PHASE 5.6: SQL VIEWS
-- Project: DineFusion
-- =====================================================


-- =====================================================
-- Q1. Create a view showing customer details.
-- =====================================================

CREATE OR REPLACE VIEW vw_customer_details AS
SELECT
    customer_id,
    name,
    email,
    phone,
    created_at
FROM CUSTOMER;

-- Display the view.
SELECT * FROM vw_customer_details;


-- =====================================================
-- Q2. Create a view showing menu items and categories.
-- =====================================================

CREATE OR REPLACE VIEW vw_menu_details AS
SELECT
    M.item_id,
    M.item_name,
    M.description,
    M.price,
    M.is_vegetarian,
    M.availability_status,
    C.category_name
FROM MENU_ITEM M
INNER JOIN MENU_CATEGORY C
    ON M.category_id = C.category_id;

-- Display menu details.
SELECT * FROM vw_menu_details;


-- =====================================================
-- Q3. Create a view showing complete order details.
-- =====================================================

CREATE OR REPLACE VIEW vw_order_details AS
SELECT
    O.order_id,
    O.order_date,
    O.order_type,
    O.order_status,
    C.customer_id,
    C.name AS customer_name,
    O.subtotal,
    O.tax,
    O.discount,
    O.total_amount
FROM RESTAURANT_ORDER O
LEFT JOIN CUSTOMER C
    ON O.customer_id = C.customer_id;

-- Display order details.
SELECT * FROM vw_order_details;


-- =====================================================
-- Q4. Create a view showing order items and menu details.
-- =====================================================

CREATE OR REPLACE VIEW vw_order_item_details AS
SELECT
    O.order_id,
    O.order_date,
    M.item_name,
    OI.quantity,
    OI.unit_price,
    OI.subtotal AS item_subtotal
FROM ORDER_ITEM OI
INNER JOIN RESTAURANT_ORDER O
    ON OI.order_id = O.order_id
INNER JOIN MENU_ITEM M
    ON OI.item_id = M.item_id;

-- Display order item details.
SELECT * FROM vw_order_item_details;


-- =====================================================
-- Q5. Create a view showing branch-wise revenue.
-- =====================================================

CREATE OR REPLACE VIEW vw_branch_revenue AS
SELECT
    B.branch_id,
    B.branch_name,
    COUNT(O.order_id) AS total_orders,
    COALESCE(SUM(
        CASE
            WHEN O.order_status <> 'CANCELLED'
            THEN O.total_amount
            ELSE 0
        END
    ), 0) AS total_revenue
FROM BRANCH B
LEFT JOIN RESTAURANT_ORDER O
    ON B.branch_id = O.branch_id
GROUP BY
    B.branch_id,
    B.branch_name;

-- Display branch revenue.
SELECT * FROM vw_branch_revenue;


-- =====================================================
-- Q6. Create a view showing customer review details.
-- =====================================================

CREATE OR REPLACE VIEW vw_customer_reviews AS
SELECT
    R.review_id,
    C.customer_id,
    C.name AS customer_name,
    M.item_name,
    R.rating,
    R.created_at
FROM REVIEW R
INNER JOIN CUSTOMER C
    ON R.customer_id = C.customer_id
INNER JOIN MENU_ITEM M
    ON R.item_id = M.item_id;

-- Display customer reviews.
SELECT * FROM vw_customer_reviews;


-- =====================================================
-- Q7. Create a view showing employee and branch details.
-- =====================================================

CREATE OR REPLACE VIEW vw_employee_branch AS
SELECT
    E.employee_id,
    E.name AS employee_name,
    E.role,
    E.email,
    B.branch_name,
    B.city
FROM EMPLOYEE E
INNER JOIN BRANCH B
    ON E.branch_id = B.branch_id;

-- Display employee and branch details.
SELECT * FROM vw_employee_branch;


-- =====================================================
-- Q8. Filter a view using WHERE.
-- Display menu items priced above 200.
-- =====================================================

SELECT *
FROM vw_menu_details
WHERE price > 200;


-- =====================================================
-- Q9. Sort data obtained from a view.
-- Display menu items from highest to lowest price.
-- =====================================================

SELECT *
FROM vw_menu_details
ORDER BY price DESC;


-- =====================================================
-- Q10. Use aggregate functions on a view.
-- Find average menu price for each category.
-- =====================================================

SELECT
    category_name,
    AVG(price) AS average_price,
    COUNT(item_id) AS total_items
FROM vw_menu_details
GROUP BY category_name;


-- =====================================================
-- Q11. Join two views.
-- Display orders along with their item details.
-- =====================================================

SELECT
    O.order_id,
    O.customer_name,
    I.item_name,
    I.quantity,
    I.item_subtotal
FROM vw_order_details O
INNER JOIN vw_order_item_details I
    ON O.order_id = I.order_id;


-- =====================================================
-- Q12. Drop a view.
-- Uncomment only when you want to remove a view.
-- =====================================================

-- DROP VIEW vw_customer_details;


-- =====================================================
-- END OF PHASE 5.6
-- =====================================================
