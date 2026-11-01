/*
DINEFUSION PHASE 7 - FILE 03
TRANSACTION ISOLATION LEVELS

Run File 01 first. Run this complete file in ONE connection.
The concurrent effects are demonstrated in File 04.
*/
USE dinefusion_db;

SELECT @@transaction_isolation AS current_isolation_level;

-- READ UNCOMMITTED
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM phase7_transaction_demo WHERE demo_id = 1;
COMMIT;

-- READ COMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM phase7_transaction_demo WHERE demo_id = 1;
COMMIT;

-- REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM phase7_transaction_demo WHERE demo_id = 1;
COMMIT;

-- SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM phase7_transaction_demo WHERE demo_id = 1;
COMMIT;

SELECT @@transaction_isolation AS current_isolation_level;

/*
VIVA:
READ UNCOMMITTED may allow dirty reads.
READ COMMITTED prevents dirty reads.
REPEATABLE READ provides a consistent snapshot for ordinary
consistent reads within a transaction.
SERIALIZABLE is the strongest standard isolation level.
InnoDB commonly defaults to REPEATABLE READ.
SET TRANSACTION applies to the next transaction.
*/
