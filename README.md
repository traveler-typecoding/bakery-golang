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
└── migrations/         # versioned SQL migrations (up/down)
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

`migrations/` holds versioned schema changes applied by a migration tool
(e.g. [golang-migrate](https://github.com/golang-migrate/migrate), goose, or
atlas). These travel with the code that depends on them.

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
