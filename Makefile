.PHONY: help install dev stop restart status logs clean test backup restore setup samples docs lint format check-env reset-db monitor open-docs

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

## Show this help
help: ## Show this help message
	@echo ''
	@echo '${YELLOW}Document Processing System${RESET}'
	@echo '${YELLOW}========================${RESET}'
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z\-\_0-9]+:.*?## / {printf "  ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
	@echo ''
	@echo '${YELLOW}Service URLs:${RESET}'
	@echo '  - MinIO Console:     http://localhost:9001'
	@echo '  - Kibana:            http://localhost:5601'
	@echo '  - Node-RED:          http://localhost:1880'
	@echo '  - Elasticsearch:     http://localhost:9200'
	@echo '  - Tika Server:       http://localhost:9998'
	@echo ''

## Install project dependencies
install: check-env ## Install project dependencies and setup environment
	@echo "${GREEN}🚀 Installing project dependencies...${RESET}"
	@if [ -f "./install.sh" ]; then \
		chmod +x ./install.sh && \
		./install.sh; \
	else \
		echo "${YELLOW}⚠️  install.sh not found. Running docker-compose up...${RESET}" && \
		docker-compose up -d --build; \
	fi

## Start all services
dev: check-env ## Start all services in development mode
	@echo "${GREEN}🚀 Starting Document Processing System...${RESET}"
	@echo "${YELLOW}Using configuration from .env${RESET}"
	docker-compose up -d --build --remove-orphans
	@echo "${GREEN}✅ Services started${RESET}"
	@$(MAKE) --no-print-directory help | grep -A 10 'Service URLs'

## Stop all services
stop: ## Force stop all services and remove containers
	@echo "${YELLOW}🛑 Stopping all services...${RESET}"
	@if [ -n "$(shell docker-compose ps -q 2>/dev/null)" ]; then \
		docker-compose down --remove-orphans --timeout 2 || true; \
	fi
	@echo "${GREEN}✅ All services stopped${RESET}"

## Restart all services
restart: ## Force restart all services
	@echo "${YELLOW}🔄 Force restarting all services...${RESET}"
	@$(MAKE) stop
	@echo "${GREEN}Starting services...${RESET}"
	@$(MAKE) dev
	@echo "${GREEN}✅ All services restarted${RESET}"

## Show services status
status: ## Show services status
	@echo "${GREEN}📊 Services status:${RESET}"
	docker-compose ps

## Show services logs
logs: ## Show services logs (follow mode)
	docker-compose logs -f

## Clean up all containers, networks, and volumes
clean: ## Force clean up all containers, networks, and volumes
	@echo "${YELLOW}🧹 Cleaning up all resources...${RESET}"
	@echo "${YELLOW}⚠️  WARNING: This will remove all containers, networks, and volumes. Continue? [y/N] ${RESET}"
	@read -p "" confirm && [ $$confirm = y ] || [ $$confirm = Y ] || (echo "${YELLOW}Clean cancelled${RESET}"; exit 1)
	@if [ -n "$(shell docker-compose ps -q 2>/dev/null)" ]; then \
		docker-compose down -v --remove-orphans --rmi all --timeout 2 || true; \
	fi
	@echo "${YELLOW}Removing unused containers, networks, and volumes...${RESET}"
	@docker system prune -af --volumes
	@echo "${GREEN}✅ Clean complete!${RESET}"

## Run tests
test: ## Run tests
	@echo "${GREEN}🧪 Running tests...${RESET}"
	@if [ -f "./scripts/test-flow.sh" ]; then \
		./scripts/test-flow.sh; \
	else \
		echo "${YELLOW}Test script not found at ./scripts/test-flow.sh${RESET}"; \
	fi

## Setup Elasticsearch indices
setup: ## Setup Elasticsearch indices and mappings
	@echo "${GREEN}🛠️  Setting up Elasticsearch indices...${RESET}"
	@if [ -f "./scripts/setup-indices.sh" ]; then \
		./scripts/setup-indices.sh; \
	else \
		echo "${YELLOW}Setup script not found at ./scripts/setup-indices.sh${RESET}"; \
	fi

## Upload sample documents
samples: ## Upload sample documents to MinIO
	@echo "${GREEN}📤 Uploading sample documents...${RESET}"
	@if [ -f "./scripts/upload-samples.sh" ]; then \
		./scripts/upload-samples.sh; \
	else \
		echo "${YELLOW}Upload script not found at ./scripts/upload-samples.sh${RESET}"; \
	fi

## Create a backup
backup: ## Create a backup of the current state
	@echo "${GREEN}💾 Creating backup...${RESET}"
	./scripts/backup.sh

## Restore from backup
restore: ## Restore from the latest backup
	@echo "${YELLOW}⚠️  WARNING: This will overwrite current data. Continue? [y/N] ${RESET}"
	@read -p "" confirm && [ $$confirm = y ] || [ $$confirm = Y ] || (echo "${YELLOW}Restore cancelled${RESET}"; exit 1)
	@echo "${GREEN}🔄 Restoring from backup...${RESET}"
	@if [ -f "./scripts/restore.sh" ]; then \
		./scripts/restore.sh; \
	else \
		echo "${YELLOW}Restore script not found at ./scripts/restore.sh${RESET}"; \
	fi

## Check if environment is properly set up
check-env:
	@if [ ! -f .env ]; then \
		echo "${YELLOW}⚠️  .env file not found. Creating from .env.example...${RESET}"; \
		cp -n .env.example .env 2>/dev/null || true; \
		echo "${GREEN}✅ .env file created. Please edit it with your configuration.${RESET}"; \
	fi

## Reset the database (Elasticsearch indices and MinIO data)
reset-db: check-env ## Reset the database (Elasticsearch and MinIO)
	@echo "${YELLOW}⚠️  WARNING: This will delete all data. Continue? [y/N] ${RESET}"
	@read -p "" confirm && [ $$confirm = y ] || [ $$confirm = Y ] || (echo "${YELLOW}Reset cancelled${RESET}"; exit 1)
	@echo "${YELLOW}🧹 Resetting database...${RESET}"
	@docker-compose stop elasticsearch minio
	@rm -rf data/elasticsearch/* data/minio/*
	@echo "${GREEN}✅ Database reset complete. Run 'make dev' to restart services.${RESET}

## Generate documentation
docs: ## Generate project documentation
	@echo "${GREEN}📚 Generating documentation...${RESET}"
	@if [ ! -d "docs" ]; then \
		mkdir -p docs; \
	fi
	@if [ -f "./scripts/generate-docs.sh" ]; then \
		./scripts/generate-docs.sh; \
	else \
		echo "${YELLOW}Documentation generation script not found${RESET}"; \
	fi

## Open documentation in browser
open-docs: ## Open documentation in default browser
	@if [ -f "docs/index.html" ]; then \
		xdg-open docs/index.html 2>/dev/null || open docs/index.html 2>/dev/null || \
		echo "${YELLOW}Could not open documentation. Open 'docs/index.html' manually.${RESET}"; \
	else \
		echo "${YELLOW}Documentation not found. Run 'make docs' first.${RESET}"; \
	fi

## Lint code
lint: ## Run code linters
	@echo "${GREEN}🔍 Running linters...${RESET}"
	@if [ -f "package.json" ]; then \
		echo "${YELLOW}Running JavaScript/TypeScript linter...${RESET}" && \
		npm run lint || true; \
	fi
	@if [ -f "requirements.txt" ]; then \
		echo "${YELLOW}Running Python linter...${RESET}" && \
		pip install -q pylint && pylint **/*.py || true; \
	fi

## Format code
format: ## Format code
	@echo "${GREEN}🎨 Formatting code...${RESET}"
	@if [ -f "package.json" ]; then \
		echo "${YELLOW}Formatting JavaScript/TypeScript...${RESET}" && \
		npm run format || true; \
	fi
	@if [ -f "requirements.txt" ]; then \
		echo "${YELLOW}Formatting Python...${RESET}" && \
		pip install -q black isort && \
		black . && isort . || true; \
	fi

## Monitor system resources
monitor: ## Monitor system resources (CPU, memory, disk)
	@echo "${GREEN}📊 Monitoring system resources...${RESET}"
	@echo "${YELLOW}Press Ctrl+C to exit${RESET}"
	@if command -v htop &> /dev/null; then \
		htop; \
	else \
		top; \
	fi

## Show help by default
.DEFAULT_GOAL := help
