-- +goose Up
-- Which roles each user holds. A user's permissions are the combination of all
-- their roles, e.g. owner + accountant.
-- No ON DELETE CASCADE: a user who still has roles cannot be deleted.
-- Deactivate users with auth.users.is_active instead.
CREATE TABLE auth.user_roles (
    user_id     bigint NOT NULL REFERENCES auth.users(id),
    role_id     bigint NOT NULL REFERENCES auth.roles(id),
    granted_by  bigint REFERENCES auth.users(id),
    granted_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, role_id)
);
-- "Who has role X?" The primary key already covers "what roles does user Y have?".
CREATE INDEX idx_user_roles_role ON auth.user_roles(role_id);

-- +goose Down
DROP TABLE IF EXISTS auth.user_roles;
