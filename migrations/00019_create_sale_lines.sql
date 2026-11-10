-- +goose Up
-- No ON DELETE CASCADE: a sale that has lines cannot be deleted.
-- Cancel a sale with sales.status ('void', 'refunded') instead.
CREATE TABLE sales.sale_lines (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id     bigint NOT NULL REFERENCES sales.sales(id),
    item_id     bigint NOT NULL REFERENCES inventory.items(id),
    qty         numeric(18,4) NOT NULL CHECK (qty > 0),
    unit_price  numeric(18,2) NOT NULL,           -- snapshot, so later price changes don't rewrite history
    discount    numeric(18,2) NOT NULL DEFAULT 0,
    tax_rate    numeric(7,4)  NOT NULL DEFAULT 0, -- snapshot of the rate applied
    tax_amount  numeric(18,2) NOT NULL DEFAULT 0,
    line_total  numeric(18,2) NOT NULL,
    -- The backend computes tax_amount and line_total; the database only rejects negatives.
    CHECK (unit_price >= 0 AND discount >= 0 AND tax_rate >= 0 AND tax_amount >= 0 AND line_total >= 0)
);
-- PostgreSQL does not index FK columns by itself.
CREATE INDEX idx_sale_lines_sale ON sales.sale_lines(sale_id);   -- lines of one receipt
CREATE INDEX idx_sale_lines_item ON sales.sale_lines(item_id);   -- sales per item reports

-- +goose Down
DROP TABLE IF EXISTS sales.sale_lines;
