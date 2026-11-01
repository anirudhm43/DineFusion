# DineFusion — Phase 7: Transactions and Concurrency

## Objective
Study transaction management and concurrency control using MySQL InnoDB, with examples related to restaurant operations.

## Topics
1. Transactions and ACID properties
2. START TRANSACTION, COMMIT and ROLLBACK
3. SAVEPOINT and partial rollback
4. Isolation levels: READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE
5. Dirty read, non-repeatable read, phantom read and lost update
6. Row locking: SELECT ... FOR UPDATE and SELECT ... FOR SHARE
7. Deadlocks, detection and prevention
8. Transaction verification

## Requirements
- MySQL 8.x
- MySQL Workbench
- InnoDB storage engine
- Existing database: dinefusion_db

## Files and execution order

| File | Description |
|---|---|
| 01_transaction_commit_rollback.sql | Transaction, COMMIT and ROLLBACK |
| 02_savepoints.sql | SAVEPOINT and partial rollback |
| 03_isolation_levels.sql | Set and inspect isolation levels |
| 04_concurrency_problems.sql | Dirty read, non-repeatable read, phantom read and lost update |
| 05_row_locking.sql | FOR UPDATE and FOR SHARE |
| 06_deadlock_demo.sql | Controlled deadlock |
| 07_transaction_testing.sql | Verify engine, isolation, autocommit and data |

Recommended order: 01 → 02 → 03 → 04 → 05 → 06 → 07.

## Important execution instructions
- Files 04, 05 and 06 require TWO separate Workbench connections to the same MySQL server and database.
- Two query tabs on one connection are not two independent sessions.
- Do not use Run All for the multi-session demonstrations.
- Follow the SESSION 1 / SESSION 2 comments in each file.
- Do not leave transactions open. Finish them using COMMIT or ROLLBACK.
- Run setup sections only once.
- Demo tables `phase7_transaction_demo` and `phase7_concurrency_demo` are separate from the original DineFusion business tables.
- Run on a development database, not production.

## DineFusion use cases
- Place an order and its order items as one logical operation.
- Deduct inventory safely.
- Prevent overselling when customers order simultaneously.
- Keep order and payment changes consistent.
- Handle simultaneous staff updates.

## ACID
- Atomicity: all operations succeed together or are rolled back.
- Consistency: committed changes preserve database rules.
- Isolation: concurrent transactions are controlled.
- Durability: committed changes persist according to database durability settings.

## Integration note
Phase 6 inventory triggers deduct stock when order items are inserted. The backend must not deduct the same stock a second time. Before application integration, define when stock is deducted, how cancellations restore it, and how order, inventory and payment operations are coordinated in one transaction.
