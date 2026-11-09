-- +goose Up
CREATE TABLE sales.sale_lines (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id     bigint NOT NULL REFERENCES sales.sales(id) ON DELETE CASCADE,
    item_id     bigint NOT NULL REFERENCES inventory.items(id),
    qty         numeric(18,4) NOT NULL CHECK (qty > 0),
    unit_price  numeric(18,2) NOT NULL,           -- snapshot, so later price changes don't rewrite history
    discount    numeric(18,2) NOT NULL DEFAULT 0,
    tax_rate    numeric(7,4)  NOT NULL DEFAULT 0, -- snapshot of the rate applied
    tax_amount  numeric(18,2) NOT NULL DEFAULT 0,
    line_total  numeric(18,2) NOT NULL
);

-- +goose Down
DROP TABLE IF EXISTS sales.sale_lines;
