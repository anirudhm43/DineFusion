-- =====================================================
-- DineFusion
-- PHASE 4.2: TABLE CREATION
-- MySQL 8.0.16+
-- =====================================================

USE dinefusion_db;

-- -----------------------------------------------------
-- 1. RESTAURANT
-- -----------------------------------------------------
CREATE TABLE RESTAURANT (
    restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_name VARCHAR(100) NOT NULL,
    contact_number VARCHAR(15),
    email VARCHAR(100)
);

-- -----------------------------------------------------
-- 2. CUSTOMER
-- -----------------------------------------------------
CREATE TABLE CUSTOMER (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15),
    password_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- 3. CUISINE
-- -----------------------------------------------------
CREATE TABLE CUISINE (
    cuisine_id INT AUTO_INCREMENT PRIMARY KEY,
    cuisine_name VARCHAR(60) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- -----------------------------------------------------
-- 4. MENU_CATEGORY
-- -----------------------------------------------------
CREATE TABLE MENU_CATEGORY (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(60) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- -----------------------------------------------------
-- 5. SUPPLIER
-- -----------------------------------------------------
CREATE TABLE SUPPLIER (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    address VARCHAR(255)
);

-- -----------------------------------------------------
-- 6. INGREDIENT
-- -----------------------------------------------------
CREATE TABLE INGREDIENT (
    ingredient_id INT AUTO_INCREMENT PRIMARY KEY,
    ingredient_name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(20) NOT NULL,
    reorder_level DECIMAL(10,2) NOT NULL DEFAULT 0,
    CHECK (reorder_level >= 0)
);

-- -----------------------------------------------------
-- 7. BRANCH
-- -----------------------------------------------------
CREATE TABLE BRANCH (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id INT NOT NULL,
    branch_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(60) NOT NULL,
    phone VARCHAR(15),

    CONSTRAINT fk_branch_restaurant
        FOREIGN KEY (restaurant_id)
        REFERENCES RESTAURANT(restaurant_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 8. EMPLOYEE
-- -----------------------------------------------------
CREATE TABLE EMPLOYEE (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15),
    role VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255),

    CONSTRAINT fk_employee_branch
        FOREIGN KEY (branch_id)
        REFERENCES BRANCH(branch_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 9. DINING_TABLE
-- -----------------------------------------------------
CREATE TABLE DINING_TABLE (
    table_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    table_number INT NOT NULL,
    capacity INT NOT NULL,
    table_status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',

    CONSTRAINT uq_branch_table
        UNIQUE (branch_id, table_number),

    CONSTRAINT chk_table_capacity
        CHECK (capacity > 0),

    CONSTRAINT chk_table_status
        CHECK (table_status IN
            ('AVAILABLE', 'OCCUPIED', 'RESERVED', 'MAINTENANCE')),

    CONSTRAINT fk_table_branch
        FOREIGN KEY (branch_id)
        REFERENCES BRANCH(branch_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 10. MENU_ITEM
-- -----------------------------------------------------
CREATE TABLE MENU_ITEM (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    price DECIMAL(10,2) NOT NULL,
    preparation_time INT,
    is_vegetarian BOOLEAN NOT NULL DEFAULT TRUE,
    availability_status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',

    CONSTRAINT chk_menu_price
        CHECK (price >= 0),

    CONSTRAINT chk_preparation_time
        CHECK (preparation_time IS NULL OR preparation_time >= 0),

    CONSTRAINT chk_menu_availability
        CHECK (availability_status IN ('AVAILABLE', 'UNAVAILABLE')),

    CONSTRAINT fk_menu_category
        FOREIGN KEY (category_id)
        REFERENCES MENU_CATEGORY(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 11. MENU_ITEM_CUISINE
-- Junction table: MENU_ITEM <-> CUISINE
-- -----------------------------------------------------
CREATE TABLE MENU_ITEM_CUISINE (
    item_id INT NOT NULL,
    cuisine_id INT NOT NULL,

    PRIMARY KEY (item_id, cuisine_id),

    CONSTRAINT fk_mic_item
        FOREIGN KEY (item_id)
        REFERENCES MENU_ITEM(item_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_mic_cuisine
        FOREIGN KEY (cuisine_id)
        REFERENCES CUISINE(cuisine_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- -----------------------------------------------------
-- 12. RESERVATION
-- -----------------------------------------------------
CREATE TABLE RESERVATION (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_reservation_party
        CHECK (party_size > 0),

    CONSTRAINT chk_reservation_status
        CHECK (status IN
            ('CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW')),

    CONSTRAINT fk_reservation_customer
        FOREIGN KEY (customer_id)
        REFERENCES CUSTOMER(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_reservation_table
        FOREIGN KEY (table_id)
        REFERENCES DINING_TABLE(table_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 13. DINING_SESSION
-- -----------------------------------------------------
CREATE TABLE DINING_SESSION (
    session_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NULL,
    table_id INT NOT NULL,
    reservation_id INT NULL UNIQUE,
    session_type VARCHAR(20) NOT NULL,
    check_in_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    check_out_time DATETIME NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT chk_session_type
        CHECK (session_type IN ('RESERVATION', 'WALK_IN')),

    CONSTRAINT chk_session_status
        CHECK (status IN ('ACTIVE', 'COMPLETED', 'CANCELLED')),

    CONSTRAINT chk_session_checkout
        CHECK (check_out_time IS NULL OR check_out_time >= check_in_time),

    CONSTRAINT fk_session_customer
        FOREIGN KEY (customer_id)
        REFERENCES CUSTOMER(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_session_table
        FOREIGN KEY (table_id)
        REFERENCES DINING_TABLE(table_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_session_reservation
        FOREIGN KEY (reservation_id)
        REFERENCES RESERVATION(reservation_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 14. RESTAURANT_ORDER
-- -----------------------------------------------------
CREATE TABLE RESTAURANT_ORDER (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    customer_id INT NULL,
    session_id INT NULL,
    order_type VARCHAR(20) NOT NULL,
    order_status VARCHAR(20) NOT NULL DEFAULT 'PLACED',
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    tax DECIMAL(10,2) NOT NULL DEFAULT 0,
    discount DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,

    CONSTRAINT chk_order_type
        CHECK (order_type IN ('DINE_IN', 'TAKEAWAY')),

    CONSTRAINT chk_order_status
        CHECK (order_status IN
            ('PLACED', 'PREPARING', 'READY', 'COMPLETED', 'CANCELLED')),

    CONSTRAINT chk_order_amounts
        CHECK (
            subtotal >= 0 AND
            tax >= 0 AND
            discount >= 0 AND
            total_amount >= 0
        ),

    

    CONSTRAINT fk_order_branch
        FOREIGN KEY (branch_id)
        REFERENCES BRANCH(branch_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_customer
        FOREIGN KEY (customer_id)
        REFERENCES CUSTOMER(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_order_session
        FOREIGN KEY (session_id)
        REFERENCES DINING_SESSION(session_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 15. ORDER_ITEM
-- -----------------------------------------------------
CREATE TABLE ORDER_ITEM (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_order_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_order_item_prices
        CHECK (unit_price >= 0 AND subtotal >= 0),

    CONSTRAINT fk_order_item_order
        FOREIGN KEY (order_id)
        REFERENCES RESTAURANT_ORDER(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_order_item_menu
        FOREIGN KEY (item_id)
        REFERENCES MENU_ITEM(item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 16. PAYMENT
-- -----------------------------------------------------
CREATE TABLE PAYMENT (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    transaction_reference VARCHAR(100),

    CONSTRAINT chk_payment_method
        CHECK (payment_method IN
            ('CASH', 'CARD', 'UPI', 'ONLINE')),

    CONSTRAINT chk_payment_status
        CHECK (payment_status IN
            ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')),

    CONSTRAINT chk_payment_amount
        CHECK (amount >= 0),

    CONSTRAINT fk_payment_order
        FOREIGN KEY (order_id)
        REFERENCES RESTAURANT_ORDER(order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 17. MENU_ITEM_INGREDIENT
-- Junction table: MENU_ITEM <-> INGREDIENT
-- -----------------------------------------------------
CREATE TABLE MENU_ITEM_INGREDIENT (
    item_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    quantity_required DECIMAL(10,2) NOT NULL,

    PRIMARY KEY (item_id, ingredient_id),

    CONSTRAINT chk_quantity_required
        CHECK (quantity_required > 0),

    CONSTRAINT fk_mii_item
        FOREIGN KEY (item_id)
        REFERENCES MENU_ITEM(item_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_mii_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES INGREDIENT(ingredient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 18. SUPPLIER_INGREDIENT
-- Junction table: SUPPLIER <-> INGREDIENT
-- -----------------------------------------------------
CREATE TABLE SUPPLIER_INGREDIENT (
    supplier_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    lead_time_days INT NOT NULL,

    PRIMARY KEY (supplier_id, ingredient_id),

    CONSTRAINT chk_supplier_unit_price
        CHECK (unit_price >= 0),

    CONSTRAINT chk_lead_time
        CHECK (lead_time_days >= 0),

    CONSTRAINT fk_si_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES SUPPLIER(supplier_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_si_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES INGREDIENT(ingredient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- -----------------------------------------------------
-- 19. INVENTORY
-- -----------------------------------------------------
CREATE TABLE INVENTORY (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    quantity_available DECIMAL(10,2) NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_branch_ingredient
        UNIQUE (branch_id, ingredient_id),

    CONSTRAINT chk_inventory_quantity
        CHECK (quantity_available >= 0),

    CONSTRAINT fk_inventory_branch
        FOREIGN KEY (branch_id)
        REFERENCES BRANCH(branch_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_inventory_ingredient
        FOREIGN KEY (ingredient_id)
        REFERENCES INGREDIENT(ingredient_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 20. REVIEW
-- -----------------------------------------------------
CREATE TABLE REVIEW (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    item_id INT NOT NULL,
    rating INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_review_rating
        CHECK (rating BETWEEN 1 AND 5),

    CONSTRAINT fk_review_customer
        FOREIGN KEY (customer_id)
        REFERENCES CUSTOMER(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_review_item
        FOREIGN KEY (item_id)
        REFERENCES MENU_ITEM(item_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- END OF TABLE CREATION
-- -----------------------------------------------------