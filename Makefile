SECRETS_DIR = secrets
DB_ROOT_PASSWORD = $(SECRETS_DIR)/db_root_password.txt
DB_PASSWORD = $(SECRETS_DIR)/db_password.txt
WP_ADMIN_PASSWORD = $(SECRETS_DIR)/wp_admin_password.txt
COMPOSE_FILE = srcs/docker-compose.yml

setup:
	@echo "---set up secrets---"
	@mkdir -p $(SECRETS_DIR)
	@if [ ! -f $(DB_ROOT_PASSWORD) ]; then \
		openssl rand -base64 32 > $(DB_ROOT_PASSWORD); \
	fi
	@if [ ! -f $(DB_PASSWORD) ]; then \
	openssl rand -base64 32 > $(DB_PASSWORD); \
	fi
	@if [ ! -f $(WP_ADMIN_PASSWORD) ]; then \
	openssl rand -base64 32 > $(WP_ADMIN_PASSWORD); \
	fi

up: setup
	@docker compose -f $(COMPOSE_FILE) up
	@echo "---Docker compose up---"

build: setup
	@docker compose -f $(COMPOSE_FILE) up --build
	@echo "---Docker compose up --build---"

down:
	@docker compose -f $(COMPOSE_FILE) down
	@echo "---Docker down---"

fdown:
	@docker compose -f $(COMPOSE_FILE) down -v
	@echo "---Docker compose down fully---"
	@rm -rf $(SECRETS_DIR)

re: fdown
	@$(MAKE) build

.PHONY : setup up build down fdown re
