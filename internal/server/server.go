// Package server wires routes into an HTTP server and manages its lifecycle.
package server

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"time"

	"github.com/vivek-ted/go-cloud-native-app/internal/config"
)

// Server is an HTTP server that shuts down gracefully when its context ends.
type Server struct {
	httpServer      *http.Server
	shutdownTimeout time.Duration
	logger          *slog.Logger
}

// New builds a Server from the config and route handlers.
func New(cfg config.Config, healthHandler http.Handler, logger *slog.Logger) *Server {
	return &Server{
		httpServer: &http.Server{
			Addr:         cfg.Addr(),
			Handler:      newRouter(healthHandler),
			ReadTimeout:  cfg.ReadTimeout,
			WriteTimeout: cfg.WriteTimeout,
			IdleTimeout:  cfg.IdleTimeout,
		},
		shutdownTimeout: cfg.ShutdownTimeout,
		logger:          logger,
	}
}

func newRouter(healthHandler http.Handler) http.Handler {
	mux := http.NewServeMux()
	mux.Handle("GET /healthz", healthHandler)
	return mux
}

// Run listens on the configured address and serves until ctx is cancelled.
func (s *Server) Run(ctx context.Context) error {
	listener, err := net.Listen("tcp", s.httpServer.Addr)
	if err != nil {
		return fmt.Errorf("listen on %s: %w", s.httpServer.Addr, err)
	}
	return s.Serve(ctx, listener)
}

// Serve accepts connections on listener until ctx is cancelled, then shuts
// down gracefully, letting in-flight requests finish within the shutdown timeout.
func (s *Server) Serve(ctx context.Context, listener net.Listener) error {
	serveErr := make(chan error, 1)
	go func() {
		s.logger.Info("server started", "addr", listener.Addr().String())
		serveErr <- s.httpServer.Serve(listener)
	}()

	select {
	case err := <-serveErr:
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return fmt.Errorf("serve: %w", err)
	case <-ctx.Done():
	}

	s.logger.Info("shutting down server")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), s.shutdownTimeout)
	defer cancel()

	if err := s.httpServer.Shutdown(shutdownCtx); err != nil {
		return fmt.Errorf("shutdown: %w", err)
	}
	s.logger.Info("server stopped")
	return nil
}
