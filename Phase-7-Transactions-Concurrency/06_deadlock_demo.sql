/*
DINEFUSION PHASE 7 - FILE 06
DEADLOCK DEMONSTRATION

Run File 01 first. Open TWO separate Workbench connections.
Do not run the entire file using Run All.
Use demo_id 1 and 2 in phase7_transaction_demo.

A deadlock is a circular wait: each transaction holds a lock
needed by the other transaction.
*/

/*
SESSION 1 - RUN FIRST
*/
-- SESSION 1
START TRANSACTION;
UPDATE phase7_transaction_demo
SET quantity = quantity + 1 WHERE demo_id = 1;
-- Session 1 holds row 1. Keep open and switch to Session 2.

/*
SESSION 2 - RUN NEXT
*/
-- SESSION 2
START TRANSACTION;
UPDATE phase7_transaction_demo
SET quantity = quantity + 1 WHERE demo_id = 2;
-- Session 2 holds row 2. Keep open and switch to Session 1.

/*
SESSION 1 - RUN NEXT
*/
-- SESSION 1
UPDATE phase7_transaction_demo
SET quantity = quantity + 1 WHERE demo_id = 2;
-- This normally waits for Session 2's row 2 lock.
-- Leave waiting; switch to Session 2.

/*
SESSION 2 - RUN LAST
*/
-- SESSION 2
UPDATE phase7_transaction_demo
SET quantity = quantity + 1 WHERE demo_id = 1;
-- This creates a circular wait.
-- InnoDB should detect the deadlock and roll back one transaction.
-- One session commonly receives error 1213.

/*
AFTER DEADLOCK:
1. Identify which session received the deadlock error.
2. InnoDB automatically rolls back the deadlock victim.
3. The surviving transaction can proceed after the wait ends.
4. In the surviving session, execute:
*/
COMMIT;

/* Check the demonstration records. */
SELECT * FROM phase7_transaction_demo
WHERE demo_id IN (1, 2) ORDER BY demo_id;

/*
If a transaction remains open, explicitly COMMIT or ROLLBACK
in that session before continuing.

VIVA:
InnoDB detects deadlocks and rolls back a victim transaction.
Applications should be prepared to retry the complete transaction.
Consistent row-access order and short transactions reduce risk.
*/
