NAME = inception
COMPOSE = docker-compose -f ./srcs/docker-compose.yml
DATA_PATH = /home/hbettal/data

all: up

up: create_dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean: down
	docker system prune -af

fclean: down
	$(COMPOSE) down -v
	sudo rm -rf $(DATA_PATH)/wordpress/*
	sudo rm -rf $(DATA_PATH)/mariadb/*

re: fclean up

create_dirs:
	mkdir -p $(DATA_PATH)/wordpress
	mkdir -p $(DATA_PATH)/mariadb

.PHONY: all up down clean fclean re create_dirs
