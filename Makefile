.PHONY: setup build up down exec zig logs

CP := cmd /c copy
USER_ID := 1
GROUP_ID := 1

ifneq ($(OS),Windows_NT)
  CP := cp
  USER_ID := $(shell id -u)
  GROUP_ID := $(shell id -g)
endif

# Adjust file permissions
adjust:
	docker compose run --rm app chown -f -R $(USER_ID):$(GROUP_ID) . | true

setup:
ifeq ($(wildcard compose.override.yml),)
	${CP} compose.override.sample.yml compose.override.yml
	docker compose build --no-cache
else
	@echo "compose.override.yml already exists."
endif

build:
	docker compose build

build-nocache:
	docker compose build --no-cache

resetdb:
	make down
	docker volume rm horizon_sample_pg_data | true
	docker volume rm horizon_sample_mysql_data | true

up:
	docker compose up -d

down:
	docker compose down

exec:
	docker compose exec $(filter-out $@,$(MAKECMDGOALS))
	@exit 3

run:
	docker compose run --rm --service-ports app $(filter-out $@,$(MAKECMDGOALS))
	@exit 3

zig:
	docker compose run --rm --service-ports app zig $(filter-out $@,$(MAKECMDGOALS))
	@exit 3

bun:
	docker compose run --rm --service-ports app bun $(filter-out $@,$(MAKECMDGOALS))
	@exit 3

logs:
	docker compose logs -f $(filter-out $@,$(MAKECMDGOALS))
	@exit 3
