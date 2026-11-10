-- +goose Up
-- No ON DELETE CASCADE: a sale that has payments cannot be deleted.
CREATE TABLE sales.payments (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id    bigint NOT NULL REFERENCES sales.sales(id),
    method     text NOT NULL CHECK (method IN ('cash','card','qris','ewallet','transfer')),
    amount     numeric(18,2) NOT NULL CHECK (amount > 0),
    reference  text,                              -- gateway/terminal reference
    paid_at    timestamptz NOT NULL DEFAULT now()
);
-- Payments of one receipt. PostgreSQL does not index FK columns by itself.
CREATE INDEX idx_payments_sale ON sales.payments(sale_id);

-- +goose Down
DROP TABLE IF EXISTS sales.payments;
