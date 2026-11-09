-- +goose Up
-- Lets a gist exclusion constraint combine "=" on a bigint with a range overlap.
-- Needed by org.employee_assignments (00008) to block overlapping assignment periods.
-- Installed in the public schema; its operator classes work for tables in any schema.
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- +goose Down
DROP EXTENSION IF EXISTS btree_gist;
