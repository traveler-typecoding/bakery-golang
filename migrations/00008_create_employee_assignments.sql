-- How the application changes assignments (do each change in ONE transaction):
--
-- Promotion: end one job and start the new one.
-- BEGIN;
--   UPDATE org.employee_assignments
--      SET valid_to = DATE '2027-01-01'
--    WHERE id = $old_assignment_id;
--
--   INSERT INTO org.employee_assignments
--     (employee_id, outlet_id, position_id, is_primary, valid_from, change_reason, created_by)
--   VALUES ($1, $2, $3, true, DATE '2027-01-01', 'promotion', $4);
-- COMMIT;
--
-- Extra job on top of the current one (e.g. a baker who also manages the store):
--   INSERT INTO org.employee_assignments
--     (employee_id, outlet_id, position_id, is_primary, valid_from, change_reason, created_by)
--   VALUES ($1, $2, $3, false, CURRENT_DATE, 'additional', $4);
--
-- Ending a job: set valid_to on that row. No new row needed.
--
-- "What did employee 7 do on 2026-06-15?" (one row per job held that day)
-- SELECT * FROM org.employee_assignments
--  WHERE employee_id = 7
--    AND daterange(valid_from, valid_to, '[)') @> DATE '2026-06-15';

-- +goose Up
-- One row per period an employee held a position at an outlet.
-- An employee may hold several positions at once (baker + store manager),
-- or the same position at several outlets. At most one of them is primary,
-- which is the main job used by payroll and reports.
-- Period is half-open: [valid_from, valid_to). valid_to NULL = current.
-- Both exclusion constraints need the btree_gist extension (00001).
CREATE TABLE org.employee_assignments (
    id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id    bigint NOT NULL REFERENCES org.employees(id),
    outlet_id      bigint NOT NULL REFERENCES org.outlets(id),
    position_id    bigint NOT NULL REFERENCES org.positions(id),
    is_primary     boolean NOT NULL DEFAULT false,
    valid_from     date NOT NULL,
    valid_to       date,
    change_reason  text NOT NULL
                   CHECK (change_reason IN ('hire','promotion','demotion','transfer',
                                            'position_change','additional','other')),
    note           text,
    created_by     bigint REFERENCES auth.users(id),
    created_at     timestamptz NOT NULL DEFAULT now(),
    CHECK (valid_to IS NULL OR valid_to > valid_from),
    -- The same job at the same outlet cannot overlap itself.
    EXCLUDE USING gist (
        employee_id WITH =,
        outlet_id   WITH =,
        position_id WITH =,
        daterange(valid_from, valid_to, '[)') WITH &&
    ),
    -- At most one primary job at any moment.
    EXCLUDE USING gist (
        employee_id WITH =,
        daterange(valid_from, valid_to, '[)') WITH &&
    ) WHERE (is_primary)
);
CREATE INDEX idx_assignments_outlet ON org.employee_assignments(outlet_id, valid_from);

-- Where is everyone today? One row per job currently held.
CREATE VIEW org.employee_current_assignment AS
SELECT a.employee_id, a.outlet_id, a.position_id, a.is_primary, a.valid_from
FROM org.employee_assignments a
WHERE a.valid_from <= CURRENT_DATE
  AND (a.valid_to IS NULL OR a.valid_to > CURRENT_DATE);

-- +goose Down
DROP VIEW IF EXISTS org.employee_current_assignment;
DROP TABLE IF EXISTS org.employee_assignments;
