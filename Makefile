.PHONY: help build-local run-local build-prod run-prod down lint

help:
	@echo "Available targets:"
	@echo "  build-local  : Build application locally (without Docker)"
	@echo "  run-local    : Run application locally (without Docker)"
	@echo "  build-prod   : Build Docker image for production"
	@echo "  run-prod     : Run production Docker container"
	@echo "  down         : Stop and remove Docker containers"
	@echo "  lint         : Run Kotlin linter/formatting"

# Local development (without Docker)
build-local:
	./gradlew clean build

run-local: build-local
	SPRING_PROFILES_ACTIVE=local ./gradlew bootRun

# Production Docker
build-prod:
	docker build -t my-spring-app:latest .

run-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

down:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml down


keycloak-up: fix-permissions
	@./bin/setup-keycloak.sh

fix-permissions:
	chmod +x bin/setup-keycloak.sh

keycloak-down:
	docker-compose down

lint:
	./gradlew ktlintCheck ktlintFormat