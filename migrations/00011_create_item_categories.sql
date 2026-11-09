-- +goose Up
CREATE TABLE inventory.item_categories (
    id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  text NOT NULL UNIQUE
);

-- +goose Down
DROP TABLE IF EXISTS inventory.item_categories;
