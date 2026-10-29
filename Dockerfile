# =============================================================================
# Base: shared Go toolchain layer
# =============================================================================
FROM golang:1.23-alpine AS base
WORKDIR /app
RUN apk add --no-cache git
# Cache modules first so code changes don't re-download deps.
COPY go.mod go.sum* ./
RUN go mod download

# =============================================================================
# dev: hot reload with air. Source is bind-mounted via compose.
# =============================================================================
FROM base AS dev
RUN go install github.com/air-verse/air@latest
COPY . .
EXPOSE 8080
CMD ["air", "-c", ".air.toml"]

# =============================================================================
# build: compile a static binary
# =============================================================================
FROM base AS build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/server ./cmd/server

# =============================================================================
# prod: minimal runtime image
# =============================================================================
FROM alpine:3.20 AS prod
RUN apk add --no-cache ca-certificates && adduser -D -u 10001 appuser
WORKDIR /app
COPY --from=build /app/server /app/server
USER appuser
EXPOSE 8080
ENTRYPOINT ["/app/server"]
