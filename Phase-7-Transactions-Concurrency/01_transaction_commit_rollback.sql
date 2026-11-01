/*
DINEFUSION PHASE 7 - FILE 01
TRANSACTIONS, COMMIT AND ROLLBACK

Run this complete file in ONE connection.
Uses a separate demo table, not the original project tables.
Requires MySQL 8 and InnoDB.
*/
USE dinefusion_db;

CREATE TABLE IF NOT EXISTS phase7_transaction_demo (
    demo_id INT PRIMARY KEY,
    quantity INT NOT NULL,
    description VARCHAR(100)
) ENGINE=InnoDB;

DELETE FROM phase7_transaction_demo;
INSERT INTO phase7_transaction_demo VALUES
(1, 20, 'COMMIT and ROLLBACK demo'),
(2, 30, 'Second demo record');

SELECT * FROM phase7_transaction_demo ORDER BY demo_id;

-- DEMO 1: ROLLBACK cancels an uncommitted change.
START TRANSACTION;
UPDATE phase7_transaction_demo SET quantity = quantity + 10 WHERE demo_id = 1;
SELECT * FROM phase7_transaction_demo WHERE demo_id = 1;
ROLLBACK;
-- Expected quantity: 20
SELECT * FROM phase7_transaction_demo WHERE demo_id = 1;

-- DEMO 2: COMMIT saves the change.
START TRANSACTION;
UPDATE phase7_transaction_demo SET quantity = quantity + 5 WHERE demo_id = 1;
COMMIT;
-- Expected quantity: 25
SELECT * FROM phase7_transaction_demo WHERE demo_id = 1;

-- Restore original demo value.
START TRANSACTION;
UPDATE phase7_transaction_demo SET quantity = 20 WHERE demo_id = 1;
COMMIT;
SELECT * FROM phase7_transaction_demo ORDER BY demo_id;

/*
VIVA:
START TRANSACTION begins; COMMIT saves; ROLLBACK cancels
uncommitted changes. InnoDB supports transactions.
*/
