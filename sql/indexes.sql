USE flashdeals;

SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS Index_Size_MB,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) AS Data_Size_MB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'flashdeals'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;


-- Composite index for deal search queries
CREATE INDEX idx_deals_status_dates 
ON deals(deal_status, start_date, end_date, discount_pct);

-- Covering index for order reporting
CREATE INDEX idx_orders_user_date_amount 
ON orders(user_id, order_date, status, amount);

-- Composite index for deal-order joins
CREATE INDEX idx_orders_deal_status 
ON orders(deal_id, status, payment_status);

-- Index for product search with stock
CREATE INDEX idx_products_active_category 
ON products(is_active, category_id, regular_price);

-- Index for review aggregations
CREATE INDEX idx_reviews_product_rating 
ON reviews(product_id, rating, review_date);

-- Composite index for audit queries
CREATE INDEX idx_audit_table_time 
ON audit_log(table_name, timestamp, action);

-- Index for session cleanup
CREATE INDEX idx_session_expires 
ON session_context(expires_at, user_id);

-- Index for notifications
-- CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read, created_at);

-- Index for merchant performance
-- CREATE INDEX idx_deals_merchant_status ON deals(merchant_id, deal_status, created_at);

-- Index for inventory tracking
CREATE INDEX idx_inventory_product_time 
ON inventory_log(product_id, changed_at, change_type);


SELECT 
    TABLE_NAME,
    INDEX_NAME,
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) AS Columns,
    INDEX_TYPE,
    NON_UNIQUE
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'flashdeals'
    AND INDEX_NAME NOT IN ('PRIMARY')
GROUP BY TABLE_NAME, INDEX_NAME, INDEX_TYPE, NON_UNIQUE
ORDER BY TABLE_NAME, INDEX_NAME;


EXPLAIN 
SELECT 
    d.deal_id,
    d.title,
    d.deal_price,
    d.discount_pct,
    p.product_name,
    m.business_name,
    (d.quantity_available - d.quantity_sold) AS remaining
FROM deals d
INNER JOIN products p ON d.product_id = p.product_id
INNER JOIN merchants m ON d.merchant_id = m.merchant_id
WHERE d.deal_status = 'active'
    AND d.start_date <= NOW()
    AND d.end_date >= NOW()
ORDER BY d.discount_pct DESC;

SET @start_time = NOW(6);

SELECT 
    d.deal_id,
    d.title,
    d.deal_price,
    d.discount_pct,
    p.product_name,
    m.business_name,
    (d.quantity_available - d.quantity_sold) AS remaining
FROM deals d
INNER JOIN products p ON d.product_id = p.product_id
INNER JOIN merchants m ON d.merchant_id = m.merchant_id
WHERE d.deal_status = 'active'
    AND d.start_date <= NOW()
    AND d.end_date >= NOW()
ORDER BY d.discount_pct DESC;

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000 AS execution_time_ms;


-- Step 9A: Run EXPLAIN
EXPLAIN
SELECT 
    o.order_id,
    o.order_date,
    d.title,
    o.amount,
    o.status
FROM orders o
INNER JOIN deals d ON o.deal_id = d.deal_id
WHERE o.user_id = 'cust-001'
ORDER BY o.order_date DESC
LIMIT 20;

EXPLAIN
SELECT 
    d.deal_id,
    d.title,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount) AS revenue
FROM deals d
LEFT JOIN orders o ON d.deal_id = o.deal_id 
    AND o.status IN ('confirmed', 'delivered')
GROUP BY d.deal_id, d.title
ORDER BY revenue DESC
LIMIT 10;

SET @start_time = NOW(6);

SELECT 
    d.deal_id,
    d.title,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount) AS revenue
FROM deals d
LEFT JOIN orders o ON d.deal_id = o.deal_id 
    AND o.status IN ('confirmed', 'delivered')
GROUP BY d.deal_id, d.title
ORDER BY revenue DESC
LIMIT 10;

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000 AS execution_time_ms;

EXPLAIN
SELECT 
    p.product_id,
    p.product_name,
    p.regular_price,
    m.business_name
FROM products p
INNER JOIN merchants m ON p.merchant_id = m.merchant_id
WHERE p.product_name LIKE '%phone%'
    AND p.is_active = TRUE
ORDER BY p.regular_price;

SET @start_time = NOW(6);

SELECT 
    p.product_id,
    p.product_name,
    p.regular_price,
    m.business_name
FROM products p
INNER JOIN merchants m ON p.merchant_id = m.merchant_id
WHERE p.product_name LIKE '%phone%'
    AND p.is_active = TRUE
ORDER BY p.regular_price;

SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000 AS execution_time_ms;


SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB,
    ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS Index_Size_MB,
    ROUND(DATA_LENGTH / 1024 / 1024, 2) AS Data_Size_MB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'flashdeals'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;
