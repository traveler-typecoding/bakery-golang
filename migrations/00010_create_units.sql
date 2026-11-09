-- +goose Up
CREATE TABLE inventory.units (
    id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code       text NOT NULL UNIQUE,                         -- g, kg, ml, l, pcs
    name       text NOT NULL,
    dimension  text NOT NULL CHECK (dimension IN ('mass','volume','count')),
    to_base    numeric(18,6) NOT NULL CHECK (to_base > 0)    -- g=1, kg=1000, ml=1, l=1000, pcs=1
);

-- +goose Down
DROP TABLE IF EXISTS inventory.units;
