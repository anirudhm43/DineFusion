
USE dinefusion_db;

-- =====================================================
-- PHASE 6.3: PROCEDURE PARAMETERS
-- IN, OUT AND INOUT
-- Project: DineFusion
-- =====================================================

DELIMITER //


-- =====================================================
-- Q1. IN PARAMETER
-- Purpose: Display orders for a particular customer.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_orders_by_customer//

CREATE PROCEDURE sp_orders_by_customer(
    IN p_customer_id INT
)
BEGIN
    SELECT
        order_id,
        customer_id,
        order_type,
        order_status,
        order_date,
        total_amount
    FROM RESTAURANT_ORDER
    WHERE customer_id = p_customer_id;
END//


-- =====================================================
-- Q2. OUT PARAMETER
-- Purpose: Return the total number of orders
-- placed by a particular customer.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_customer_order_count//

CREATE PROCEDURE sp_customer_order_count(
    IN p_customer_id INT,
    OUT p_total_orders INT
)
BEGIN
    SELECT COUNT(*)
    INTO p_total_orders
    FROM RESTAURANT_ORDER
    WHERE customer_id = p_customer_id;
END//


-- =====================================================
-- Q3. OUT PARAMETER
-- Purpose: Return the total revenue of a branch.
-- Cancelled orders are excluded.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_branch_revenue//

CREATE PROCEDURE sp_branch_revenue(
    IN p_branch_id INT,
    OUT p_total_revenue DECIMAL(12,2)
)
BEGIN
    SELECT COALESCE(SUM(total_amount), 0)
    INTO p_total_revenue
    FROM RESTAURANT_ORDER
    WHERE branch_id = p_branch_id
      AND order_status <> 'CANCELLED';
END//


-- =====================================================
-- Q4. INOUT PARAMETER
-- Purpose: Apply a discount percentage to an amount.
-- The input amount is modified and returned.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_apply_discount//

CREATE PROCEDURE sp_apply_discount(
    INOUT p_amount DECIMAL(10,2),
    IN p_discount_rate DECIMAL(5,2)
)
BEGIN
    SET p_amount =
        p_amount - (p_amount * p_discount_rate / 100);
END//


-- =====================================================
-- Q5. INOUT PARAMETER
-- Purpose: Add a service charge to an amount.
-- The amount is modified and returned.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_add_service_charge//

CREATE PROCEDURE sp_add_service_charge(
    INOUT p_amount DECIMAL(10,2),
    IN p_service_rate DECIMAL(5,2)
)
BEGIN
    SET p_amount =
        p_amount + (p_amount * p_service_rate / 100);
END//


DELIMITER ;


-- =====================================================
-- TESTING THE PROCEDURES
-- =====================================================


-- Q6. Test IN parameter.
CALL sp_orders_by_customer(1);


-- Q7. Test OUT parameter: customer order count.

SET @order_count = 0;

CALL sp_customer_order_count(1, @order_count);

SELECT @order_count AS total_customer_orders;


-- Q8. Test OUT parameter: branch revenue.

SET @branch_revenue = 0;

CALL sp_branch_revenue(1, @branch_revenue);

SELECT @branch_revenue AS total_branch_revenue;


-- Q9. Test INOUT parameter: apply 10% discount.

SET @amount = 1000.00;

CALL sp_apply_discount(@amount, 10);

SELECT @amount AS amount_after_discount;


-- Q10. Test INOUT parameter: add 5% service charge.

SET @amount = 1000.00;

CALL sp_add_service_charge(@amount, 5);

SELECT @amount AS amount_after_service_charge;


-- Q11. Verify stored procedures.

SHOW PROCEDURE STATUS
WHERE Db = 'dinefusion_db';


-- =====================================================
-- END OF PHASE 6.3
-- =====================================================
