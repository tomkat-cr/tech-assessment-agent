#!/bin/bash
# File: n8n/init-data.sh
# 2025-01-15 | CR
# This script runs automatically when the docker-compose up command is run.

set -e;

if [ -n "${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
	echo ""
	echo "psql -v ON_ERROR_STOP=1 --username \"$POSTGRES_USER\" --dbname \"$POSTGRES_DB\" CREATE USER ${POSTGRES_NON_ROOT_USER} WITH PASSWORD '****'; GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_NON_ROOT_USER}; GRANT CREATE ON SCHEMA public TO ${POSTGRES_NON_ROOT_USER};"
	echo ""
	
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
		CREATE USER ${POSTGRES_NON_ROOT_USER} WITH PASSWORD '${POSTGRES_NON_ROOT_PASSWORD}';
		GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_NON_ROOT_USER};
		GRANT CREATE ON SCHEMA public TO ${POSTGRES_NON_ROOT_USER};
	EOSQL

	echo ""
	echo "User creation done."
	echo ""
else
	echo ""
	echo "SETUP INFO: No Environment variables given!"
	echo ""
fi
