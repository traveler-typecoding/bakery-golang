-- +goose Up
-- Recipes (bill of materials).
CREATE TABLE inventory.recipes (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    output_item_id  bigint NOT NULL REFERENCES inventory.items(id),
    version         integer NOT NULL DEFAULT 1,
    yield_qty       numeric(18,4) NOT NULL CHECK (yield_qty > 0),  -- output per batch, in output item's base unit
    notes           text,
    is_active       boolean NOT NULL DEFAULT true,
    created_at      timestamptz NOT NULL DEFAULT now(),
    UNIQUE (output_item_id, version)
);

-- +goose Down
DROP TABLE IF EXISTS inventory.recipes;
