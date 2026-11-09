-- +goose Up
-- Lives in inventory until the purchasing phase; may move to a purchasing schema then.
CREATE TABLE inventory.suppliers (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       text NOT NULL,
    phone      text,
    email      text,
    address    text,
    is_active  boolean NOT NULL DEFAULT true
);

-- +goose Down
DROP TABLE IF EXISTS inventory.suppliers;
