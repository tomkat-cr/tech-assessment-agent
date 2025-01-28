#!/bin/bash
# File: n8n/init-ottomator-data.sh
# 2025-01-20 | CR
# Create the database and user for the oTTomator Live Agent Studio.

set -e;

if [ -n "${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
	echo ""
	echo "Starting 'messages' table creation..."
	echo ""
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE TABLE messages
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            session_id TEXT NOT NULL,
            message JSONB NOT NULL
        );
        CREATE INDEX idx_messages_session_id ON messages(session_id);
        CREATE INDEX idx_messages_created_at ON messages(created_at);
	EOSQL
	echo ""
	echo "'messages' table creation done."
	echo ""
else
	echo ""
	echo "'messages' table creation INFO: No Environment variables given!"
	echo ""
fi
