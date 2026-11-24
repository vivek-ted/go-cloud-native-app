// Package config loads application configuration from environment variables.
package config

import (
	"fmt"
	"strconv"
	"time"
)

const (
	defaultPort            = 8080
	defaultReadTimeout     = 5 * time.Second
	defaultWriteTimeout    = 10 * time.Second
	defaultIdleTimeout     = 60 * time.Second
	defaultShutdownTimeout = 10 * time.Second

	minPort = 1
	maxPort = 65535
)

// Config holds the runtime settings for the HTTP server.
type Config struct {
	Port            int
	ReadTimeout     time.Duration
	WriteTimeout    time.Duration
	IdleTimeout     time.Duration
	ShutdownTimeout time.Duration
}

// Addr returns the listen address for the configured port.
func (c Config) Addr() string {
	return fmt.Sprintf(":%d", c.Port)
}

// Load builds a Config from the given lookup function (typically os.Getenv),
// applying defaults for unset values.
func Load(getenv func(string) string) (Config, error) {
	port, err := parsePort(getenv("PORT"))
	if err != nil {
		return Config{}, err
	}

	return Config{
		Port:            port,
		ReadTimeout:     defaultReadTimeout,
		WriteTimeout:    defaultWriteTimeout,
		IdleTimeout:     defaultIdleTimeout,
		ShutdownTimeout: defaultShutdownTimeout,
	}, nil
}

func parsePort(raw string) (int, error) {
	if raw == "" {
		return defaultPort, nil
	}

	port, err := strconv.Atoi(raw)
	if err != nil {
		return 0, fmt.Errorf("invalid PORT %q: must be a number", raw)
	}
	if port < minPort || port > maxPort {
		return 0, fmt.Errorf("invalid PORT %d: must be between %d and %d", port, minPort, maxPort)
	}

	return port, nil
}
