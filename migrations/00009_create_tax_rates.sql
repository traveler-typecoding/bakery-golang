-- +goose Up
CREATE TABLE sales.tax_rates (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code            text NOT NULL,                           -- e.g. VAT
    name            text NOT NULL,
    rate            numeric(7,4) NOT NULL CHECK (rate >= 0), -- 0.1100 = 11%
    effective_from  date NOT NULL,
    effective_to    date,
    CHECK (effective_to IS NULL OR effective_to >= effective_from),
    UNIQUE (code, effective_from)
);

-- +goose Down
DROP TABLE IF EXISTS sales.tax_rates;
