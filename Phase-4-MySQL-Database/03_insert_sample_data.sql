-- =====================================================
-- DineFusion
-- PHASE 4.3: INSERT SAMPLE DATA
-- =====================================================

USE dinefusion_db;

-- 1. RESTAURANT
INSERT INTO RESTAURANT
(restaurant_id, restaurant_name, contact_number, email)
VALUES
(1, 'DineFusion', '9876500000', 'contact@dinefusion.com');

-- 2. CUSTOMER
INSERT INTO CUSTOMER
(customer_id, name, email, phone, password_hash)
VALUES
(1, 'Aarav Sharma', 'aarav@example.com', '9876500001', 'sample_hash_1'),
(2, 'Diya Rao', 'diya@example.com', '9876500002', 'sample_hash_2'),
(3, 'Kabir Mehta', 'kabir@example.com', '9876500003', 'sample_hash_3');

-- 3. CUISINE
INSERT INTO CUISINE
(cuisine_id, cuisine_name, description)
VALUES
(1, 'Indian', 'Indian regional dishes'),
(2, 'Italian', 'Italian dishes'),
(3, 'Chinese', 'Chinese dishes');

-- 4. MENU_CATEGORY
INSERT INTO MENU_CATEGORY
(category_id, category_name, description)
VALUES
(1, 'Starters', 'Small dishes served before the main course'),
(2, 'Main Course', 'Main meals'),
(3, 'Desserts', 'Sweet dishes'),
(4, 'Beverages', 'Drinks');

-- 5. SUPPLIER
INSERT INTO SUPPLIER
(supplier_id, supplier_name, phone, email, address)
VALUES
(1, 'Fresh Farms', '9876510001', 'fresh@farms.com', 'Bengaluru'),
(2, 'Global Foods', '9876510002', 'sales@globalfoods.com', 'Bengaluru');

-- 6. INGREDIENT
INSERT INTO INGREDIENT
(ingredient_id, ingredient_name, unit, reorder_level)
VALUES
(1, 'Rice', 'KG', 10),
(2, 'Tomato', 'KG', 5),
(3, 'Cheese', 'KG', 3),
(4, 'Flour', 'KG', 5),
(5, 'Paneer', 'KG', 4);

-- 7. BRANCH
INSERT INTO BRANCH
(branch_id, restaurant_id, branch_name, address, city, phone)
VALUES
(1, 1, 'DineFusion Central', 'MG Road', 'Bengaluru', '9876520001'),
(2, 1, 'DineFusion West', 'Vijayanagar', 'Bengaluru', '9876520002');

-- 8. EMPLOYEE
INSERT INTO EMPLOYEE
(employee_id, branch_id, name, email, phone, role, password_hash)
VALUES
(1, 1, 'Rohan Kumar', 'rohan@dinefusion.com', '9876530001', 'MANAGER', 'sample_hash_4'),
(2, 1, 'Meera Nair', 'meera@dinefusion.com', '9876530002', 'CHEF', 'sample_hash_5'),
(3, 2, 'Arjun Das', 'arjun@dinefusion.com', '9876530003', 'CASHIER', 'sample_hash_6');

-- 9. DINING_TABLE
INSERT INTO DINING_TABLE
(table_id, branch_id, table_number, capacity, table_status)
VALUES
(1, 1, 1, 2, 'AVAILABLE'),
(2, 1, 2, 4, 'OCCUPIED'),
(3, 1, 3, 6, 'AVAILABLE'),
(4, 2, 1, 4, 'AVAILABLE');

-- 10. MENU_ITEM
INSERT INTO MENU_ITEM
(item_id, category_id, item_name, description, price,
 preparation_time, is_vegetarian, availability_status)
VALUES
(1, 1, 'Paneer Tikka', 'Grilled paneer starter', 220.00, 20, TRUE, 'AVAILABLE'),
(2, 2, 'Veg Biryani', 'Aromatic vegetable rice dish', 280.00, 30, TRUE, 'AVAILABLE'),
(3, 2, 'Margherita Pizza', 'Classic cheese pizza', 350.00, 25, TRUE, 'AVAILABLE'),
(4, 3, 'Chocolate Brownie', 'Chocolate dessert', 150.00, 15, TRUE, 'AVAILABLE'),
(5, 4, 'Fresh Lime Soda', 'Fresh lime drink', 90.00, 5, TRUE, 'AVAILABLE');

-- 11. MENU_ITEM_CUISINE
INSERT INTO MENU_ITEM_CUISINE (item_id, cuisine_id)
VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 2),
(5, 1);

-- 12. RESERVATION
INSERT INTO RESERVATION
(reservation_id, customer_id, table_id, reservation_date,
 reservation_time, party_size, status)
VALUES
(1, 1, 1, '2026-11-05', '19:00:00', 2, 'CONFIRMED'),
(2, 2, 3, '2026-11-06', '20:00:00', 5, 'CONFIRMED');

-- 13. DINING_SESSION
INSERT INTO DINING_SESSION
(session_id, customer_id, table_id, reservation_id,
 session_type, check_in_time, status)
VALUES
(1, 1, 1, 1, 'RESERVATION', '2026-11-05 19:00:00', 'COMPLETED'),
(2, 2, 2, NULL, 'WALK_IN', '2026-10-31 19:30:00', 'ACTIVE');

-- 14. RESTAURANT_ORDER
INSERT INTO RESTAURANT_ORDER
(order_id, branch_id, customer_id, session_id, order_type,
 order_status, order_date, subtotal, tax, discount, total_amount)
VALUES
(1, 1, 1, 1, 'DINE_IN', 'COMPLETED',
 '2026-11-05 19:15:00', 500.00, 25.00, 0.00, 525.00),

(2, 1, 2, 2, 'DINE_IN', 'PREPARING',
 '2026-10-31 19:45:00', 370.00, 18.50, 0.00, 388.50),

(3, 2, 3, NULL, 'TAKEAWAY', 'PLACED',
 '2026-10-31 20:00:00', 350.00, 17.50, 10.00, 357.50);

-- 15. ORDER_ITEM
INSERT INTO ORDER_ITEM
(order_item_id, order_id, item_id, quantity, unit_price, subtotal)
VALUES
(1, 1, 1, 1, 220.00, 220.00),
(2, 1, 2, 1, 280.00, 280.00),
(3, 2, 2, 1, 280.00, 280.00),
(4, 2, 5, 1, 90.00, 90.00),
(5, 3, 3, 1, 350.00, 350.00);

-- 16. PAYMENT
INSERT INTO PAYMENT
(payment_id, order_id, payment_method, payment_status,
 amount, transaction_reference)
VALUES
(1, 1, 'UPI', 'SUCCESS', 525.00, 'TXN-DINE-001'),
(2, 2, 'CASH', 'PENDING', 388.50, 'TXN-DINE-002'),
(3, 3, 'CARD', 'SUCCESS', 357.50, 'TXN-DINE-003');

-- 17. MENU_ITEM_INGREDIENT
INSERT INTO MENU_ITEM_INGREDIENT
(item_id, ingredient_id, quantity_required)
VALUES
(1, 5, 0.20),
(1, 2, 0.10),
(2, 1, 0.30),
(2, 2, 0.10),
(3, 3, 0.15),
(3, 4, 0.25);

-- 18. SUPPLIER_INGREDIENT
INSERT INTO SUPPLIER_INGREDIENT
(supplier_id, ingredient_id, unit_price, lead_time_days)
VALUES
(1, 1, 60.00, 2),
(1, 2, 35.00, 1),
(2, 3, 400.00, 3),
(2, 4, 50.00, 2),
(1, 5, 300.00, 2);

-- 19. INVENTORY
INSERT INTO INVENTORY
(inventory_id, branch_id, ingredient_id, quantity_available)
VALUES
(1, 1, 1, 50.00),
(2, 1, 2, 20.00),
(3, 1, 3, 10.00),
(4, 1, 5, 15.00),
(5, 2, 1, 30.00),
(6, 2, 4, 12.00);

-- 20. REVIEW
INSERT INTO REVIEW
(review_id, customer_id, item_id, rating)
VALUES
(1, 1, 1, 5),
(2, 2, 2, 4),
(3, 3, 3, 5);

-- -----------------------------------------------------
-- END OF SAMPLE DATA INSERTION
-- -----------------------------------------------------