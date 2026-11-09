-- +goose Up
-- System permission roles (what a person may do in the software), not job titles.
CREATE TABLE auth.roles (
    id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code  text NOT NULL UNIQUE,            -- owner, manager, cashier, baker, accountant
    name  text NOT NULL
);

-- +goose Down
DROP TABLE IF EXISTS auth.roles;
