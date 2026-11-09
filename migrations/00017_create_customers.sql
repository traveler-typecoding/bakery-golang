-- +goose Up
CREATE TABLE sales.customers (
    id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            text NOT NULL,
    phone           text UNIQUE,
    email           text,
    birth_date      date,
    loyalty_points  integer NOT NULL DEFAULT 0 CHECK (loyalty_points >= 0),
    notes           text,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE IF EXISTS sales.customers;
