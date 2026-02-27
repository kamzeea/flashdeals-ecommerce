USE flashdeals;

-- 1) USERS
CREATE TABLE users (
  user_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  email_plain VARCHAR(100),
  email_encrypted BLOB,
  phone_plain VARCHAR(20),
  phone_encrypted BLOB,
  user_type ENUM('customer', 'merchant', 'admin') NOT NULL DEFAULT 'customer',
  account_status ENUM('active', 'suspended', 'locked') DEFAULT 'active',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login DATETIME,
  INDEX idx_username (username),
  INDEX idx_user_type (user_type),
  INDEX idx_account_status (account_status)
) ENGINE=InnoDB;

-- 2) LOGIN AUDIT
CREATE TABLE login_audit (
  audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  login_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  ip_address VARCHAR(45),
  success BOOLEAN NOT NULL,
  failure_reason VARCHAR(255),
  INDEX idx_user_login (user_id, login_time),
  INDEX idx_login_time (login_time),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3) ACCOUNT LOCKOUT
CREATE TABLE account_lock (
  user_id CHAR(36) PRIMARY KEY,
  failed_attempts INT DEFAULT 0,
  locked_until DATETIME NULL,
  last_attempt DATETIME,
  INDEX idx_locked_until (locked_until),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4) SESSION CONTEXT
CREATE TABLE session_context (
  session_id CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  merchant_id CHAR(36),
  role ENUM('customer', 'merchant', 'admin', 'analyst') NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  expires_at DATETIME NOT NULL,
  ip_address VARCHAR(45),
  INDEX idx_user_session (user_id),
  INDEX idx_expires (expires_at),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5) AUDIT LOG
CREATE TABLE audit_log (
  audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  user_id CHAR(36),
  action ENUM('INSERT','UPDATE','DELETE','LOGIN','SELECT') NOT NULL,
  table_name VARCHAR(50) NOT NULL,
  record_id CHAR(36),
  old_data JSON,
  new_data JSON,
  ip_address VARCHAR(45),
  session_id CHAR(36),
  INDEX idx_audit_user (user_id, timestamp),
  INDEX idx_audit_table (table_name, timestamp),
  INDEX idx_audit_time (timestamp)
) ENGINE=InnoDB;

-- 6) MERCHANTS
CREATE TABLE merchants (
  merchant_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL UNIQUE,
  business_name VARCHAR(100) NOT NULL,
  business_email VARCHAR(100),
  business_phone VARCHAR(20),
  address TEXT,
  verification_status ENUM('pending', 'verified', 'rejected') DEFAULT 'pending',
  rating DECIMAL(3,2) DEFAULT 0.00,
  total_sales DECIMAL(15,2) DEFAULT 0.00,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_verification (verification_status),
  INDEX idx_rating (rating),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7) CATEGORIES
CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL UNIQUE,
  parent_category_id INT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_parent (parent_category_id),
  INDEX idx_active (is_active),
  FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 8) PRODUCTS
CREATE TABLE products (
  product_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  merchant_id CHAR(36) NOT NULL,
  category_id INT NOT NULL,
  product_name VARCHAR(200) NOT NULL,
  description TEXT,
  regular_price DECIMAL(10,2) NOT NULL,
  stock_quantity INT NOT NULL DEFAULT 0,
  image_url VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_merchant (merchant_id),
  INDEX idx_category (category_id),
  INDEX idx_active_stock (is_active, stock_quantity),
  INDEX idx_price (regular_price),
  FULLTEXT idx_product_search (product_name, description),
  FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 9) DEALS
CREATE TABLE deals (
  deal_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  product_id CHAR(36) NOT NULL,
  merchant_id CHAR(36) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  original_price DECIMAL(10,2) NOT NULL,
  deal_price DECIMAL(10,2) NOT NULL,
  discount_pct DECIMAL(5,2) AS ((original_price - deal_price) / original_price * 100) STORED,
  quantity_available INT NOT NULL,
  quantity_sold INT DEFAULT 0,
  start_date DATETIME NOT NULL,
  end_date DATETIME NOT NULL,
  deal_status ENUM('upcoming', 'active', 'expired', 'soldout') DEFAULT 'upcoming',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_deal_status (deal_status),
  INDEX idx_dates (start_date, end_date),
  INDEX idx_merchant (merchant_id),
  INDEX idx_product (product_id),
  INDEX idx_active_deals (deal_status, start_date, end_date),
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id) ON DELETE CASCADE,
  CONSTRAINT chk_deal_price CHECK (deal_price < original_price),
  CONSTRAINT chk_deal_dates CHECK (end_date > start_date)
) ENGINE=InnoDB;

-- 10) ORDERS
CREATE TABLE orders (
  order_id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  user_id CHAR(36) NOT NULL,
  deal_id CHAR(36) NOT NULL,
  order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NOT NULL,
  amount DECIMAL(10,2) AS (quantity * unit_price) STORED,
  status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',
  payment_method ENUM('credit_card', 'debit_card', 'paypal', 'wallet') NOT NULL,
  payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
  shipping_address TEXT,
  tracking_number VARCHAR(100),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_user_orders (user_id, order_date),
  INDEX idx_deal_orders (deal_id),
  INDEX idx_status (status),
  INDEX idx_payment_status (payment_status),
  INDEX idx_order_date (order_date),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (deal_id) REFERENCES deals(deal_id) ON DELETE RESTRICT,
  CONSTRAINT chk_quantity CHECK (quantity > 0)
) ENGINE=InnoDB;

-- 11) INVENTORY LOG
CREATE TABLE inventory_log (
  log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id CHAR(36) NOT NULL,
  deal_id CHAR(36),
  change_type ENUM('restock', 'sale', 'return', 'adjustment') NOT NULL,
  quantity_change INT NOT NULL,
  quantity_before INT NOT NULL,
  quantity_after INT NOT NULL,
  reason VARCHAR(255),
  changed_by CHAR(36),
  changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_product_log (product_id, changed_at),
  INDEX idx_deal_log (deal_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  FOREIGN KEY (deal_id) REFERENCES deals(deal_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 12) REVIEWS
CREATE TABLE reviews (
  review_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  product_id CHAR(36) NOT NULL,
  merchant_id CHAR(36) NOT NULL,
  rating INT NOT NULL,
  review_text TEXT,
  review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  is_verified_purchase BOOLEAN DEFAULT TRUE,
  helpful_count INT DEFAULT 0,
  INDEX idx_product_reviews (product_id, rating),
  INDEX idx_merchant_reviews (merchant_id, rating),
  INDEX idx_user_reviews (user_id),
  FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
  FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id) ON DELETE CASCADE,
  CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;

-- 13) WISHLIST
CREATE TABLE wishlist (
  wishlist_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  product_id CHAR(36) NOT NULL,
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  notify_on_deal BOOLEAN DEFAULT TRUE,
  UNIQUE KEY uk_user_product (user_id, product_id),
  INDEX idx_user_wishlist (user_id),
  INDEX idx_product_wishlist (product_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 14) NOTIFICATIONS
CREATE TABLE notifications (
  notification_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  notification_type ENUM('deal_alert', 'order_update', 'price_drop', 'system') NOT NULL,
  title VARCHAR(200) NOT NULL,
  message TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_notifications (user_id, is_read, created_at),
  INDEX idx_notification_type (notification_type),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 15) ORDER HISTORY (Partitioned)
CREATE TABLE order_history (
  history_id BIGINT AUTO_INCREMENT,
  order_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  deal_id CHAR(36) NOT NULL,
  order_date DATETIME NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) NOT NULL,
  archived_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (history_id, order_date),
  INDEX idx_user_history (user_id, order_date),
  INDEX idx_archived (archived_at)
) ENGINE=InnoDB
PARTITION BY RANGE (YEAR(order_date)) (
  PARTITION p_2023 VALUES LESS THAN (2024),
  PARTITION p_2024 VALUES LESS THAN (2025),
  PARTITION p_2025 VALUES LESS THAN (2026),
  PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 16) DEAL METRICS
CREATE TABLE deal_metrics (
  metric_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  deal_id CHAR(36) NOT NULL,
  metric_date DATE NOT NULL,
  views_count INT DEFAULT 0,
  clicks_count INT DEFAULT 0,
  orders_count INT DEFAULT 0,
  revenue DECIMAL(15,2) DEFAULT 0.00,
  conversion_rate DECIMAL(5,2) AS (orders_count / NULLIF(clicks_count, 0) * 100) STORED,
  UNIQUE KEY uk_deal_date (deal_id, metric_date),
  INDEX idx_deal_metrics (deal_id, metric_date),
  INDEX idx_metric_date (metric_date),
  FOREIGN KEY (deal_id) REFERENCES deals(deal_id) ON DELETE CASCADE
) ENGINE=InnoDB;
