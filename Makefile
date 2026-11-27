BINARY := bin/server
IMAGE  := go-cloud-native-app:local

CLUSTER   := gcn-local
KUBECTL   := kubectl --context kind-$(CLUSTER)

TRAEFIK_CHART_VERSION := 43.0.0

.PHONY: build run test lint fmt docker-build docker-run clean kind-up kind-down kind-load deploy-local ingress-local

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

kind-up:
	kind create cluster --name $(CLUSTER) --config kind/cluster.yaml

kind-down:
	kind delete cluster --name $(CLUSTER)

kind-load: docker-build
	kind load docker-image $(IMAGE) --name $(CLUSTER)

deploy-local: kind-load
	$(KUBECTL) apply -k k8s/overlays/local
	$(KUBECTL) -n gcn rollout restart deployment/api
	$(KUBECTL) -n gcn rollout status deployment/api --timeout=90s

ingress-local:
	helm repo add traefik https://traefik.github.io/charts 2>/dev/null || true
	helm repo update traefik
	helm upgrade --install traefik traefik/traefik \
	  --kube-context kind-$(CLUSTER) \
	  --namespace traefik --create-namespace \
	  --version $(TRAEFIK_CHART_VERSION) \
	  -f kind/traefik-values.yaml \
	  --wait

