/*
DINEFUSION PHASE 7 - FILE 05
ROW LOCKING: FOR UPDATE AND FOR SHARE

Run File 01 first. Open TWO separate Workbench connections.
Execute labelled session blocks in order; do not Run All.
Uses phase7_transaction_demo, not the real INVENTORY table.
*/

/*
============================================================
DEMO A: SELECT ... FOR UPDATE
SESSION 1 - RUN FIRST
============================================================
*/
-- SESSION 1
START TRANSACTION;
SELECT * FROM phase7_transaction_demo
WHERE demo_id = 1 FOR UPDATE;
-- Keep transaction open. Switch to Session 2.

/*
SESSION 2 - RUN NEXT.
The UPDATE normally waits until Session 1 releases the lock.
*/
-- SESSION 2
START TRANSACTION;
UPDATE phase7_transaction_demo
SET quantity = quantity - 2 WHERE demo_id = 1;
-- If waiting, switch to Session 1.

/* SESSION 1 - RUN NEXT */
-- SESSION 1
COMMIT;

/* SESSION 2 - after its UPDATE proceeds */
COMMIT;

SELECT * FROM phase7_transaction_demo WHERE demo_id = 1;


/*
============================================================
DEMO B: SELECT ... FOR SHARE
SESSION 1 - RUN FIRST
============================================================
*/
-- SESSION 1
START TRANSACTION;
SELECT * FROM phase7_transaction_demo
WHERE demo_id = 1 FOR SHARE;
-- Keep transaction open. Switch to Session 2.

/*
SESSION 2 - RUN NEXT.
The UPDATE normally waits while the shared lock is held.
*/
-- SESSION 2
START TRANSACTION;
UPDATE phase7_transaction_demo
SET quantity = quantity + 5 WHERE demo_id = 1;

/* SESSION 1 - RUN NEXT */
-- SESSION 1
COMMIT;

/* SESSION 2 - after its UPDATE proceeds */
COMMIT;

SELECT * FROM phase7_transaction_demo WHERE demo_id = 1;

/* Restore test quantity after both sessions finish. */
UPDATE phase7_transaction_demo SET quantity = 20 WHERE demo_id = 1;
SELECT * FROM phase7_transaction_demo ORDER BY demo_id;

/*
VIVA:
FOR UPDATE obtains exclusive row locks for selected rows.
FOR SHARE obtains shared locks.
Locks are normally released at COMMIT or ROLLBACK.
*/
