-- +goose Up
CREATE TABLE sales.payments (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sale_id    bigint NOT NULL REFERENCES sales.sales(id) ON DELETE CASCADE,
    method     text NOT NULL CHECK (method IN ('cash','card','qris','ewallet','transfer')),
    amount     numeric(18,2) NOT NULL CHECK (amount > 0),
    reference  text,                              -- gateway/terminal reference
    paid_at    timestamptz NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE IF EXISTS sales.payments;
