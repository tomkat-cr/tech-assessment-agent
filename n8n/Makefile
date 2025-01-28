# .DEFAULT_GOAL := local
# .PHONY: tests
SHELL := /bin/bash

# General Commands
help:
	cat Makefile

.PHONY: help

# Application Specific Commands

# Runs n8n in detached mode
run:
	sh run_n8n.sh

# Stops n8n
stop:
	sh run_n8n.sh stop

# Stop and removes n8n containers
down:
	sh run_n8n.sh down

# Shows n8n and postgres logs
logs:
	sh run_n8n.sh logs

# Upgrade n8n, postgress and pg_admin
update:
	sh run_n8n.sh update

# Restart docker containers
restart: down run

# Open n8n port (linux)
open:
	sh run_n8n.sh open

# Close n8n port (linux)
close:
	sh run_n8n.sh close

# Run n8n with force-recreate
force-recreate:
	sh run_n8n.sh force-recreate

# Enter to the n8n-postgres container
enter_pg:
	docker exec -ti n8n-postgres-1 bash

# Enter to the n8n container
enter_n8n:
	docker exec -ti n8n-n8n-1 sh
