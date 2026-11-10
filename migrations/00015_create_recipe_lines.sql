-- +goose Up
-- No ON DELETE CASCADE: a recipe that still has lines cannot be deleted.
-- Retire a recipe with inventory.recipes.is_active instead, or have the backend
-- delete its lines first in the same transaction.
CREATE TABLE inventory.recipe_lines (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    recipe_id      bigint NOT NULL REFERENCES inventory.recipes(id),
    input_item_id  bigint NOT NULL REFERENCES inventory.items(id),
    qty            numeric(18,4) NOT NULL CHECK (qty > 0),   -- in input item's base unit, per batch
    UNIQUE (recipe_id, input_item_id)
);
-- "Which recipes use this ingredient?" PostgreSQL does not index FK columns by itself.
CREATE INDEX idx_recipe_lines_input ON inventory.recipe_lines(input_item_id);

-- +goose Down
DROP TABLE IF EXISTS inventory.recipe_lines;
