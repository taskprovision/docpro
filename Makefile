.PHONY: help install start stop restart status logs clean test backup restore

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

## Show this help
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/(^[a-zA-Z\-\_0-9]+:.*?##.*$$)|(^##)/ { \
		https://www.gnu.org/software/make/manual/html_node/Special-Variables.html#Special-Variables
		if ($$1 ~ /^[a-z\-]+:.*?##.*$$/) { \
			printf "  ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2 \
		} else if ($$1 ~ /^## .*$$/) { \
			printf "${YELLOW}%s${RESET}\n", substr($$1,4) \
		} \
	}' $(MAKEFILE_LIST)

## Install project dependencies
install: .env ## Install project dependencies
	@echo "${GREEN}🚀 Installing project dependencies...${RESET}"
	./install.sh

## Start all services
dev: .env ## Start all services in development mode
	@echo "${GREEN}🚀 Starting DocPro in development mode...${RESET}
${YELLOW}Access services at:${RESET}
- MinIO: http://localhost:9001 (minioadmin/minioadmin)\n- Elasticsearch: http://localhost:9200\n- Kibana: http://localhost:5601${RESET}"
	docker-compose up -d

## Stop all services
stop: ## Stop all services
	@echo "${YELLOW}🛑 Stopping all services...${RESET}"
	docker-compose down

## Restart all services
restart: stop dev ## Restart all services

## Show services status
status: ## Show services status
	@echo "${GREEN}📊 Services status:${RESET}"
	docker-compose ps

## Show services logs
logs: ## Show services logs (follow mode)
	docker-compose logs -f

## Clean up all containers, networks, and volumes
clean: ## Clean up all containers, networks, and volumes
	@echo "${YELLOW}🧹 Cleaning up...${RESET}"
	docker-compose down -v --remove-orphans
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

## Setup environment file if it doesn't exist
.env:
	@if [ ! -f .env ]; then \
		echo "${YELLOW}⚠️  .env file not found. Creating from .env.example...${RESET}"; \
		cp .env.example .env; \
		echo "${GREEN}✅ .env file created. Please edit it with your configuration.${RESET}"; \
	fi

## Show help by default
.DEFAULT_GOAL := help
