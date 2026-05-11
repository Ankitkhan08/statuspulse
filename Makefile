IMAGE_NAME   := statuspulse
CONTAINER    := statuspulse_app
HEALTH_URL   := http://localhost:8000/health
COMPOSE_FILE := docker-compose.yml

COMPOSE := $(shell docker compose version > /dev/null 2>&1 && echo "docker compose" || echo "docker-compose")

.PHONY: build up down logs test clean shell help

help:
	@echo "make build   - Build the Docker image"
	@echo "make up      - Start all services"
	@echo "make down    - Stop all services"
	@echo "make logs    - Tail logs"
	@echo "make test    - Health check via curl"
	@echo "make clean   - Remove containers, images, volumes"
	@echo "make shell   - Open bash in app container"

build:
	@echo ">>> Building image..."
	docker build -t $(IMAGE_NAME):latest .
	docker images $(IMAGE_NAME):latest

up:
	@[ -f .env ] || cp .env.example .env
	$(COMPOSE) -f $(COMPOSE_FILE) up -d --build
	@sleep 5
	$(COMPOSE) -f $(COMPOSE_FILE) ps

down:
	$(COMPOSE) -f $(COMPOSE_FILE) down

logs:
	$(COMPOSE) -f $(COMPOSE_FILE) logs -f

test:
	@echo ">>> Testing /health endpoint..."
	@curl -sf $(HEALTH_URL) | python3 -m json.tool || \
		(echo "FAIL: health check failed" && exit 1)
	@echo "PASS: health check succeeded"

clean:
	$(COMPOSE) -f $(COMPOSE_FILE) down -v --remove-orphans
	docker rmi $(IMAGE_NAME):latest 2>/dev/null || true

shell:
	docker exec -it $(CONTAINER) /bin/bash