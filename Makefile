POSTGRES_IMAGE := postgres:11.3-alpine
POSTGRES_CONTAINER := changeme_db
POSTGRES_DATA := changeme_database

REDIS_IMAGE := redis:5.0.5-alpine
REDIS_CONTAINER := changeme_redis
REDIS_DATA := changeme_redis

.DEFAULT_GOAL := help
args = `arg="sh -c "$(filter-out $@,$(MAKECMDGOALS))"`

.PHONY: db redis start help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-z%A-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

db: db-start ## Run db:start

db%start: ## Run a postgres container on locaohost:5432
	${INFO} 'Running db container on localhost:5432 ...'
	@ docker run --rm -d --name=$(POSTGRES_CONTAINER) -v $(POSTGRES_DATA):/var/lib/postgresql/data -p 5432:5432 $(POSTGRES_IMAGE)

db%stop: ## Stop and remove a postgres container
	${INFO} "Stoping db container ..."
	@ docker stop $(POSTGRES_CONTAINER)
	${INFO} "Done"

db%exec: ## Connect to a running postgres container for executing commands; run shell by default
	${INFO} "Connect to running db container ..."
	@ docker exec -it $(POSTGRES_CONTAINER) $(call args,sh)

# make db:exec
# make db:exec "psql -U postgres"
# make db:exec "psql -U postgres -c 'create database compare_dev'"

redis: redis-start

redis%start: ## Start a redis container
	${INFO} "Running redis container on localhost:6379 ..."
	@ docker run --rm -d --name=$(REDIS_CONTAINER) -v $(REDIS_DATA):/data -p 6379:6379 $(REDIS_IMAGE) redis-server --appendonly yes

redis%stop: ## Stop a redis container
	${INFO} "Stoping redis container ..."
	@ docker stop $(REDIS_CONTAINER)
	${INFO} "Done"

start: start%all ## Run start:all
start%all: db-start redis-start ## Start all services (postgres, redis)
stop%all:	db%stop redis%stop ## Stop all services (postgres, redis)

%:
	@:

# Cosmetic
YELLOW := "\e[1;33m"
NC := "\e[0m"
INFO := @bash -c ' printf $(YELLOW); echo "=> $$1"; printf $(NC)' VALUE
