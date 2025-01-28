#!/bin/bash
# File: n8n/run_n8n.sh
# Run n8n automation tool
# 2025-01-15 | CR

# Reference:
# https://docs.n8n.io/hosting/installation/docker/

REPO_BASEDIR="`pwd`"
cd "`dirname "$0"`"
SCRIPTS_DIR="`pwd`"

if [ -f ".env" ]; then
    set -o allexport; . .env ; set +o allexport ;
else
    echo "Error: .env file not found."
    echo ""
    echo "Run the following command to create it:"
    echo "  cp .env.example .env"
    echo "  vi .env"
    echo "... and set the variables in it."
    echo ""
    cat .env.example
    echo ""
    exit 1
fi

if [ "$N8N_PORT" = "" ]; then
    export N8N_PORT="5678"
fi

if [ "$ACTION" = "" ]; then
    ACTION="$1"
fi
if [ "$ACTION" = "" ]; then
    ACTION="run"
fi

echo ""
echo "***************"
echo "* N8N MANAGER *"
echo "***************"
echo ""
echo "Action: $ACTION"

if [ "$ACTION" = "open" ]; then
    echo ""
    echo "Opening public access to port ${N8N_PORT} in the firewall"
    echo ""
    sh ../scripts/firewall_manager.sh open ${N8N_PORT}
fi

if [ "$ACTION" = "close" ]; then
    echo ""
    echo "Closing public access to port ${N8N_PORT} in the firewall"
    echo ""
    sh ../scripts/firewall_manager.sh close ${N8N_PORT}
fi

if [ "$ACTION" = "stop" ]; then
    echo ""
    echo "Stopping n8n"
    echo ""
    docker-compose stop
fi

if [ "$ACTION" = "down" ]; then
    echo ""
    echo "Stopping n8n"
    echo ""
    docker-compose down
fi

if [ "$ACTION" = "run" ]; then
    echo ""
    echo "Starting n8n"
    echo ""
    docker-compose up -d
    docker ps
    echo ""
    echo "Access n8n local server at http://127.0.0.1:${N8N_PORT}"
    echo ""
    echo "If you don't see the login or setup owner account page, please run the following commands:"
    echo ""    
    echo "docker exec -ti n8n-postgres-1 bash"
    echo "sh /docker-entrypoint-initdb.d/init-data.sh"
    echo ""
    echo "Press ENTER to continue with the logs or Ctrl-C to cancel."
    read answer ;
    docker-compose logs -f
fi

if [ "$ACTION" = "logs" ]; then
    echo ""
    echo "Displaying logs for all services"
    docker-compose logs -f
fi

if [ "$ACTION" = "update" ]; then
    echo ""
    echo "Updating n8n, postgres and pgadmin versions"
    echo ""
    echo ""
    # docker pull docker.n8n.io/n8nio/n8n:nightly
    docker-compose down
    docker-compose pull
    docker-compose up -d
fi

if [ "$ACTION" = "force-recreate" ]; then
    echo ""
    echo "Forcing recreate of all services"
    if docker ps | grep n8n ; then
        docker-compose down
    fi
    docker compose up --force-recreate -d
fi
