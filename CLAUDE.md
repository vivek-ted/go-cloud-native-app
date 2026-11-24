# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
make build          # go build -o bin/server ./cmd/server
make run            # go run ./cmd/server   (PORT env var, default 8080)
make test           # go test -race ./...
make lint           # go vet, plus golangci-lint if installed
make fmt            # gofmt -s -w .
make docker-build   # image tag go-cloud-native-app:local
make docker-run     # serves on localhost:8080

go test -race -run TestName ./internal/health/   # single test in one package
curl -i localhost:8080/healthz                    # smoke check
```

## Architecture

Standard-library-only Go service (module `github.com/vivek-ted/go-cloud-native-app`, Go 1.26). Routing uses `net/http.ServeMux` method patterns (`"GET /healthz"`), so wrong methods get 405 from the mux, not the handler.

Wiring happens only in `cmd/server/main.go`: it loads config, builds handlers, and injects them into `server.New`. Packages under `internal/` don't construct their own collaborators:

- `internal/config` — `Load(getenv)` takes the lookup func (pass `os.Getenv`; pass a map-backed func in tests). Only `PORT` is env-configurable (validated 1–65535); timeouts are constants.
- `internal/server` — owns the `http.Server`, route table (`newRouter`), and lifecycle. `Run` listens on the configured address; `Serve(ctx, listener)` takes any listener, so tests can bind `127.0.0.1:0`. Cancelling `ctx` triggers graceful `Shutdown` bounded by `ShutdownTimeout`.
- `internal/health` — `GET /healthz` liveness handler; returns `{"status":"ok"}` with no dependency checks.

Shutdown signal path: SIGINT/SIGTERM → `signal.NotifyContext` in `main` → ctx passed to `Server.Run`. Logging is JSON `log/slog` to stdout; the logger is injected into `server.New`.

To add an endpoint: create a handler package under `internal/`, add a parameter to `server.New` and a route in `newRouter`, then wire it in `main.go`.

## Container

Multi-stage `Dockerfile`: static binary (`CGO_ENABLED=0`) on `gcr.io/distroless/static-debian12:nonroot`. The runtime image has no shell or curl, so there is no Docker `HEALTHCHECK`; use orchestrator HTTP probes against `/healthz`.
