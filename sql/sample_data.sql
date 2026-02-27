USE flashdeals;
-- =====================================================
-- 1. INSERT CATEGORIES (10 categories)
-- =====================================================

INSERT INTO categories (category_id, category_name, parent_category_id, description, is_active) VALUES
(1, 'Electronics', NULL, 'Electronic devices and accessories', TRUE),
(2, 'Fashion', NULL, 'Clothing and accessories', TRUE),
(3, 'Home & Garden', NULL, 'Home improvement and garden supplies', TRUE),
(4, 'Sports', NULL, 'Sports equipment and outdoor gear', TRUE),
(5, 'Books', NULL, 'Books and media', TRUE),
(6, 'Smartphones', 1, 'Mobile phones', TRUE),
(7, 'Laptops', 1, 'Laptop computers', TRUE),
(8, 'Mens Fashion', 2, 'Mens clothing', TRUE),
(9, 'Womens Fashion', 2, 'Womens clothing', TRUE),
(10, 'Fitness', 4, 'Fitness equipment', TRUE);

COMMIT;

-- =====================================================
-- 2. INSERT USERS (10 users: 2 admins, 3 merchants, 5 customers)
-- =====================================================

-- Admin users (2)
INSERT INTO users (user_id, username, password_hash, email_plain, phone_plain, user_type, account_status) VALUES
('admin-001', 'admin_john', SHA2('AdminPass123!', 256), 'john.admin@flashdeals.com', '+1234567890', 'admin', 'active'),
('admin-002', 'admin_sarah', SHA2('AdminPass123!', 256), 'sarah.admin@flashdeals.com', '+1234567891', 'admin', 'active');

-- Merchant users (3)
INSERT INTO users (user_id, username, password_hash, email_plain, phone_plain, user_type, account_status) VALUES
('merch-user-001', 'techstore_owner', SHA2('Merchant123!', 256), 'owner@techstore.com', '+1555000001', 'merchant', 'active'),
('merch-user-002', 'fashionhub_owner', SHA2('Merchant123!', 256), 'owner@fashionhub.com', '+1555000002', 'merchant', 'active'),
('merch-user-003', 'homegoods_owner', SHA2('Merchant123!', 256), 'owner@homegoods.com', '+1555000003', 'merchant', 'active');

-- Customer users (5)
INSERT INTO users (user_id, username, password_hash, email_plain, phone_plain, user_type, account_status) VALUES
('cust-001', 'alice_wonder', SHA2('Customer123!', 256), 'alice@email.com', '+1555100001', 'customer', 'active'),
('cust-002', 'bob_builder', SHA2('Customer123!', 256), 'bob@email.com', '+1555100002', 'customer', 'active'),
('cust-003', 'charlie_brown', SHA2('Customer123!', 256), 'charlie@email.com', '+1555100003', 'customer', 'active'),
('cust-004', 'diana_prince', SHA2('Customer123!', 256), 'diana@email.com', '+1555100004', 'customer', 'active'),
('cust-005', 'edward_stark', SHA2('Customer123!', 256), 'edward@email.com', '+1555100005', 'customer', 'active');

COMMIT;

-- =====================================================
-- 3. INSERT MERCHANTS (3 merchants)
-- =====================================================

INSERT INTO merchants (merchant_id, user_id, business_name, business_email, business_phone, address, verification_status, rating, total_sales) VALUES
('merch-001', 'merch-user-001', 'TechStore Electronics', 'contact@techstore.com', '+1555000001', '123 Tech Street, Silicon Valley, CA 94025', 'verified', 4.75, 125000.00),
('merch-002', 'merch-user-002', 'Fashion Hub', 'contact@fashionhub.com', '+1555000002', '456 Fashion Ave, New York, NY 10001', 'verified', 4.60, 89000.00),
('merch-003', 'merch-user-003', 'HomeGoods Plus', 'contact@homegoods.com', '+1555000003', '789 Home Blvd, Austin, TX 78701', 'verified', 4.80, 156000.00);

COMMIT;

-- =====================================================
-- 4. INSERT PRODUCTS (10 products)
-- =====================================================

INSERT INTO products (product_id, merchant_id, category_id, product_name, description, regular_price, stock_quantity, is_active) VALUES
('prod-001', 'merch-001', 6, 'iPhone 15 Pro Max', 'Latest Apple flagship smartphone', 1199.99, 150, TRUE),
('prod-002', 'merch-001', 7, 'MacBook Pro 16"', 'Professional laptop with M3 chip', 2499.99, 80, TRUE),
('prod-003', 'merch-001', 1, 'Sony WH-1000XM5', 'Premium noise-cancelling headphones', 399.99, 250, TRUE),
('prod-004', 'merch-001', 1, 'iPad Air M2', 'Versatile tablet', 599.99, 200, TRUE),
('prod-005', 'merch-002', 8, 'Levi\'s 501 Jeans', 'Classic straight-fit jeans', 79.99, 500, TRUE),
('prod-006', 'merch-002', 9, 'Zara Summer Dress', 'Elegant floral dress', 59.99, 450, TRUE),
('prod-007', 'merch-002', 2, 'Nike Air Max Sneakers', 'Comfortable athletic shoes', 129.99, 400, TRUE),
('prod-008', 'merch-003', 3, 'KitchenAid Stand Mixer', 'Professional mixer', 379.99, 200, TRUE),
('prod-009', 'merch-003', 3, 'Dyson V15 Vacuum', 'Cordless stick vacuum', 699.99, 180, TRUE),
('prod-010', 'merch-003', 3, 'Instant Pot Duo', 'Multi-function pressure cooker', 99.99, 350, TRUE);

COMMIT;

-- =====================================================
-- 5. INSERT DEALS (10 deals: mix of active, upcoming, expired)
-- =====================================================

INSERT INTO deals (deal_id, product_id, merchant_id, title, description, original_price, deal_price, quantity_available, quantity_sold, start_date, end_date, deal_status) VALUES
-- Active deals (5)
('deal-001', 'prod-001', 'merch-001', 'iPhone 15 Flash Sale', '20% off latest iPhone', 1199.99, 959.99, 100, 45, '2025-12-01 00:00:00', '2025-12-15 23:59:59', 'active'),
('deal-002', 'prod-003', 'merch-001', 'Sony Headphones Deal', 'Save $100 on premium audio', 399.99, 299.99, 150, 78, '2025-12-03 00:00:00', '2025-12-10 23:59:59', 'active'),
('deal-003', 'prod-005', 'merch-002', 'Levi\'s Jeans Blowout', '30% off classic jeans', 79.99, 55.99, 200, 112, '2025-12-01 00:00:00', '2025-12-12 23:59:59', 'active'),
('deal-004', 'prod-008', 'merch-003', 'KitchenAid Deal', 'Premium mixer $80 off', 379.99, 299.99, 100, 67, '2025-12-05 00:00:00', '2025-12-18 23:59:59', 'active'),
('deal-005', 'prod-009', 'merch-003', 'Dyson Vacuum Sale', '$200 off cordless vacuum', 699.99, 499.99, 80, 34, '2025-12-04 00:00:00', '2025-12-14 23:59:59', 'active'),

-- Upcoming deals (3)
('deal-006', 'prod-002', 'merch-001', 'MacBook Pro Holiday Sale', 'Huge discount on laptops', 2499.99, 2099.99, 50, 0, '2025-12-20 00:00:00', '2025-12-31 23:59:59', 'upcoming'),
('deal-007', 'prod-006', 'merch-002', 'New Year Fashion Deal', 'Dress clearance event', 59.99, 39.99, 150, 0, '2025-12-25 00:00:00', '2026-01-05 23:59:59', 'upcoming'),
('deal-008', 'prod-010', 'merch-003', 'Instant Pot Special', '50% off pressure cooker', 99.99, 49.99, 200, 0, '2025-12-18 00:00:00', '2025-12-24 23:59:59', 'upcoming'),

-- Expired deals (2)
('deal-009', 'prod-004', 'merch-001', 'iPad Black Friday', 'Limited time iPad sale', 599.99, 499.99, 120, 120, '2025-11-20 00:00:00', '2025-11-30 23:59:59', 'soldout'),
('deal-010', 'prod-007', 'merch-002', 'Nike Cyber Monday', 'Athletic shoes discount', 129.99, 89.99, 100, 87, '2025-11-25 00:00:00', '2025-12-02 23:59:59', 'expired');

COMMIT;

-- =====================================================
-- 6. INSERT ORDERS (10 orders with various statuses)
-- =====================================================

INSERT INTO orders (order_id, user_id, deal_id, order_date, quantity, unit_price, status, payment_method, payment_status, shipping_address) VALUES
('order-001', 'cust-001', 'deal-001', '2025-12-02 10:30:00', 1, 959.99, 'delivered', 'credit_card', 'completed', '123 Main St, Boston, MA 02101'),
('order-002', 'cust-002', 'deal-002', '2025-12-03 14:15:00', 2, 299.99, 'shipped', 'paypal', 'completed', '456 Oak Ave, Seattle, WA 98101'),
('order-003', 'cust-003', 'deal-003', '2025-12-04 09:20:00', 1, 55.99, 'processing', 'debit_card', 'completed', '789 Elm St, Austin, TX 78701'),
('order-004', 'cust-004', 'deal-004', '2025-12-05 16:45:00', 1, 299.99, 'confirmed', 'credit_card', 'completed', '321 Pine Rd, Denver, CO 80201'),
('order-005', 'cust-005', 'deal-005', '2025-12-05 11:00:00', 1, 499.99, 'pending', 'wallet', 'pending', '654 Maple Dr, Portland, OR 97201'),
('order-006', 'cust-001', 'deal-003', '2025-12-02 13:30:00', 3, 55.99, 'delivered', 'credit_card', 'completed', '123 Main St, Boston, MA 02101'),
('order-007', 'cust-002', 'deal-001', '2025-12-03 08:45:00', 1, 959.99, 'cancelled', 'paypal', 'refunded', '456 Oak Ave, Seattle, WA 98101'),
('order-008', 'cust-003', 'deal-009', '2025-11-28 15:20:00', 1, 499.99, 'delivered', 'credit_card', 'completed', '789 Elm St, Austin, TX 78701'),
('order-009', 'cust-004', 'deal-010', '2025-11-30 10:15:00', 2, 89.99, 'delivered', 'debit_card', 'completed', '321 Pine Rd, Denver, CO 80201'),
('order-010', 'cust-005', 'deal-002', '2025-12-04 17:30:00', 1, 299.99, 'shipped', 'credit_card', 'completed', '654 Maple Dr, Portland, OR 97201');

COMMIT;

-- =====================================================
-- 7. INSERT REVIEWS (10 reviews)
-- =====================================================

INSERT INTO reviews (order_id, user_id, product_id, merchant_id, rating, review_text, is_verified_purchase) VALUES
('order-001', 'cust-001', 'prod-001', 'merch-001', 5, 'Amazing phone! The camera quality is outstanding.', TRUE),
('order-002', 'cust-002', 'prod-003', 'merch-001', 4, 'Great headphones, noise cancellation works well.', TRUE),
('order-003', 'cust-003', 'prod-005', 'merch-002', 5, 'Perfect fit! Classic jeans that never go out of style.', TRUE),
('order-004', 'cust-004', 'prod-008', 'merch-003', 5, 'Best mixer ever! Makes baking so much easier.', TRUE),
('order-006', 'cust-001', 'prod-005', 'merch-002', 4, 'Good quality jeans, bought 3 pairs.', TRUE),
('order-008', 'cust-003', 'prod-004', 'merch-001', 5, 'iPad is perfect for work and entertainment.', TRUE),
('order-009', 'cust-004', 'prod-007', 'merch-002', 4, 'Comfortable sneakers, great for running.', TRUE),
('order-010', 'cust-005', 'prod-003', 'merch-001', 5, 'Sound quality is incredible, worth every penny.', TRUE),
('order-001', 'cust-001', 'prod-001', 'merch-001', 5, 'Fast shipping and great customer service!', TRUE),
('order-002', 'cust-002', 'prod-003', 'merch-001', 4, 'Second pair for my wife, she loves them too.', TRUE);

COMMIT;

-- =====================================================
-- 8. INSERT WISHLIST (10 entries)
-- =====================================================

INSERT INTO wishlist (user_id, product_id, notify_on_deal) VALUES
('cust-001', 'prod-002', TRUE),
('cust-001', 'prod-009', TRUE),
('cust-002', 'prod-004', TRUE),
('cust-002', 'prod-008', FALSE),
('cust-003', 'prod-007', TRUE),
('cust-003', 'prod-010', TRUE),
('cust-004', 'prod-001', TRUE),
('cust-004', 'prod-006', FALSE),
('cust-005', 'prod-002', TRUE),
('cust-005', 'prod-005', FALSE);

COMMIT;

-- =====================================================
-- 9. INSERT NOTIFICATIONS (10 notifications)
-- =====================================================

INSERT INTO notifications (user_id, notification_type, title, message, is_read) VALUES
('cust-001', 'deal_alert', 'iPhone Flash Sale Live!', 'Your wishlist item iPhone 15 is now on sale at 20% off', FALSE),
('cust-001', 'order_update', 'Order Delivered', 'Your order #order-001 has been delivered', TRUE),
('cust-002', 'deal_alert', 'Headphones Deal Starting', 'Sony WH-1000XM5 flash sale begins in 1 hour', FALSE),
('cust-002', 'order_update', 'Order Shipped', 'Your order #order-002 is on the way', TRUE),
('cust-003', 'price_drop', 'Price Drop Alert', 'Levis Jeans price dropped to $55.99', TRUE),
('cust-003', 'order_update', 'Order Confirmed', 'Your order #order-003 is being processed', FALSE),
('cust-004', 'deal_alert', 'Kitchen Deal Live', 'KitchenAid mixer on sale now', FALSE),
('cust-004', 'system', 'Welcome to FlashDeals', 'Thank you for joining our community', TRUE),
('cust-005', 'deal_alert', 'Vacuum Sale Alert', 'Dyson vacuum 30% off today only', FALSE),
('cust-005', 'order_update', 'Payment Pending', 'Please complete payment for order #order-005', FALSE);

COMMIT;

-- =====================================================
-- 10. INSERT INVENTORY LOGS (10 entries)
-- =====================================================

INSERT INTO inventory_log (product_id, deal_id, change_type, quantity_change, quantity_before, quantity_after, reason, changed_by) VALUES
('prod-001', 'deal-001', 'sale', -45, 150, 105, 'Flash sale orders', 'merch-user-001'),
('prod-003', 'deal-002', 'sale', -78, 250, 172, 'Deal orders processed', 'merch-user-001'),
('prod-005', 'deal-003', 'sale', -112, 500, 388, 'Jeans flash sale', 'merch-user-002'),
('prod-008', 'deal-004', 'sale', -67, 200, 133, 'Mixer deal orders', 'merch-user-003'),
('prod-001', NULL, 'restock', 50, 105, 155, 'New inventory received', 'merch-user-001'),
('prod-002', NULL, 'restock', 30, 80, 110, 'Restocking laptops', 'merch-user-001'),
('prod-006', NULL, 'adjustment', -5, 450, 445, 'Damaged items removed', 'merch-user-002'),
('prod-009', 'deal-005', 'sale', -34, 180, 146, 'Vacuum cleaner sales', 'merch-user-003'),
('prod-004', 'deal-009', 'sale', -120, 200, 80, 'Black Friday sold out', 'merch-user-001'),
('prod-010', NULL, 'restock', 100, 350, 450, 'Bulk restock', 'merch-user-003');

COMMIT;

-- =====================================================
-- 11. INSERT ORDER HISTORY (10 archived orders for partitioning test)
-- =====================================================

INSERT INTO order_history (order_id, user_id, deal_id, order_date, amount, status) VALUES
('hist-001', 'cust-001', 'deal-009', '2023-11-15 10:00:00', 499.99, 'delivered'),
('hist-002', 'cust-002', 'deal-009', '2023-11-20 14:30:00', 499.99, 'delivered'),
('hist-003', 'cust-003', 'deal-010', '2024-03-10 09:15:00', 89.99, 'delivered'),
('hist-004', 'cust-004', 'deal-010', '2024-06-22 16:45:00', 179.98, 'delivered'),
('hist-005', 'cust-005', 'deal-009', '2024-08-05 11:20:00', 499.99, 'delivered'),
('hist-006', 'cust-001', 'deal-010', '2024-09-12 13:00:00', 89.99, 'delivered'),
('hist-007', 'cust-002', 'deal-009', '2024-11-25 10:30:00', 999.98, 'delivered'),
('hist-008', 'cust-003', 'deal-010', '2025-01-08 15:15:00', 89.99, 'delivered'),
('hist-009', 'cust-004', 'deal-009', '2025-02-14 12:00:00', 499.99, 'delivered'),
('hist-010', 'cust-005', 'deal-010', '2025-03-20 14:45:00', 179.98, 'delivered');

COMMIT;

-- =====================================================
-- 12. INSERT DEAL METRICS (10 metrics entries)
-- =====================================================

INSERT INTO deal_metrics (deal_id, metric_date, views_count, clicks_count, orders_count, revenue) VALUES
('deal-001', '2025-12-01', 5000, 1200, 15, 14399.85),
('deal-001', '2025-12-02', 4500, 1100, 18, 17279.82),
('deal-001', '2025-12-03', 3800, 950, 12, 11519.88),
('deal-002', '2025-12-03', 3200, 800, 25, 7499.75),
('deal-002', '2025-12-04', 2900, 750, 30, 8999.70),
('deal-003', '2025-12-01', 4200, 1000, 40, 2239.60),
('deal-003', '2025-12-02', 3900, 920, 45, 2519.55),
('deal-004', '2025-12-05', 2800, 700, 35, 10499.65),
('deal-005', '2025-12-04', 2500, 600, 20, 9999.80),
('deal-009', '2025-11-28', 8000, 2000, 120, 59999.00);

COMMIT;

-- =====================================================
-- 13. CREATE SAMPLE SESSIONS (for testing row-level security)
-- =====================================================

INSERT INTO session_context (session_id, user_id, merchant_id, role, expires_at, ip_address) VALUES
('session-001', 'cust-001', NULL, 'customer', DATE_ADD(NOW(), INTERVAL 2 HOUR), '192.168.1.100'),
('session-002', 'cust-002', NULL, 'customer', DATE_ADD(NOW(), INTERVAL 2 HOUR), '192.168.1.101'),
('session-003', 'merch-user-001', 'merch-001', 'merchant', DATE_ADD(NOW(), INTERVAL 2 HOUR), '192.168.1.102'),
('session-004', 'merch-user-002', 'merch-002', 'merchant', DATE_ADD(NOW(), INTERVAL 2 HOUR), '192.168.1.103'),
('session-005', 'admin-001', NULL, 'admin', DATE_ADD(NOW(), INTERVAL 4 HOUR), '192.168.1.104');

COMMIT;
