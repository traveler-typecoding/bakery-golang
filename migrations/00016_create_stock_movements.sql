-- +goose Up
-- Stock ledger (append-only).
-- Never UPDATE or DELETE rows here. Corrections are new rows.
-- The backend enforces this: its stock repository only offers an insert.
--
-- Stock on hand is calculated by the backend, not stored or defined here.
-- Query to use in the Go repository:
--   SELECT outlet_id, item_id, sum(qty_change) AS qty_on_hand
--     FROM inventory.stock_movements
--    WHERE outlet_id = $1
--    GROUP BY outlet_id, item_id;
CREATE TABLE inventory.stock_movements (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    outlet_id       bigint NOT NULL REFERENCES org.outlets(id),
    item_id         bigint NOT NULL REFERENCES inventory.items(id),
    movement_type   text NOT NULL
                    CHECK (movement_type IN ('purchase','production_in','production_out',
                                             'sale','waste','adjustment','transfer_in','transfer_out')),
    qty_change      numeric(18,4) NOT NULL CHECK (qty_change <> 0),  -- signed, base unit
    unit_cost       numeric(18,4),                                   -- cost per base unit, if known
    expiry_date     date,
    reference_type  text,                                            -- 'sale', 'purchase_order', ...
    reference_id    bigint,
    note            text,
    created_by      bigint REFERENCES auth.users(id),
    created_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_stock_mov_lookup ON inventory.stock_movements(outlet_id, item_id, created_at);
CREATE INDEX idx_stock_mov_ref    ON inventory.stock_movements(reference_type, reference_id);

-- +goose Down
DROP TABLE IF EXISTS inventory.stock_movements;
