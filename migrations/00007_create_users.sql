-- +goose Up
-- One login per employee. A user's roles live in auth.user_roles (00021),
-- so one person can hold several roles, e.g. owner + accountant.
CREATE TABLE auth.users (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id    bigint NOT NULL UNIQUE REFERENCES org.employees(id),
    username       text NOT NULL UNIQUE,
    password_hash  text NOT NULL,
    is_active      boolean NOT NULL DEFAULT true,
    last_login_at  timestamptz,
    created_at     timestamptz NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE IF EXISTS auth.users;
