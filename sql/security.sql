USE flashdeals;

CREATE USER IF NOT EXISTS 'flashdeals_app'@'%' IDENTIFIED BY 'TempAppPass123!';
CREATE USER IF NOT EXISTS 'flashdeals_web'@'%' IDENTIFIED BY 'TempWebPass123!';
CREATE USER IF NOT EXISTS 'flashdeals_admin'@'%' IDENTIFIED BY 'TempAdminPass123!';
CREATE USER IF NOT EXISTS 'flashdeals_analyst'@'%' IDENTIFIED BY 'TempAnalyst123!';

GRANT SELECT, INSERT, UPDATE, DELETE ON flashdeals.* TO 'flashdeals_app'@'%';
GRANT EXECUTE ON flashdeals.* TO 'flashdeals_web'@'%';
GRANT ALL PRIVILEGES ON flashdeals.* TO 'flashdeals_admin'@'%';

-- Analyst only gets aggregated view later (in 03_logic.sql after views exist)
-- GRANT SELECT ON flashdeals.vw_deal_summary TO 'flashdeals_analyst'@'%';

FLUSH PRIVILEGES;
