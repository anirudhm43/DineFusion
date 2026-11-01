/*
DINEFUSION PHASE 7 - FILE 02
SAVEPOINT AND PARTIAL ROLLBACK

Run File 01 first. Run this complete file in ONE connection.
Final ROLLBACK restores the original demo data.
*/
USE dinefusion_db;

SELECT * FROM phase7_transaction_demo ORDER BY demo_id;

START TRANSACTION;

-- First change.
UPDATE phase7_transaction_demo SET quantity = quantity + 10 WHERE demo_id = 1;

-- Mark the point to which we may roll back.
SAVEPOINT after_first_update;

-- These changes will be undone.
UPDATE phase7_transaction_demo SET quantity = quantity + 20 WHERE demo_id = 2;
UPDATE phase7_transaction_demo
SET description = 'Temporary description'
WHERE demo_id = 1;

SELECT * FROM phase7_transaction_demo ORDER BY demo_id;

-- Undo only changes made after the savepoint.
ROLLBACK TO SAVEPOINT after_first_update;

-- Expected: row 1 quantity 30; row 2 quantity 30.
SELECT * FROM phase7_transaction_demo ORDER BY demo_id;

-- Roll back the entire transaction to preserve original demo data.
ROLLBACK;
SELECT * FROM phase7_transaction_demo ORDER BY demo_id;

/*
VIVA:
SAVEPOINT marks a point inside a transaction.
ROLLBACK TO SAVEPOINT undoes later changes but does not end
the transaction. COMMIT or full ROLLBACK ends the transaction.
*/
