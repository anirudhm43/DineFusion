
USE dinefusion_db;

-- =====================================================
-- PHASE 6.5: BEFORE AND AFTER TRIGGERS
-- Project: DineFusion
-- Database: MySQL
-- =====================================================


-- =====================================================
-- SECTION 1: CREATE AUDIT TABLE
-- This table stores menu price changes.
-- =====================================================

CREATE TABLE IF NOT EXISTS MENU_PRICE_AUDIT (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    old_price DECIMAL(10,2),
    new_price DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type VARCHAR(20)
);


DELIMITER //


-- =====================================================
-- Q1. BEFORE INSERT TRIGGER
-- Prevent negative or zero menu prices.
-- =====================================================

DROP TRIGGER IF EXISTS trg_before_menu_insert//

CREATE TRIGGER trg_before_menu_insert
BEFORE INSERT ON MENU_ITEM
FOR EACH ROW
BEGIN
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Menu price must be greater than zero';
    END IF;
END//


-- =====================================================
-- Q2. BEFORE UPDATE TRIGGER
-- Prevent negative or zero prices during updates.
-- =====================================================

DROP TRIGGER IF EXISTS trg_before_menu_update//

CREATE TRIGGER trg_before_menu_update
BEFORE UPDATE ON MENU_ITEM
FOR EACH ROW
BEGIN
    IF NEW.price <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Updated menu price must be greater than zero';
    END IF;
END//


-- =====================================================
-- Q3. AFTER UPDATE TRIGGER
-- Record menu price changes in audit table.
-- =====================================================

DROP TRIGGER IF EXISTS trg_after_menu_update//

CREATE TRIGGER trg_after_menu_update
AFTER UPDATE ON MENU_ITEM
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN

        INSERT INTO MENU_PRICE_AUDIT (
            item_id,
            old_price,
            new_price,
            action_type
        )
        VALUES (
            OLD.item_id,
            OLD.price,
            NEW.price,
            'PRICE UPDATE'
        );

    END IF;
END//


-- =====================================================
-- Q4. BEFORE INSERT TRIGGER
-- Validate customer review ratings.
-- Valid rating range: 1 to 5.
-- =====================================================

DROP TRIGGER IF EXISTS trg_before_review_insert//

CREATE TRIGGER trg_before_review_insert
BEFORE INSERT ON REVIEW
FOR EACH ROW
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Review rating must be between 1 and 5';
    END IF;
END//


-- =====================================================
-- Q5. AFTER INSERT TRIGGER
-- Record a newly inserted review in an audit table.
-- =====================================================

CREATE TABLE IF NOT EXISTS REVIEW_AUDIT (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    review_id INT NOT NULL,
    customer_id INT NOT NULL,
    item_id INT NOT NULL,
    rating INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)//

DROP TRIGGER IF EXISTS trg_after_review_insert//

CREATE TRIGGER trg_after_review_insert
AFTER INSERT ON REVIEW
FOR EACH ROW
BEGIN
    INSERT INTO REVIEW_AUDIT (
        review_id,
        customer_id,
        item_id,
        rating
    )
    VALUES (
        NEW.review_id,
        NEW.customer_id,
        NEW.item_id,
        NEW.rating
    );
END//


-- =====================================================
-- Q6. BEFORE DELETE TRIGGER
-- Prevent deletion of a menu item with existing order items.
-- =====================================================

DROP TRIGGER IF EXISTS trg_before_menu_delete//

CREATE TRIGGER trg_before_menu_delete
BEFORE DELETE ON MENU_ITEM
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM ORDER_ITEM
        WHERE item_id = OLD.item_id
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Cannot delete menu item because it exists in order history';

    END IF;
END//


-- =====================================================
-- Q7. AFTER DELETE TRIGGER
-- Record deleted menu item details in an audit table.
-- =====================================================

CREATE TABLE IF NOT EXISTS MENU_DELETE_AUDIT (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    item_name VARCHAR(150),
    deleted_price DECIMAL(10,2),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)//

DROP TRIGGER IF EXISTS trg_after_menu_delete//

CREATE TRIGGER trg_after_menu_delete
AFTER DELETE ON MENU_ITEM
FOR EACH ROW
BEGIN
    INSERT INTO MENU_DELETE_AUDIT (
        item_id,
        item_name,
        deleted_price
    )
    VALUES (
        OLD.item_id,
        OLD.item_name,
        OLD.price
    );
END//


DELIMITER ;


-- =====================================================
-- SECTION 2: TESTING THE TRIGGERS
-- =====================================================


-- Q8. Verify all triggers.
SHOW TRIGGERS
WHERE `Table` IN ('MENU_ITEM', 'REVIEW');


-- Q9. Check menu price audit records.
SELECT * FROM MENU_PRICE_AUDIT;


-- Q10. Check review audit records.
SELECT * FROM REVIEW_AUDIT;


-- Q11. Check deleted menu item audit records.
SELECT * FROM MENU_DELETE_AUDIT;


-- =====================================================
-- END OF PHASE 6.5
-- =====================================================
