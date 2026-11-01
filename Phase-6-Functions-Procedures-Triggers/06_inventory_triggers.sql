
USE dinefusion_db;

-- =====================================================
-- PHASE 6.6: INVENTORY TRIGGERS
-- Project: DineFusion
-- =====================================================

DELIMITER //


-- =====================================================
-- Q1. BEFORE INSERT TRIGGER
-- Validate whether sufficient ingredient stock exists
-- before inserting an order item.
-- =====================================================

DROP TRIGGER IF EXISTS trg_before_order_item_insert//

CREATE TRIGGER trg_before_order_item_insert
BEFORE INSERT ON ORDER_ITEM
FOR EACH ROW
BEGIN
    DECLARE v_branch_id INT;
    DECLARE v_ingredient_count INT;
    DECLARE v_sufficient_count INT;

    -- Find the branch associated with the order.
    SELECT branch_id
    INTO v_branch_id
    FROM RESTAURANT_ORDER
    WHERE order_id = NEW.order_id;

    -- Count ingredients required by this menu item.
    SELECT COUNT(*)
    INTO v_ingredient_count
    FROM MENU_ITEM_INGREDIENT
    WHERE item_id = NEW.item_id;

    -- Check whether all required ingredients have stock.
    SELECT COUNT(*)
    INTO v_sufficient_count
    FROM MENU_ITEM_INGREDIENT MI
    INNER JOIN INVENTORY I
        ON MI.ingredient_id = I.ingredient_id
       AND I.branch_id = v_branch_id
    WHERE MI.item_id = NEW.item_id
      AND I.quantity_available >=
          (MI.quantity_required * NEW.quantity);

    -- If ingredient mappings exist, every ingredient
    -- must have sufficient stock.
    IF v_ingredient_count > 0
       AND v_sufficient_count <> v_ingredient_count THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Insufficient ingredient stock for this order item';

    END IF;
END//


-- =====================================================
-- Q2. AFTER INSERT TRIGGER
-- Deduct ingredient quantities after an order item
-- is successfully inserted.
-- =====================================================

DROP TRIGGER IF EXISTS trg_after_order_item_insert//

CREATE TRIGGER trg_after_order_item_insert
AFTER INSERT ON ORDER_ITEM
FOR EACH ROW
BEGIN
    DECLARE v_branch_id INT;

    SELECT branch_id
    INTO v_branch_id
    FROM RESTAURANT_ORDER
    WHERE order_id = NEW.order_id;

    UPDATE INVENTORY I
    INNER JOIN MENU_ITEM_INGREDIENT MI
        ON I.ingredient_id = MI.ingredient_id
    SET I.quantity_available =
        I.quantity_available -
        (MI.quantity_required * NEW.quantity),
        I.last_updated = CURRENT_TIMESTAMP
    WHERE MI.item_id = NEW.item_id
      AND I.branch_id = v_branch_id;
END//


-- =====================================================
-- Q3. AFTER DELETE TRIGGER
-- Restore ingredient quantities when an order item
-- is deleted.
-- =====================================================

DROP TRIGGER IF EXISTS trg_after_order_item_delete//

CREATE TRIGGER trg_after_order_item_delete
AFTER DELETE ON ORDER_ITEM
FOR EACH ROW
BEGIN
    DECLARE v_branch_id INT;

    SELECT branch_id
    INTO v_branch_id
    FROM RESTAURANT_ORDER
    WHERE order_id = OLD.order_id;

    UPDATE INVENTORY I
    INNER JOIN MENU_ITEM_INGREDIENT MI
        ON I.ingredient_id = MI.ingredient_id
    SET I.quantity_available =
        I.quantity_available +
        (MI.quantity_required * OLD.quantity),
        I.last_updated = CURRENT_TIMESTAMP
    WHERE MI.item_id = OLD.item_id
      AND I.branch_id = v_branch_id;
END//


-- =====================================================
-- Q4. AFTER UPDATE TRIGGER
-- Adjust ingredient stock when an order item's
-- quantity is changed.
-- =====================================================

DROP TRIGGER IF EXISTS trg_after_order_item_update//

CREATE TRIGGER trg_after_order_item_update
AFTER UPDATE ON ORDER_ITEM
FOR EACH ROW
BEGIN
    DECLARE v_branch_id INT;

    SELECT branch_id
    INTO v_branch_id
    FROM RESTAURANT_ORDER
    WHERE order_id = NEW.order_id;

    -- Restore the previous quantity.
    UPDATE INVENTORY I
    INNER JOIN MENU_ITEM_INGREDIENT MI
        ON I.ingredient_id = MI.ingredient_id
    SET I.quantity_available =
        I.quantity_available +
        (MI.quantity_required * OLD.quantity),
        I.last_updated = CURRENT_TIMESTAMP
    WHERE MI.item_id = OLD.item_id
      AND I.branch_id = v_branch_id;

    -- Deduct the new quantity.
    UPDATE INVENTORY I
    INNER JOIN MENU_ITEM_INGREDIENT MI
        ON I.ingredient_id = MI.ingredient_id
    SET I.quantity_available =
        I.quantity_available -
        (MI.quantity_required * NEW.quantity),
        I.last_updated = CURRENT_TIMESTAMP
    WHERE MI.item_id = NEW.item_id
      AND I.branch_id = v_branch_id;
END//


DELIMITER ;


-- =====================================================
-- SECTION 2: VERIFY TRIGGERS
-- =====================================================

SHOW TRIGGERS
WHERE `Table` = 'ORDER_ITEM';


-- =====================================================
-- SECTION 3: CHECK INVENTORY
-- =====================================================

SELECT
    I.inventory_id,
    B.branch_name,
    G.ingredient_name,
    I.quantity_available,
    G.reorder_level,
    I.last_updated
FROM INVENTORY I
INNER JOIN BRANCH B
    ON I.branch_id = B.branch_id
INNER JOIN INGREDIENT G
    ON I.ingredient_id = G.ingredient_id
ORDER BY B.branch_id, G.ingredient_name;


-- =====================================================
-- END OF PHASE 6.6
-- =====================================================
