-- =====================================================
-- FlashDeals: Sample Data
-- File: sql/04_sample_data.sql
-- Purpose: Populate tables with demo data
-- =====================================================

USE flashdeals;

-- IMPORTANT:
-- These inserts rely on your encryption triggers:
-- users.email_plain and users.phone_plain will be encrypted and nulled.

-- 1) CATEGORIES
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

-- 2) USERS
INSERT INTO users (user_id, username, password_hash, email_plain, phone_plain, user_type, account_status) VALUES
('admin-001', 'admin_john', SHA2('AdminPass123!', 256), 'john.admin@flashdeals.com', '+1234567890', 'admin', 'active'),
('admin-002', 'admin_sarah', SHA2('AdminPass123!', 256), 'sarah.admin@flashdeals.com', '+1234567891', 'admin', 'active'),
('merch-user-001', 'techstore_owner', SHA2('Merchant123!', 256), 'owner@techstore.com', '+1555000001', 'merchant', 'active'),
('merch-user-002', 'fashionhub_owner', SHA2('Merchant123!', 256), 'owner@fashionhub.com', '+1555000002', 'merchant', 'active'),
('merch-user-003', 'homegoods_owner', SHA2('Merchant123!', 256), 'owner@homegoods.com', '+1555000003', 'merchant', 'active'),
('cust-001', 'alice_wonder', SHA2('Customer123!', 256), 'alice@email.com', '+1555100001', 'customer', 'active'),
('cust-002', 'bob_builder', SHA2('Customer123!', 256), 'bob@email.com', '+1555100002', 'customer', 'active'),
('cust-003', 'charlie_brown', SHA2('Customer123!', 256), 'charlie@email.com', '+1555100003', 'customer', 'active'),
('cust-004', 'diana_prince', SHA2('Customer123!', 256), 'diana@email.com', '+1555100004', 'customer', 'active'),
('cust-005', 'edward_stark', SHA2('Customer123!', 256), 'edward@email.com', '+1555100005', 'customer', 'active');

-- Continue with your inserts:
-- 3) MERCHANTS
-- 4) PRODUCTS
-- 5) DEALS
-- 6) ORDERS
-- 7) REVIEWS
-- 8) WISHLIST
-- 9) NOTIFICATIONS
-- 10) INVENTORY LOG
-- 11) ORDER HISTORY
-- 12) DEAL METRICS
-- 13) SESSION CONTEXT
