-- =====================================================
-- DineFusion
-- PHASE 4.4: UPDATE AND DELETE OPERATIONS
-- =====================================================

USE dinefusion_db;

-- -----------------------------------------------------
-- UPDATE EXAMPLE 1:
-- Update a customer's phone number
-- -----------------------------------------------------
UPDATE CUSTOMER
SET phone = '9999900001'
WHERE customer_id = 1;

-- Verify the update
SELECT customer_id, name, phone
FROM CUSTOMER
WHERE customer_id = 1;


-- -----------------------------------------------------
-- UPDATE EXAMPLE 2:
-- Update a menu item's price
-- -----------------------------------------------------
UPDATE MENU_ITEM
SET price = 240.00
WHERE item_id = 1;

-- Verify the update
SELECT item_id, item_name, price
FROM MENU_ITEM
WHERE item_id = 1;


-- -----------------------------------------------------
-- UPDATE EXAMPLE 3:
-- Update inventory quantity
-- -----------------------------------------------------
UPDATE INVENTORY
SET quantity_available = quantity_available + 5
WHERE branch_id = 1
  AND ingredient_id = 1;

-- Verify the update
SELECT *
FROM INVENTORY
WHERE branch_id = 1
  AND ingredient_id = 1;


-- -----------------------------------------------------
-- DELETE EXAMPLE:
-- Insert a temporary customer and delete that record
-- -----------------------------------------------------

START TRANSACTION;

INSERT INTO CUSTOMER
(name, email, phone, password_hash)
VALUES
('Temporary Test Customer',
 'temporary@example.com',
 '9000000000',
 'temporary_hash');

-- Store the newly generated customer ID
SET @temp_customer_id = LAST_INSERT_ID();

-- Verify the temporary customer
SELECT *
FROM CUSTOMER
WHERE customer_id = @temp_customer_id;

-- Delete the temporary customer using its primary key
DELETE FROM CUSTOMER
WHERE customer_id = @temp_customer_id;

COMMIT;

-- Confirm deletion
SELECT *
FROM CUSTOMER
WHERE email = 'temporary@example.com';

-- -----------------------------------------------------
-- END OF UPDATE AND DELETE OPERATIONS
-- -----------------------------------------------------