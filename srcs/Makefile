NAME = inception
COMPOSE = docker-compose
UID := $(shell id -u)

all: up

up:
	@echo "🔧 Starting containers..."
	@sudo $(COMPOSE) up -d --build

down:
	@echo "🛑 Stopping containers..."
	@sudo $(COMPOSE) down

fclean: down
	@echo "🔥 Removing volumes..."
	@sudo docker volume rm db_data wp_data || true

re: fclean up