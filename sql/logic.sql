USE flashdeals;

SET @FLASHDEALS_AES_KEY = 'DEMO_KEY_CHANGE_ME';

-- -------------------------
-- SECTION A: ENCRYPTION TRIGGERS
-- -------------------------
DELIMITER $$

CREATE TRIGGER trg_encrypt_user_pii
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
  IF NEW.email_plain IS NOT NULL THEN
    SET NEW.email_encrypted = AES_ENCRYPT(NEW.email_plain, @FLASHDEALS_AES_KEY);
    SET NEW.email_plain = NULL;
  END IF;

  IF NEW.phone_plain IS NOT NULL THEN
    SET NEW.phone_encrypted = AES_ENCRYPT(NEW.phone_plain, @FLASHDEALS_AES_KEY);
    SET NEW.phone_plain = NULL;
  END IF;
END$$

CREATE TRIGGER trg_encrypt_user_pii_update
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
  IF NEW.email_plain IS NOT NULL THEN
    SET NEW.email_encrypted = AES_ENCRYPT(NEW.email_plain, @FLASHDEALS_AES_KEY);
    SET NEW.email_plain = NULL;
  END IF;

  IF NEW.phone_plain IS NOT NULL THEN
    SET NEW.phone_encrypted = AES_ENCRYPT(NEW.phone_plain, @FLASHDEALS_AES_KEY);
    SET NEW.phone_plain = NULL;
  END IF;
END$$

DELIMITER ;

-- -------------------------
-- SECTION B: ACCOUNT LOCKOUT TRIGGER
-- -------------------------
DELIMITER $$

CREATE TRIGGER trg_check_login_lockout
BEFORE INSERT ON login_audit
FOR EACH ROW
BEGIN
  DECLARE lock_time DATETIME;

  SELECT locked_until INTO lock_time
  FROM account_lock
  WHERE user_id = NEW.user_id;

  IF lock_time IS NOT NULL AND lock_time > NOW() THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account locked. Try again later.';
  END IF;

  IF NEW.success = 0 THEN
    INSERT INTO account_lock (user_id, failed_attempts, locked_until, last_attempt)
    VALUES (NEW.user_id, 1, NULL, NOW())
    ON DUPLICATE KEY UPDATE
      failed_attempts = failed_attempts + 1,
      last_attempt = NOW(),
      locked_until = CASE
        WHEN failed_attempts + 1 >= 5 THEN DATE_ADD(NOW(), INTERVAL 15 MINUTE)
        ELSE NULL
      END;
  ELSE
    DELETE FROM account_lock WHERE user_id = NEW.user_id;
  END IF;
END$$

DELIMITER ;

-- -------------------------
-- SECTION C: AUDIT TRIGGERS (uses session vars)
-- NOTE: @current_user_id and @session_id should be set by app/session.
-- -------------------------
DELIMITER $$

CREATE TRIGGER trg_audit_users_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, table_name, record_id, new_data, ip_address, session_id)
  VALUES (
    NEW.user_id, 'INSERT', 'users', NEW.user_id,
    JSON_OBJECT('username', NEW.username, 'user_type', NEW.user_type, 'account_status', NEW.account_status),
    SUBSTRING_INDEX(USER(), '@', -1),
    @session_id
  );
END$$

CREATE TRIGGER trg_audit_users_update
AFTER UPDATE ON users
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, table_name, record_id, old_data, new_data, ip_address)
  VALUES (
    NEW.user_id, 'UPDATE', 'users', NEW.user_id,
    JSON_OBJECT('account_status', OLD.account_status),
    JSON_OBJECT('account_status', NEW.account_status),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END$$

CREATE TRIGGER trg_audit_deals_insert
AFTER INSERT ON deals
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, table_name, record_id, new_data, ip_address)
  VALUES (
    @current_user_id, 'INSERT', 'deals', NEW.deal_id,
    JSON_OBJECT('title', NEW.title, 'merchant_id', NEW.merchant_id, 'discount_pct', NEW.discount_pct, 'start_date', NEW.start_date),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END$$

CREATE TRIGGER trg_audit_deals_update
AFTER UPDATE ON deals
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, table_name, record_id, old_data, new_data, ip_address)
  VALUES (
    @current_user_id, 'UPDATE', 'deals', NEW.deal_id,
    JSON_OBJECT('title', OLD.title, 'discount_pct', OLD.discount_pct),
    JSON_OBJECT('title', NEW.title, 'discount_pct', NEW.discount_pct),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END$$

CREATE TRIGGER trg_audit_deals_delete
AFTER DELETE ON deals
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, table_name, record_id, old_data, ip_address)
  VALUES (
    @current_user_id, 'DELETE', 'deals', OLD.deal_id,
    JSON_OBJECT('title', OLD.title, 'merchant_id', OLD.merchant_id, 'discount_pct', OLD.discount_pct),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END$$

CREATE TRIGGER trg_audit_orders_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, table_name, record_id, new_data, ip_address)
  VALUES (
    @current_user_id, 'INSERT', 'orders', NEW.order_id,
    JSON_OBJECT('deal_id', NEW.deal_id, 'amount', NEW.amount, 'status', NEW.status),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END$$

CREATE TRIGGER trg_audit_orders_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, table_name, record_id, old_data, new_data, ip_address)
  VALUES (
    @current_user_id, 'UPDATE', 'orders', NEW.order_id,
    JSON_OBJECT('status', OLD.status, 'amount', OLD.amount),
    JSON_OBJECT('status', NEW.status, 'amount', NEW.amount),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END$$

CREATE TRIGGER trg_audit_orders_delete
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
  INSERT INTO audit_log (user_id, action, table_name, record_id, old_data, ip_address)
  VALUES (
    @current_user_id, 'DELETE', 'orders', OLD.order_id,
    JSON_OBJECT('deal_id', OLD.deal_id, 'amount', OLD.amount, 'status', OLD.status),
    SUBSTRING_INDEX(USER(), '@', -1)
  );
END$$

DELIMITER ;

-- -------------------------
-- SECTION D: VIEWS
-- -------------------------
CREATE OR REPLACE VIEW vw_user_profile AS
SELECT
  u.user_id,
  u.username,
  CAST(AES_DECRYPT(u.email_encrypted, @FLASHDEALS_AES_KEY) AS CHAR) AS email,
  CAST(AES_DECRYPT(u.phone_encrypted, @FLASHDEALS_AES_KEY) AS CHAR) AS phone,
  u.user_type,
  u.account_status,
  u.created_at
FROM users u;

CREATE OR REPLACE VIEW vw_merchant_deals AS
SELECT
  d.deal_id, d.product_id, d.merchant_id, d.title, d.description,
  d.original_price, d.deal_price, d.discount_pct,
  d.quantity_available, d.quantity_sold,
  d.start_date, d.end_date, d.deal_status
FROM deals d;

CREATE OR REPLACE VIEW vw_deal_summary AS
SELECT
  d.deal_id,
  d.title,
  d.discount_pct,
  d.start_date,
  COUNT(o.order_id) AS total_orders,
  COALESCE(SUM(o.amount), 0) AS revenue
FROM deals d
LEFT JOIN orders o ON d.deal_id = o.deal_id AND o.status = 'confirmed'
GROUP BY d.deal_id, d.title, d.discount_pct, d.start_date;

-- -------------------------
-- SECTION E: STORED PROCEDURES
-- -------------------------
DELIMITER $$

CREATE PROCEDURE get_user_profile(
  IN p_session_id CHAR(36),
  IN p_user_id CHAR(36)
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM session_context
    WHERE session_id = p_session_id
      AND user_id = p_user_id
      AND expires_at > NOW()
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid session or access denied';
  END IF;

  SELECT
    user_id,
    username,
    CAST(AES_DECRYPT(email_encrypted, @FLASHDEALS_AES_KEY) AS CHAR) AS email,
    CAST(AES_DECRYPT(phone_encrypted, @FLASHDEALS_AES_KEY) AS CHAR) AS phone,
    user_type,
    account_status,
    created_at
  FROM users
  WHERE user_id = p_user_id;
END$$

CREATE PROCEDURE get_merchant_deals(
  IN p_session_id CHAR(36),
  IN p_merchant_id CHAR(36)
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM session_context
    WHERE session_id = p_session_id
      AND merchant_id = p_merchant_id
      AND expires_at > NOW()
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid session or access denied';
  END IF;

  SELECT
    deal_id, product_id, title, description,
    original_price, deal_price, discount_pct,
    quantity_available, quantity_sold,
    start_date, end_date, deal_status, created_at
  FROM deals
  WHERE merchant_id = p_merchant_id;
END$$

CREATE PROCEDURE create_session(
  IN p_user_id CHAR(36),
  IN p_role ENUM('customer', 'merchant', 'admin', 'analyst'),
  IN p_merchant_id CHAR(36),
  IN p_ip_address VARCHAR(45),
  OUT p_session_id CHAR(36)
)
BEGIN
  SET p_session_id = UUID();

  INSERT INTO session_context (session_id, user_id, merchant_id, role, expires_at, ip_address)
  VALUES (p_session_id, p_user_id, p_merchant_id, p_role, DATE_ADD(NOW(), INTERVAL 2 HOUR), p_ip_address);

  SELECT p_session_id AS session_id;
END$$

CREATE PROCEDURE process_order_transaction(
  IN p_user_id CHAR(36),
  IN p_deal_id CHAR(36),
  IN p_quantity INT,
  IN p_payment_method VARCHAR(20),
  OUT p_order_id CHAR(36),
  OUT p_result VARCHAR(100)
)
BEGIN
  DECLARE v_deal_price DECIMAL(10,2);
  DECLARE v_quantity_available INT;
  DECLARE v_product_id CHAR(36);
  DECLARE v_merchant_id CHAR(36);

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SET p_result = 'ERROR: Transaction rolled back';
    SET p_order_id = NULL;
  END;

  START TRANSACTION;

  SELECT
    deal_price,
    quantity_available - quantity_sold,
    product_id,
    merchant_id
  INTO
    v_deal_price,
    v_quantity_available,
    v_product_id,
    v_merchant_id
  FROM deals
  WHERE deal_id = p_deal_id
    AND deal_status = 'active'
    AND start_date <= NOW()
    AND end_date >= NOW()
  FOR UPDATE;

  IF v_quantity_available < p_quantity THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient quantity available';
  END IF;

  SET p_order_id = UUID();

  INSERT INTO orders (order_id, user_id, deal_id, quantity, unit_price, status, payment_method, payment_status, shipping_address)
  VALUES (p_order_id, p_user_id, p_deal_id, p_quantity, v_deal_price, 'pending', p_payment_method, 'pending', '123 Default St');

  UPDATE deals
  SET quantity_sold = quantity_sold + p_quantity,
      deal_status = CASE
        WHEN quantity_sold + p_quantity >= quantity_available THEN 'soldout'
        ELSE deal_status
      END
  WHERE deal_id = p_deal_id;

  INSERT INTO inventory_log (product_id, deal_id, change_type, quantity_change, quantity_before, quantity_after, reason, changed_by)
  VALUES (v_product_id, p_deal_id, 'sale', -p_quantity, v_quantity_available, v_quantity_available - p_quantity, 'Order processed', p_user_id);

  UPDATE merchants
  SET total_sales = total_sales + (v_deal_price * p_quantity)
  WHERE merchant_id = v_merchant_id;

  COMMIT;
  SET p_result = 'SUCCESS: Order processed';
END$$

DELIMITER ;
