-- +goose Up
-- Job titles as data, not free text, so history and reports stay consistent.
CREATE TABLE org.positions (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code       text NOT NULL UNIQUE,          -- baker, cashier, store_manager
    name       text NOT NULL,
    is_active  boolean NOT NULL DEFAULT true
);

-- +goose Down
DROP TABLE IF EXISTS org.positions;
