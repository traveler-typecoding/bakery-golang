# bakery-golang

Go backend for the Bakery system. Owns its source, Dockerfile, and database
migrations. Orchestrated by the `bakery-infra` repo.

## Layout

```
.
├── Dockerfile          # multi-stage: dev (air hot reload) / build / prod
├── .air.toml           # hot-reload config used by the dev target
├── go.mod
├── cmd/server/main.go  # HTTP server with /health
└── migrations/         # goose SQL migrations (Up + Down in one file)
```

## Run standalone (just this service)

```bash
docker build --target dev -t bakery-golang:local .
docker run --rm -p 8080:8080 bakery-golang:local
# http://localhost:8080/health
```

Normally you run it via the full stack in `bakery-infra`
(`docker compose up`), which also starts Postgres.

## Migrations

`migrations/` holds versioned schema changes applied with
[goose](https://github.com/pressly/goose). These travel with the code that
depends on them.

Each file is `NNNNN_name.sql` and contains both directions:

```sql
-- +goose Up
CREATE TABLE ...;

-- +goose Down
DROP TABLE IF EXISTS ...;
```

Tables are grouped into PostgreSQL schemas by business area (created in
`00002_create_schemas.sql`):

| Schema | Tables |
|---|---|
| `org` | outlets, positions, employees, employee_assignments (+ view employee_current_assignment) |
| `auth` | roles, users, user_roles |
| `inventory` | units, item_categories, suppliers, items, recipes, recipe_lines, stock_movements |
| `sales` | tax_rates, customers, sales, sale_lines, payments |

Always write the schema name in migrations (`org.outlets`, `REFERENCES org.outlets(id)`).
goose keeps its own `goose_db_version` table in `public`.

Full reference of every migration, table and column: [docs/migrations.md](docs/migrations.md).

One table per migration, ordered so foreign-key targets are created first.
goose runs each file in its own transaction, so don't add `BEGIN/COMMIT`.
Never edit a migration that has already run somewhere; add a new one instead.
Applied versions are recorded in the `goose_db_version` table.

### Install goose (once)

```cmd
go install github.com/pressly/goose/v3/cmd/goose@latest
```

### Run (from this repo, with the compose Postgres up)

Windows cmd:

```cmd
set GOOSE_DRIVER=postgres
set "GOOSE_DBSTRING=postgres://bakery:changeme@localhost:5432/bakerydb?sslmode=disable"
set GOOSE_MIGRATION_DIR=migrations

goose status        :: list applied / pending migrations
goose up            :: apply all pending
goose down          :: roll back the last one
goose create -s add_something sql   :: new file with the next number
```

Use the user, password and database from `bakery-infra/.env` if you changed them.

> Note: `bakery-infra/db/init/*.sql` runs only once, on an empty Postgres
> volume, for first-boot bootstrap. Real schema evolution belongs here in
> `migrations/`.

## Image publishing

CI builds the `prod` target and pushes a tagged image; `bakery-infra` then
references that tag via `BACKEND_IMAGE`.

```bash
docker build --target prod -t registry.example.com/bakery/golang:<tag> .
docker push registry.example.com/bakery/golang:<tag>
```
