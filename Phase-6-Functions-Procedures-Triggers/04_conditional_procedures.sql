
USE dinefusion_db;

-- =====================================================
-- PHASE 6.4: CONDITIONAL LOGIC AND LOOPS
-- Project: DineFusion
-- =====================================================

DELIMITER //


-- =====================================================
-- Q1. IF-ELSE
-- Classify an order based on its total amount.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_classify_order//

CREATE PROCEDURE sp_classify_order(
    IN p_order_id INT
)
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT total_amount
    INTO v_total
    FROM RESTAURANT_ORDER
    WHERE order_id = p_order_id;

    IF v_total IS NULL THEN
        SELECT 'ORDER NOT FOUND' AS order_category;

    ELSEIF v_total >= 1000 THEN
        SELECT 'HIGH VALUE ORDER' AS order_category;

    ELSEIF v_total >= 500 THEN
        SELECT 'MEDIUM VALUE ORDER' AS order_category;

    ELSE
        SELECT 'LOW VALUE ORDER' AS order_category;
    END IF;
END//


-- =====================================================
-- Q2. IF-ELSE WITH DISCOUNT
-- Apply a discount based on order subtotal.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_calculate_order_discount//

CREATE PROCEDURE sp_calculate_order_discount(
    IN p_subtotal DECIMAL(10,2),
    OUT p_discount DECIMAL(10,2)
)
BEGIN
    IF p_subtotal >= 2000 THEN
        SET p_discount = p_subtotal * 0.20;

    ELSEIF p_subtotal >= 1000 THEN
        SET p_discount = p_subtotal * 0.10;

    ELSEIF p_subtotal >= 500 THEN
        SET p_discount = p_subtotal * 0.05;

    ELSE
        SET p_discount = 0;
    END IF;
END//


-- =====================================================
-- Q3. CASE STATEMENT
-- Classify menu items based on their prices.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_classify_menu_items//

CREATE PROCEDURE sp_classify_menu_items()
BEGIN
    SELECT
        item_id,
        item_name,
        price,
        CASE
            WHEN price >= 300 THEN 'PREMIUM'
            WHEN price >= 150 THEN 'STANDARD'
            ELSE 'BUDGET'
        END AS price_category
    FROM MENU_ITEM
    ORDER BY price DESC;
END//


-- =====================================================
-- Q4. WHILE LOOP
-- Generate numbers from 1 to a given limit.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_generate_numbers//

CREATE PROCEDURE sp_generate_numbers(
    IN p_limit INT
)
BEGIN
    DECLARE v_counter INT DEFAULT 1;

    IF p_limit IS NULL OR p_limit < 1 OR p_limit > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Limit must be between 1 and 100';

    ELSE
        DROP TEMPORARY TABLE IF EXISTS temp_numbers;

        CREATE TEMPORARY TABLE temp_numbers (
            number_value INT
        );

        WHILE v_counter <= p_limit DO

            INSERT INTO temp_numbers(number_value)
            VALUES (v_counter);

            SET v_counter = v_counter + 1;

        END WHILE;

        SELECT * FROM temp_numbers;

        DROP TEMPORARY TABLE IF EXISTS temp_numbers;
    END IF;
END//


-- =====================================================
-- Q5. REPEAT LOOP
-- Generate numbers from 1 to a given limit.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_repeat_numbers//

CREATE PROCEDURE sp_repeat_numbers(
    IN p_limit INT
)
BEGIN
    DECLARE v_counter INT DEFAULT 1;

    IF p_limit IS NULL OR p_limit < 1 OR p_limit > 100 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Limit must be between 1 and 100';

    ELSE
        DROP TEMPORARY TABLE IF EXISTS temp_repeat_numbers;

        CREATE TEMPORARY TABLE temp_repeat_numbers (
            number_value INT
        );

        REPEAT

            INSERT INTO temp_repeat_numbers(number_value)
            VALUES (v_counter);

            SET v_counter = v_counter + 1;

        UNTIL v_counter > p_limit
        END REPEAT;

        SELECT * FROM temp_repeat_numbers;

        DROP TEMPORARY TABLE IF EXISTS temp_repeat_numbers;
    END IF;
END//


-- =====================================================
-- Q6. LOOP WITH LEAVE
-- Generate numbers and stop at 5.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_loop_with_leave//

CREATE PROCEDURE sp_loop_with_leave()
BEGIN
    DECLARE v_counter INT DEFAULT 1;

    DROP TEMPORARY TABLE IF EXISTS temp_loop_numbers;

    CREATE TEMPORARY TABLE temp_loop_numbers (
        number_value INT
    );

    number_loop: LOOP

        IF v_counter > 5 THEN
            LEAVE number_loop;
        END IF;

        INSERT INTO temp_loop_numbers(number_value)
        VALUES (v_counter);

        SET v_counter = v_counter + 1;

    END LOOP number_loop;

    SELECT * FROM temp_loop_numbers;

    DROP TEMPORARY TABLE IF EXISTS temp_loop_numbers;
END//


-- =====================================================
-- Q7. LOOP WITH ITERATE
-- Skip even numbers and display odd numbers.
-- =====================================================

DROP PROCEDURE IF EXISTS sp_loop_with_iterate//

CREATE PROCEDURE sp_loop_with_iterate()
BEGIN
    DECLARE v_counter INT DEFAULT 0;

    DROP TEMPORARY TABLE IF EXISTS temp_odd_numbers;

    CREATE TEMPORARY TABLE temp_odd_numbers (
        number_value INT
    );

    number_loop: LOOP

        SET v_counter = v_counter + 1;

        IF v_counter > 10 THEN
            LEAVE number_loop;
        END IF;

        IF MOD(v_counter, 2) = 0 THEN
            ITERATE number_loop;
        END IF;

        INSERT INTO temp_odd_numbers(number_value)
        VALUES (v_counter);

    END LOOP number_loop;

    SELECT * FROM temp_odd_numbers;

    DROP TEMPORARY TABLE IF EXISTS temp_odd_numbers;
END//


DELIMITER ;


-- =====================================================
-- TESTING THE PROCEDURES
-- =====================================================


-- Q8. Test order classification.
CALL sp_classify_order(1);


-- Q9. Test discount calculation.
SET @discount = 0;

CALL sp_calculate_order_discount(1500, @discount);

SELECT @discount AS calculated_discount;


-- Q10. Test menu item classification.
CALL sp_classify_menu_items();


-- Q11. Test WHILE loop.
CALL sp_generate_numbers(5);


-- Q12. Test REPEAT loop.
CALL sp_repeat_numbers(5);


-- Q13. Test LOOP with LEAVE.
CALL sp_loop_with_leave();


-- Q14. Test LOOP with ITERATE.
CALL sp_loop_with_iterate();


-- Q15. Verify stored procedures.
SHOW PROCEDURE STATUS
WHERE Db = 'dinefusion_db';


-- =====================================================
-- END OF PHASE 6.4
-- =====================================================
