# DineFusion – Multi-Cuisine Restaurant Intelligence and Management System

## Project Overview

DineFusion is a DBMS mini-project designed to manage and analyze the operations of a multi-cuisine restaurant brand with multiple branches.

The system focuses on restaurant operations such as customer management, employee management, table reservations, dining sessions, menu management, orders, payments, inventory, suppliers, and customer reviews.

The project demonstrates database design, relational database implementation, SQL operations, advanced database concepts, NoSQL technologies, and web application integration.

## Project Objectives

- Design a normalized relational database for restaurant management.
- Manage restaurant branches, customers, employees, and dining tables.
- Handle reservations, dining sessions, orders, and payments.
- Maintain menu items, cuisines, ingredients, suppliers, and inventory.
- Store and manage customer reviews.
- Apply SQL queries, constraints, joins, subqueries, functions, procedures, and triggers.
- Explore NoSQL databases, graph databases, caching, and vector search.
- Develop a web application integrated with the database.

## Technology Stack

| Component | Technology |
|---|---|
| Relational Database | MySQL |
| Database Management Tool | MySQL Workbench |
| Graph Database | Neo4j |
| In-memory Database / Cache | Redis |
| Document Database | MongoDB |
| Vector Database | To be finalized |
| Frontend | Next.js |
| Version Control | Git and GitHub |

*Technologies will be integrated progressively as the project develops.*

## Project Structure

```text
DineFusion/
│
├── Phase-1-Requirement-Analysis/
│   └── Phase 1 requirement analysis document
│
├── Phase-2-Database-Design/
│   ├── Chen ER Diagram (.drawio / .png)
│   ├── Relational Schema (.mmd / .png / .pdf)
│   ├── Data Dictionary (.xlsx)
│   ├── Normalization Notes
│   └── ER Relationships and Cardinalities
│
├── Phase-3-Normalization/
│   └── Normalization_Report.docx
│
├── Phase-4-MySQL-Database/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_sample_data.sql
│   ├── 04_update_delete.sql
│   └── 05_verification_queries.sql
│
├── Phase-5-Advanced-SQL/
│   └── To be added
│
├── Documentation/
│   └── Phase progress documentation
│
└── README.md
```

## Project Development Progress

### Phase 1 – Requirement Analysis

**Status: Completed**

- Defined the project scope and objectives.
- Identified the main entities and functional requirements.
- Established the restaurant management system requirements.

### Phase 2 – Database Design

**Status: Completed**

- Designed the conceptual ER diagram.
- Identified entities, attributes, relationships, and cardinalities.
- Converted the ER model into a relational schema.
- Prepared the data dictionary.
- Documented entity relationships and assumptions.

### Phase 3 – Database Normalization

**Status: Completed**

- Analyzed the relational schema.
- Documented functional dependencies.
- Evaluated relations against 1NF, 2NF, 3NF, and BCNF.
- Prepared the normalization report.

### Phase 4 – MySQL Database Implementation

**Status: Completed**

- Created the `dinefusion_db` database.
- Implemented 20 relational tables.
- Defined primary keys, foreign keys, unique constraints, and check constraints.
- Inserted sample data into the tables.
- Practiced SQL INSERT, UPDATE, and DELETE operations.
- Prepared database verification queries.
- Tested joins and aggregate queries.

### Phase 5 – Advanced SQL

**Status: Planned / In Progress**

Planned topics:

- Inner, left, right, and other joins.
- Nested and correlated subqueries.
- Aggregate and scalar functions.
- Views.
- Common Table Expressions (CTEs).
- Window functions.
- Stored procedures and functions.
- Triggers.

### Phase 6 – Transactions and Concurrency Control

**Status: Planned**

- Transaction management.
- ACID properties.
- Transaction isolation levels.
- Concurrency control and locking.

### Phase 7 – NoSQL and Vector Database Integration

**Status: Planned**

- MongoDB document storage.
- Neo4j graph database implementation.
- Redis caching and data operations.
- Vector database and semantic search.

### Phase 8 – Web Application Development

**Status: Planned**

- Next.js frontend.
- Backend and MySQL integration.
- NoSQL database integration.
- Authentication and authorization.
- Restaurant management features.

### Phase 9 – Testing and Documentation

**Status: Planned**

- Database testing.
- Application testing.
- Documentation.
- Final project demonstration.

## Database Overview

The current MySQL implementation contains 20 tables:

1. RESTAURANT
2. BRANCH
3. CUSTOMER
4. EMPLOYEE
5. DINING_TABLE
6. RESERVATION
7. DINING_SESSION
8. RESTAURANT_ORDER
9. ORDER_ITEM
10. PAYMENT
11. CUISINE
12. MENU_CATEGORY
13. MENU_ITEM
14. MENU_ITEM_CUISINE
15. INGREDIENT
16. MENU_ITEM_INGREDIENT
17. SUPPLIER
18. SUPPLIER_INGREDIENT
19. INVENTORY
20. REVIEW

The database uses primary keys, foreign keys, composite keys, unique constraints, and check constraints to maintain data integrity.

## How to Run the MySQL Database

1. Install and open MySQL Workbench.
2. Connect to your local MySQL server.
3. Open the SQL files in `Phase-4-MySQL-Database/`.
4. Execute the scripts in the following order:

   - `01_create_database.sql`
   - `02_create_tables.sql`
   - `03_insert_sample_data.sql`
   - `04_update_delete.sql`
   - `05_verification_queries.sql`

5. Verify the database and table records using the verification queries.

**Note:** Run the setup and sample-data scripts on a clean database for the initial setup. Do not repeatedly execute the sample-data insertion script because it uses fixed IDs.

## Repository

GitHub: https://github.com/anirudhm43/DineFusion

## Project Note

This is an academic DBMS mini-project. The implementation is being developed phase by phase, with database design and MySQL implementation completed before moving to advanced SQL, NoSQL technologies, and web application development.