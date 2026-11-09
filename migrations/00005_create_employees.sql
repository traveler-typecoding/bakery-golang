-- +goose Up
-- Current position and outlet live in org.employee_assignments (single source of truth).
-- Sensitive payroll data (NIK, NPWP, bank account, BPJS no.) goes in
-- employee_payroll_profiles in the payroll phase, with tighter access.
CREATE TABLE org.employees (
    id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_no      text NOT NULL UNIQUE,
    full_name        text NOT NULL,
    phone            text,
    email            text,
    employment_type  text NOT NULL DEFAULT 'permanent'
                     CHECK (employment_type IN ('permanent','contract','daily','part_time')),
    hire_date        date NOT NULL,
    end_date         date,
    is_active        boolean NOT NULL DEFAULT true,
    created_at       timestamptz NOT NULL DEFAULT now(),
    updated_at       timestamptz NOT NULL DEFAULT now()
);

-- +goose Down
DROP TABLE IF EXISTS org.employees;
