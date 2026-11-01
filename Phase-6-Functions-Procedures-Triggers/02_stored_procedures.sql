
USE dinefusion_db;

-- =====================================================
-- PHASE 6.2: STORED PROCEDURES
-- Project: DineFusion
-- Database: MySQL
-- =====================================================

DELIMITER //


-- =====================================================
-- Q1. PROCEDURE: Display all customers
-- =====================================================

DROP PROCEDURE IF EXISTS sp_display_customers//

CREATE PROCEDURE sp_display_customers()
BEGIN
    SELECT
        customer_id,
        name,
        email,
        phone,
        created_at
    FROM CUSTOMER
    ORDER BY customer_id;
END//


-- =====================================================
-- Q2. PROCEDURE: Display available menu items
-- =====================================================

DROP PROCEDURE IF EXISTS sp_display_menu//

CREATE PROCEDURE sp_display_menu()
BEGIN
    SELECT
        item_id,
        item_name,
        price,
        is_vegetarian,
        availability_status
    FROM MENU_ITEM
    WHERE availability_status = 'AVAILABLE'
    ORDER BY item_name;
END//


-- =====================================================
-- Q3. PROCEDURE: Get orders of a customer
-- =====================================================

DROP PROCEDURE IF EXISTS sp_get_customer_orders//

CREATE PROCEDURE sp_get_customer_orders(
    IN p_customer_id INT
)
BEGIN
    SELECT
        order_id,
        order_type,
        order_status,
        order_date,
        total_amount
    FROM RESTAURANT_ORDER
    WHERE customer_id = p_customer_id
    ORDER BY order_date DESC;
END//


-- =====================================================
-- Q4. PROCEDURE: Get orders of a branch
-- =====================================================

DROP PROCEDURE IF EXISTS sp_get_branch_orders//

CREATE PROCEDURE sp_get_branch_orders(
    IN p_branch_id INT
)
BEGIN
    SELECT
        O.order_id,
        O.order_type,
        O.order_status,
        O.order_date,
        O.total_amount,
        B.branch_name
    FROM RESTAURANT_ORDER O
    INNER JOIN BRANCH B
        ON O.branch_id = B.branch_id
    WHERE O.branch_id = p_branch_id
    ORDER BY O.order_date DESC;
END//


-- =====================================================
-- Q5. PROCEDURE: Get details of a particular order
-- =====================================================

DROP PROCEDURE IF EXISTS sp_get_order_details//

CREATE PROCEDURE sp_get_order_details(
    IN p_order_id INT
)
BEGIN
    SELECT
        O.order_id,
        O.order_date,
        O.order_status,
        M.item_name,
        OI.quantity,
        OI.unit_price,
        OI.subtotal AS item_subtotal
    FROM RESTAURANT_ORDER O
    INNER JOIN ORDER_ITEM OI
        ON O.order_id = OI.order_id
    INNER JOIN MENU_ITEM M
        ON OI.item_id = M.item_id
    WHERE O.order_id = p_order_id;
END//


-- =====================================================
-- Q6. PROCEDURE: Get low-stock ingredients
-- =====================================================

DROP PROCEDURE IF EXISTS sp_get_low_stock_items//

CREATE PROCEDURE sp_get_low_stock_items(
    IN p_branch_id INT
)
BEGIN
    SELECT
        I.inventory_id,
        G.ingredient_id,
        G.ingredient_name,
        I.quantity_available,
        G.reorder_level,
        B.branch_name
    FROM INVENTORY I
    INNER JOIN INGREDIENT G
        ON I.ingredient_id = G.ingredient_id
    INNER JOIN BRANCH B
        ON I.branch_id = B.branch_id
    WHERE I.branch_id = p_branch_id
      AND I.quantity_available <= G.reorder_level
    ORDER BY G.ingredient_name;
END//


DELIMITER ;


-- =====================================================
-- TESTING THE STORED PROCEDURES
-- =====================================================


-- Q7. Display all customers.
CALL sp_display_customers();


-- Q8. Display available menu items.
CALL sp_display_menu();


-- Q9. Display orders placed by customer ID 1.
CALL sp_get_customer_orders(1);


-- Q10. Display orders belonging to branch ID 1.
CALL sp_get_branch_orders(1);


-- Q11. Display details of order ID 1.
CALL sp_get_order_details(1);


-- Q12. Display low-stock ingredients at branch ID 1.
CALL sp_get_low_stock_items(1);


-- Q13. Verify that the procedures exist.
SHOW PROCEDURE STATUS
WHERE Db = 'dinefusion_db';


-- =====================================================
-- END OF PHASE 6.2
-- =====================================================
