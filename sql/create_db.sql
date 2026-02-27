-- =====================================================
-- FlashDeals: Database Bootstrap
-- File: sql/00_create_database.sql
-- Purpose: Create database + select it
-- =====================================================

DROP DATABASE IF EXISTS flashdeals;

CREATE DATABASE IF NOT EXISTS flashdeals
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE flashdeals;
