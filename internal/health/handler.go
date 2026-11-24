// Package health provides the liveness endpoint handler.
package health

import (
	"encoding/json"
	"net/http"
)

const statusOK = "ok"

type response struct {
	Status string `json:"status"`
}

// Handler reports that the process is alive and able to serve HTTP.
type Handler struct{}

// NewHandler returns a health Handler.
func NewHandler() *Handler {
	return &Handler{}
}

// ServeHTTP writes a 200 response with a JSON status body.
func (h *Handler) ServeHTTP(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(response{Status: statusOK})
}
