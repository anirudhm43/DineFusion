
USE dinefusion_db;

-- =====================================================
-- PHASE 6.1: USER-DEFINED SQL FUNCTIONS
-- Project: DineFusion
-- Database: MySQL
-- =====================================================


-- =====================================================
-- IMPORTANT:
-- DELIMITER changes how MySQL identifies statement endings.
-- It allows semicolons inside function definitions.
-- =====================================================

DELIMITER //


-- =====================================================
-- Q1. FUNCTION: Calculate tax
-- Purpose: Calculate tax based on an amount and tax rate.
-- =====================================================

DROP FUNCTION IF EXISTS fn_calculate_tax//

CREATE FUNCTION fn_calculate_tax(
    p_amount DECIMAL(10,2),
    p_tax_rate DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_tax DECIMAL(10,2);

    SET v_tax = p_amount * p_tax_rate / 100;

    RETURN ROUND(v_tax, 2);
END//


-- =====================================================
-- Q2. FUNCTION: Calculate discount
-- Purpose: Calculate discount based on amount and rate.
-- =====================================================

DROP FUNCTION IF EXISTS fn_calculate_discount//

CREATE FUNCTION fn_calculate_discount(
    p_amount DECIMAL(10,2),
    p_discount_rate DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_discount DECIMAL(10,2);

    SET v_discount = p_amount * p_discount_rate / 100;

    RETURN ROUND(v_discount, 2);
END//


-- =====================================================
-- Q3. FUNCTION: Calculate final order amount
-- Purpose: Calculate final bill after discount and tax.
-- Tax is calculated on the amount after discount.
-- =====================================================

DROP FUNCTION IF EXISTS fn_calculate_final_amount//

CREATE FUNCTION fn_calculate_final_amount(
    p_subtotal DECIMAL(10,2),
    p_discount_rate DECIMAL(5,2),
    p_tax_rate DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_discount DECIMAL(10,2);
    DECLARE v_taxable_amount DECIMAL(10,2);
    DECLARE v_tax DECIMAL(10,2);
    DECLARE v_final_amount DECIMAL(10,2);

    SET v_discount =
        p_subtotal * p_discount_rate / 100;

    SET v_taxable_amount =
        p_subtotal - v_discount;

    SET v_tax =
        v_taxable_amount * p_tax_rate / 100;

    SET v_final_amount =
        v_taxable_amount + v_tax;

    RETURN ROUND(v_final_amount, 2);
END//


-- =====================================================
-- Q4. FUNCTION: Get menu item price
-- Purpose: Retrieve the price of a menu item using ID.
-- =====================================================

DROP FUNCTION IF EXISTS fn_get_menu_item_price//

CREATE FUNCTION fn_get_menu_item_price(
    p_item_id INT
)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_price DECIMAL(10,2);

    SELECT price
    INTO v_price
    FROM MENU_ITEM
    WHERE item_id = p_item_id
    LIMIT 1;

    RETURN v_price;
END//


-- =====================================================
-- Q5. FUNCTION: Count customer orders
-- Purpose: Find the number of orders placed by a customer.
-- =====================================================

DROP FUNCTION IF EXISTS fn_get_customer_order_count//

CREATE FUNCTION fn_get_customer_order_count(
    p_customer_id INT
)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_order_count INT DEFAULT 0;

    SELECT COUNT(*)
    INTO v_order_count
    FROM RESTAURANT_ORDER
    WHERE customer_id = p_customer_id;

    RETURN v_order_count;
END//


-- =====================================================
-- Q6. FUNCTION: Get inventory stock status
-- Purpose: Compare available quantity with reorder level.
-- =====================================================

DROP FUNCTION IF EXISTS fn_get_stock_status//

CREATE FUNCTION fn_get_stock_status(
    p_inventory_id INT
)
RETURNS VARCHAR(30)
READS SQL DATA
BEGIN
    DECLARE v_quantity DECIMAL(10,2);
    DECLARE v_reorder_level DECIMAL(10,2);
    DECLARE v_status VARCHAR(30);

    SELECT
        I.quantity_available,
        G.reorder_level
    INTO
        v_quantity,
        v_reorder_level
    FROM INVENTORY I
    INNER JOIN INGREDIENT G
        ON I.ingredient_id = G.ingredient_id
    WHERE I.inventory_id = p_inventory_id
    LIMIT 1;

    IF v_quantity IS NULL THEN
        SET v_status = 'NOT FOUND';

    ELSEIF v_quantity <= v_reorder_level THEN
        SET v_status = 'REORDER REQUIRED';

    ELSE
        SET v_status = 'STOCK AVAILABLE';
    END IF;

    RETURN v_status;
END//


DELIMITER ;


-- =====================================================
-- TESTING THE FUNCTIONS
-- =====================================================


-- Q7. Test tax calculation.
SELECT
    fn_calculate_tax(1000, 5) AS calculated_tax;


-- Q8. Test discount calculation.
SELECT
    fn_calculate_discount(1000, 10) AS calculated_discount;


-- Q9. Test final amount calculation.
SELECT
    fn_calculate_final_amount(1000, 10, 5)
    AS final_amount;


-- Q10. Retrieve menu item price.
SELECT
    item_id,
    item_name,
    fn_get_menu_item_price(item_id) AS menu_price
FROM MENU_ITEM;


-- Q11. Count orders placed by each customer.
SELECT
    customer_id,
    name,
    fn_get_customer_order_count(customer_id)
    AS total_orders
FROM CUSTOMER;


-- Q12. Display inventory stock status.
SELECT
    inventory_id,
    quantity_available,
    fn_get_stock_status(inventory_id) AS stock_status
FROM INVENTORY;


-- Q13. Test function with a customer ID.
-- Replace 1 with another valid customer ID if required.
SELECT
    fn_get_customer_order_count(1) AS customer_order_count;


-- Q14. Verify that all six functions exist.
SHOW FUNCTION STATUS
WHERE Db = 'dinefusion_db';


-- =====================================================
-- END OF PHASE 6.1
-- =====================================================
