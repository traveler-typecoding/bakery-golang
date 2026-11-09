-- +goose Up
CREATE TABLE inventory.recipe_lines (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    recipe_id      bigint NOT NULL REFERENCES inventory.recipes(id) ON DELETE CASCADE,
    input_item_id  bigint NOT NULL REFERENCES inventory.items(id),
    qty            numeric(18,4) NOT NULL CHECK (qty > 0),   -- in input item's base unit, per batch
    UNIQUE (recipe_id, input_item_id)
);

-- +goose Down
DROP TABLE IF EXISTS inventory.recipe_lines;
