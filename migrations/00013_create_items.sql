-- +goose Up
-- One table for everything stocked or sold; item_type tells them apart.
CREATE TABLE inventory.items (
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku              text NOT NULL UNIQUE,
    name             text NOT NULL,
    item_type        text NOT NULL
                     CHECK (item_type IN ('raw_material','semi_finished','finished_good','packaging')),
    category_id      bigint REFERENCES inventory.item_categories(id),
    base_unit_id     bigint NOT NULL REFERENCES inventory.units(id),   -- all stock is counted in this unit
    is_sellable      boolean NOT NULL DEFAULT false,
    selling_price    numeric(18,2) CHECK (selling_price >= 0),
    tax_rate_code    text,                                   -- resolved via sales.tax_rates at sale time
    shelf_life_days  integer,
    reorder_level    numeric(18,4),
    is_active        boolean NOT NULL DEFAULT true,
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now(),
    CHECK (NOT is_sellable OR selling_price IS NOT NULL)
);
CREATE INDEX idx_items_type ON inventory.items(item_type) WHERE is_active;

-- +goose Down
DROP TABLE IF EXISTS inventory.items;
