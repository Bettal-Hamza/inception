NAME = inception
COMPOSE = docker-compose -f ./srcs/docker-compose.yml
DATA_PATH = /home/hbettal/data

all: up

up: create_dirs
	@echo "Starting containers..."
	@$(COMPOSE) up -d --build

down:
	@echo "Stopping containers..."
	@$(COMPOSE) down

clean: down
	@echo "Cleaning containers and images..."
	@docker system prune -af

fclean: down
	@echo "Removing volumes and data..."
	@$(COMPOSE) down -v
	@sudo rm -rf $(DATA_PATH)/wordpress/*
	@sudo rm -rf $(DATA_PATH)/mariadb/*

re: fclean up

create_dirs:
	@echo "Creating data directories..."
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/mariadb

.PHONY: all up down clean fclean re create_dirs
