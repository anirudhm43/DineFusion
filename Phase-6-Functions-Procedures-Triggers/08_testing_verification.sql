
USE dinefusion_db;

-- =====================================================
-- PHASE 6.8: TESTING AND VERIFICATION
-- Project: DineFusion
-- =====================================================


-- =====================================================
-- SECTION 1: VERIFY USER-DEFINED FUNCTIONS
-- =====================================================

-- Q1. List all functions.

SHOW FUNCTION STATUS
WHERE Db = 'dinefusion_db';


-- Q2. Test tax calculation.

SELECT fn_calculate_tax(1000, 5)
AS calculated_tax;


-- Q3. Test discount calculation.

SELECT fn_calculate_discount(1000, 10)
AS calculated_discount;


-- Q4. Test final bill calculation.

SELECT fn_calculate_final_amount(1000, 10, 5)
AS final_bill_amount;


-- Q5. Test customer order count.

SELECT fn_get_customer_order_count(1)
AS customer_order_count;


-- =====================================================
-- SECTION 2: VERIFY STORED PROCEDURES
-- =====================================================

-- Q6. List all stored procedures.

SHOW PROCEDURE STATUS
WHERE Db = 'dinefusion_db';


-- Q7. Test customer display procedure.

CALL sp_display_customers();


-- Q8. Test menu display procedure.

CALL sp_display_menu();


-- Q9. Test customer order procedure.

CALL sp_get_customer_orders(1);


-- Q10. Test branch order procedure.

CALL sp_get_branch_orders(1);


-- =====================================================
-- SECTION 3: VERIFY IN, OUT AND INOUT PARAMETERS
-- =====================================================

-- Q11. Test OUT parameter.

SET @test_order_count = 0;

CALL sp_customer_order_count(1, @test_order_count);

SELECT @test_order_count AS total_orders;


-- Q12. Test OUT parameter for branch revenue.

SET @test_revenue = 0;

CALL sp_branch_revenue(1, @test_revenue);

SELECT @test_revenue AS branch_revenue;


-- Q13. Test INOUT parameter for discount.

SET @test_amount = 1000;

CALL sp_apply_discount(@test_amount, 10);

SELECT @test_amount AS discounted_amount;


-- =====================================================
-- SECTION 4: VERIFY CONDITIONAL LOGIC AND LOOPS
-- =====================================================

-- Q14. Test order classification.

CALL sp_classify_order(1);


-- Q15. Test conditional discount.

SET @test_discount = 0;

CALL sp_calculate_order_discount(1500, @test_discount);

SELECT @test_discount AS calculated_discount;


-- Q16. Test CASE statement.

CALL sp_classify_menu_items();


-- Q17. Test WHILE loop.

CALL sp_generate_numbers(5);


-- Q18. Test REPEAT loop.

CALL sp_repeat_numbers(5);


-- Q19. Test LOOP with LEAVE.

CALL sp_loop_with_leave();


-- Q20. Test LOOP with ITERATE.

CALL sp_loop_with_iterate();


-- =====================================================
-- SECTION 5: VERIFY TRIGGERS
-- =====================================================

-- Q21. Display all triggers in the database.

SHOW TRIGGERS;


-- Q22. Display menu price audit.

SELECT *
FROM MENU_PRICE_AUDIT;


-- Q23. Display review audit.

SELECT *
FROM REVIEW_AUDIT;


-- Q24. Display menu deletion audit.

SELECT *
FROM MENU_DELETE_AUDIT;


-- Q25. Display payment audit.

SELECT *
FROM PAYMENT_AUDIT
ORDER BY audit_id;


-- =====================================================
-- SECTION 6: VERIFY INVENTORY
-- =====================================================

-- Q26. Display inventory for all branches.

SELECT
    B.branch_name,
    G.ingredient_name,
    I.quantity_available,
    G.reorder_level
FROM INVENTORY I
INNER JOIN BRANCH B
    ON I.branch_id = B.branch_id
INNER JOIN INGREDIENT G
    ON I.ingredient_id = G.ingredient_id
ORDER BY B.branch_name, G.ingredient_name;


-- =====================================================
-- SECTION 7: VERIFY PAYMENT AND ORDER STATUS
-- =====================================================

-- Q27. Display payment and corresponding order status.

SELECT
    P.payment_id,
    P.order_id,
    P.payment_method,
    P.payment_status,
    P.amount,
    O.order_status
FROM PAYMENT P
INNER JOIN RESTAURANT_ORDER O
    ON P.order_id = O.order_id;


-- =====================================================
-- SECTION 8: DATABASE OBJECT SUMMARY
-- =====================================================

-- Q28. Count tables.

SELECT COUNT(*) AS total_tables
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dinefusion_db'
AND TABLE_TYPE = 'BASE TABLE';


-- Q29. Count stored functions.

SELECT COUNT(*) AS total_functions
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'dinefusion_db'
AND ROUTINE_TYPE = 'FUNCTION';


-- Q30. Count stored procedures.

SELECT COUNT(*) AS total_procedures
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'dinefusion_db'
AND ROUTINE_TYPE = 'PROCEDURE';


-- Q31. Count triggers.

SELECT COUNT(*) AS total_triggers
FROM INFORMATION_SCHEMA.TRIGGERS
WHERE TRIGGER_SCHEMA = 'dinefusion_db';


-- =====================================================
-- END OF PHASE 6.8
-- =====================================================
