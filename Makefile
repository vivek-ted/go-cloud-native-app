BINARY := bin/server
IMAGE  := go-cloud-native-app:local

.PHONY: build run test lint fmt docker-build docker-run clean

build:
	go build -o $(BINARY) ./cmd/server

run:
	go run ./cmd/server

test:
	go test -race ./...

lint:
	go vet ./...
	@command -v golangci-lint >/dev/null && golangci-lint run ./... || echo "golangci-lint not installed; ran go vet only"

fmt:
	gofmt -s -w .

docker-build:
	docker build -t $(IMAGE) .

docker-run:
	docker run --rm -p 8080:8080 $(IMAGE)

clean:
	rm -rf bin
