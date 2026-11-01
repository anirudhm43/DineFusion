
USE dinefusion_db;

-- =====================================================
-- PHASE 6.7: PAYMENT TRIGGERS
-- Project: DineFusion
-- =====================================================


-- =====================================================
-- SECTION 1: PAYMENT AUDIT TABLE
-- Stores payment status changes and deletions.
-- =====================================================

CREATE TABLE IF NOT EXISTS PAYMENT_AUDIT (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id INT,
    order_id INT,
    old_status VARCHAR(30),
    new_status VARCHAR(30),
    payment_amount DECIMAL(10,2),
    action_type VARCHAR(30),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


DELIMITER //


-- =====================================================
-- Q1. BEFORE INSERT TRIGGER
-- Validate payment amount.
-- =====================================================

DROP TRIGGER IF EXISTS trg_before_payment_insert//

CREATE TRIGGER trg_before_payment_insert
BEFORE INSERT ON PAYMENT
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Payment amount must be greater than zero';
    END IF;
END//


-- =====================================================
-- Q2. AFTER INSERT TRIGGER
-- Update order status based on payment status.
-- =====================================================

DROP TRIGGER IF EXISTS trg_after_payment_insert//

CREATE TRIGGER trg_after_payment_insert
AFTER INSERT ON PAYMENT
FOR EACH ROW
BEGIN

    IF NEW.payment_status = 'SUCCESS' THEN

        UPDATE RESTAURANT_ORDER
        SET order_status = 'COMPLETED'
        WHERE order_id = NEW.order_id;

    ELSEIF NEW.payment_status = 'FAILED' THEN

        UPDATE RESTAURANT_ORDER
        SET order_status = 'PAYMENT_FAILED'
        WHERE order_id = NEW.order_id;

    ELSEIF NEW.payment_status = 'REFUNDED' THEN

        UPDATE RESTAURANT_ORDER
        SET order_status = 'REFUNDED'
        WHERE order_id = NEW.order_id;

    END IF;

    INSERT INTO PAYMENT_AUDIT (
        payment_id,
        order_id,
        old_status,
        new_status,
        payment_amount,
        action_type
    )
    VALUES (
        NEW.payment_id,
        NEW.order_id,
        NULL,
        NEW.payment_status,
        NEW.amount,
        'PAYMENT INSERT'
    );

END//


-- =====================================================
-- Q3. BEFORE UPDATE TRIGGER
-- Validate payment amount during updates.
-- =====================================================

DROP TRIGGER IF EXISTS trg_before_payment_update//

CREATE TRIGGER trg_before_payment_update
BEFORE UPDATE ON PAYMENT
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Updated payment amount must be greater than zero';
    END IF;
END//


-- =====================================================
-- Q4. AFTER UPDATE TRIGGER
-- Update order status and record payment changes.
-- =====================================================

DROP TRIGGER IF EXISTS trg_after_payment_update//

CREATE TRIGGER trg_after_payment_update
AFTER UPDATE ON PAYMENT
FOR EACH ROW
BEGIN

    IF NEW.payment_status <> OLD.payment_status THEN

        IF NEW.payment_status = 'SUCCESS' THEN

            UPDATE RESTAURANT_ORDER
            SET order_status = 'COMPLETED'
            WHERE order_id = NEW.order_id;

        ELSEIF NEW.payment_status = 'FAILED' THEN

            UPDATE RESTAURANT_ORDER
            SET order_status = 'PAYMENT_FAILED'
            WHERE order_id = NEW.order_id;

        ELSEIF NEW.payment_status = 'REFUNDED' THEN

            UPDATE RESTAURANT_ORDER
            SET order_status = 'REFUNDED'
            WHERE order_id = NEW.order_id;

        ELSEIF NEW.payment_status = 'PENDING' THEN

            UPDATE RESTAURANT_ORDER
            SET order_status = 'PENDING'
            WHERE order_id = NEW.order_id;

        END IF;

        INSERT INTO PAYMENT_AUDIT (
            payment_id,
            order_id,
            old_status,
            new_status,
            payment_amount,
            action_type
        )
        VALUES (
            NEW.payment_id,
            NEW.order_id,
            OLD.payment_status,
            NEW.payment_status,
            NEW.amount,
            'PAYMENT UPDATE'
        );

    END IF;

END//


-- =====================================================
-- Q5. AFTER DELETE TRIGGER
-- Record deleted payment details and reset order status.
-- =====================================================

DROP TRIGGER IF EXISTS trg_after_payment_delete//

CREATE TRIGGER trg_after_payment_delete
AFTER DELETE ON PAYMENT
FOR EACH ROW
BEGIN

    UPDATE RESTAURANT_ORDER
    SET order_status = 'PENDING'
    WHERE order_id = OLD.order_id;

    INSERT INTO PAYMENT_AUDIT (
        payment_id,
        order_id,
        old_status,
        new_status,
        payment_amount,
        action_type
    )
    VALUES (
        OLD.payment_id,
        OLD.order_id,
        OLD.payment_status,
        NULL,
        OLD.amount,
        'PAYMENT DELETE'
    );

END//


DELIMITER ;


-- =====================================================
-- SECTION 2: VERIFY TRIGGERS
-- =====================================================

SHOW TRIGGERS
WHERE `Table` = 'PAYMENT';


-- =====================================================
-- SECTION 3: VIEW PAYMENT RECORDS
-- =====================================================

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
-- SECTION 4: VIEW PAYMENT AUDIT
-- =====================================================

SELECT *
FROM PAYMENT_AUDIT
ORDER BY audit_id;


-- =====================================================
-- END OF PHASE 6.7
-- =====================================================
