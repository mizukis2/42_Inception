SECRETS_DIR = secrets
DB_ROOT_PASSWORD = $(SECRETS_DIR)/db_root_password.txt
DB_PASSWORD = $(SECRETS_DIR)/db_password.txt
WP_ADMIN_PASSWORD = $(SECRETS_DIR)/wp_admin_password.txt

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
	@docker compose up
	@echo "---Docker compose up---"

build: setup
	@docker compose up --build
	@echo "---Docker compose up --build---"

down:
	@docker compose down
	@echo "---Docker down---"

fdown:
	@docker compose down -v
	@echo "---Docker compose down fully---"
	@rm -rf $(SECRETS_DIR)

re: fdown
	@$(MAKE) build

.PHONY : setup up build down fdown re
