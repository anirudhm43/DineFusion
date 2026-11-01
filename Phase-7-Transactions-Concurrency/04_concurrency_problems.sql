/*
============================================================
DINEFUSION PHASE 7 - FILE 04: CONCURRENCY PROBLEMS
============================================================
Demonstrates:
1. Dirty read
2. Non-repeatable read
3. Phantom read
4. Lost update

IMPORTANT SETUP:
- Open TWO separate Workbench connections to the SAME server
  and dinefusion_db database. Call them SESSION 1 and SESSION 2.
- Two query tabs on one connection are NOT two sessions.
- Run SETUP once only.
- Do NOT run the entire file with Run All.
- Execute each labelled session block in the specified order.
- This file uses phase7_concurrency_demo, not INVENTORY.

============================================================
SETUP - RUN ONCE IN EITHER SESSION
============================================================
*/
USE dinefusion_db;

CREATE TABLE IF NOT EXISTS phase7_concurrency_demo (
    demo_id INT PRIMARY KEY,
    quantity INT NOT NULL,
    description VARCHAR(100)
) ENGINE=InnoDB;

DELETE FROM phase7_concurrency_demo;
INSERT INTO phase7_concurrency_demo VALUES
(1, 20, 'Demo item 1'),
(2, 30, 'Demo item 2');

SELECT * FROM phase7_concurrency_demo ORDER BY demo_id;


/*
============================================================
DEMO 1: DIRTY READ
SESSION 1 - RUN FIRST
============================================================
*/
-- SESSION 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
UPDATE phase7_concurrency_demo
SET quantity = quantity + 100 WHERE demo_id = 1;
SELECT * FROM phase7_concurrency_demo WHERE demo_id = 1;
-- Do NOT commit/rollback. Switch to Session 2.

/*
SESSION 2 - RUN AFTER SESSION 1
READ UNCOMMITTED may see the uncommitted value 120.
*/
-- SESSION 2
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM phase7_concurrency_demo WHERE demo_id = 1;
COMMIT;

/*
SESSION 1 - RUN LAST
Rollback removes the uncommitted +100 update.
*/
-- SESSION 1
ROLLBACK;
SELECT * FROM phase7_concurrency_demo WHERE demo_id = 1;


/*
============================================================
DEMO 2: NON-REPEATABLE READ
SESSION 1 - RUN FIRST
============================================================
*/
-- SESSION 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT quantity FROM phase7_concurrency_demo WHERE demo_id = 1;
-- Expected first result: 20. Keep transaction open.

/*
SESSION 2 - RUN NEXT
*/
-- SESSION 2
START TRANSACTION;
UPDATE phase7_concurrency_demo
SET quantity = quantity + 5 WHERE demo_id = 1;
COMMIT;

/*
SESSION 1 - RUN AFTER SESSION 2 COMMITS
Expected second result: 25.
*/
-- SESSION 1
SELECT quantity FROM phase7_concurrency_demo WHERE demo_id = 1;
COMMIT;

-- Restore row for next demonstration.
UPDATE phase7_concurrency_demo SET quantity = 20 WHERE demo_id = 1;


/*
============================================================
DEMO 3: PHANTOM READ
SESSION 1 - RUN FIRST
============================================================
*/
-- SESSION 1
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM phase7_concurrency_demo
WHERE quantity < 50 ORDER BY demo_id;
-- Initially two rows. Keep transaction open.

/*
SESSION 2 - RUN NEXT
*/
-- SESSION 2
START TRANSACTION;
INSERT INTO phase7_concurrency_demo
(demo_id, quantity, description)
VALUES (3, 10, 'Inserted during phantom read demonstration');
COMMIT;

/*
SESSION 1 - RUN AFTER SESSION 2 COMMITS
The repeated query should now include demo_id 3.
*/
-- SESSION 1
SELECT * FROM phase7_concurrency_demo
WHERE quantity < 50 ORDER BY demo_id;
COMMIT;

-- Remove the extra row.
DELETE FROM phase7_concurrency_demo WHERE demo_id = 3;


/*
============================================================
DEMO 4: LOST UPDATE
Initial quantity = 20.
Session 1 calculates 25 (20 + 5).
Session 2 calculates 17 (20 - 3).
Session 2 overwrites Session 1's saved value.
============================================================
*/

/* SESSION 1 - RUN FIRST */
START TRANSACTION;
SELECT quantity FROM phase7_concurrency_demo WHERE demo_id = 1;
-- Note 20. Do not update yet. Switch to Session 2.

/* SESSION 2 - RUN NEXT */
START TRANSACTION;
SELECT quantity FROM phase7_concurrency_demo WHERE demo_id = 1;
-- Also reads 20. Do not update yet.

/* SESSION 1 - RUN NEXT */
UPDATE phase7_concurrency_demo SET quantity = 25 WHERE demo_id = 1;
COMMIT;

/* SESSION 2 - RUN AFTER SESSION 1 COMMITS */
UPDATE phase7_concurrency_demo SET quantity = 17 WHERE demo_id = 1;
COMMIT;

/* Verify: 17 instead of the expected 22 demonstrates lost update. */
SELECT * FROM phase7_concurrency_demo WHERE demo_id = 1;


/*
SAFER UPDATE PATTERN:
Use arithmetic against the current database value rather than
writing a fixed value calculated from an earlier read.
Starting from 17, these updates produce 19.
*/
START TRANSACTION;
UPDATE phase7_concurrency_demo
SET quantity = quantity + 5 WHERE demo_id = 1;
UPDATE phase7_concurrency_demo
SET quantity = quantity - 3
WHERE demo_id = 1 AND quantity >= 3;
COMMIT;
SELECT * FROM phase7_concurrency_demo WHERE demo_id = 1;


/*
FINAL CLEANUP:
Run only after both sessions have finished all demonstrations
and no demo transaction remains open.
*/
UPDATE phase7_concurrency_demo
SET quantity = 20, description = 'Demo item 1'
WHERE demo_id = 1;
UPDATE phase7_concurrency_demo
SET quantity = 30, description = 'Demo item 2'
WHERE demo_id = 2;
DELETE FROM phase7_concurrency_demo WHERE demo_id NOT IN (1, 2);
SELECT * FROM phase7_concurrency_demo ORDER BY demo_id;

/*
VIVA:
Dirty read = read uncommitted data.
Non-repeatable read = same row read returns changed value.
Phantom read = repeated condition query returns a changed row set.
Lost update = one transaction overwrites another's change.
*/
