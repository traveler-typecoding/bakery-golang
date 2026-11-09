-- +goose Up
-- One schema per business area. Tables refer to each other across schemas
-- with fully qualified names, e.g. REFERENCES org.outlets(id).
--   org        outlets, positions, employees, employee_assignments
--   auth       roles, users (login and permissions)
--   inventory  units, item_categories, suppliers, items, recipes, stock ledger
--   sales      tax_rates, customers, sales, sale_lines, payments
-- Later phases add their own schemas (purchasing, production, payroll, accounting).
CREATE SCHEMA IF NOT EXISTS org;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS inventory;
CREATE SCHEMA IF NOT EXISTS sales;

-- +goose Down
-- No CASCADE: the later migrations' Down steps must have dropped the tables first,
-- so a leftover table makes this fail loudly instead of silently deleting data.
DROP SCHEMA IF EXISTS sales;
DROP SCHEMA IF EXISTS inventory;
DROP SCHEMA IF EXISTS auth;
DROP SCHEMA IF EXISTS org;
