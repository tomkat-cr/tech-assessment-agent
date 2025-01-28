
#!/bin/sh
# n8n/examples/supabase_test.sh
# 2025-01-22 | CR

# Run:
# docker exec -ti n8n-postgres-1 sh /var/scripts/examples/supabase_test.sh
# 

REPO_BASEDIR="`pwd`"
cd "`dirname "$0"`"
SCRIPTS_DIR="`pwd`"

if [ -f "../.env" ]; then
    set -o allexport; . ../.env ; set +o allexport ;
else
    echo "Error: ../.env file not found."
    echo ""
    echo "Run the following command to create it:"
    echo "  cd /var/scripts"
    echo "  cp .env.example .env"
    echo "  vi .env"
    echo "... and set the variables in it."
    echo ""
    cat ../.env.example
    echo ""
    exit 1
fi

if [ "$SUPABASE_USR" = "" ]; then
    echo "ERROR: SUPABASE_USR must be set"
    exit 1
fi

if [ "$SUPABASE_PSW" = "" ]; then
    echo "ERROR: SUPABASE_PSW must be set"
    exit 1
fi

if [ "$SUPABASE_URL" = "" ]; then
    echo "ERROR: SUPABASE_URL must be set"
    exit 1
fi

if [ "$SUPABASE_PORT" = "" ]; then
    echo "ERROR: SUPABASE_PORT must be set"
    exit 1
fi

if [ "$SUPABASE_DB" = "" ]; then
    echo "ERROR: SUPABASE_DB must be set"
    exit 1
fi

if [ "$SUPABASE_PROJECT_REF_ID" = "" ]; then
    echo "ERROR: SUPABASE_PROJECT_REF_ID must be set"
    exit 1
fi

if [ "$SUPABASE_API_KEY" = "" ]; then
    echo "ERROR: SUPABASE_API_KEY must be set"
    exit 1
fi

cd "${SCRIPTS_DIR}"

echo ""
echo "Testing python installation"
if ! python3 --version
then
    apt update
    apt install -y python3 curl python3.11-venv
    if ! python3 --version
    then
        echo "Error: Python is not installed"
        exit 1
    fi
fi

echo ""
echo "Testing node.js installation"
if ! node --version
then
    curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh
    bash nodesource_setup.sh
    apt update
    apt install -y nodejs
    if ! node --version
    then
        echo "Error: node.js is not installed"
        exit 1
    fi
    if ! npm -v
    then
        echo "Error: npm is not installed"
        exit 1
    fi
fi

echo ""
echo "Removing existing python virtual environment"
if [ ! -d venv ]; then
    echo ""
    echo "Creating python virtual environment"
    if ! python3 -m venv venv
    then
        echo "Error: Could not create the venv directory"
        exit 1
    fi
fi

echo ""
echo "Activating python virtual environment"
. venv/bin/activate

echo ""
echo "Installing python-dotenv and psycopg2"
if [ -f supabase_test_requirements.txt ]; then
    pip install -r supabase_test_requirements.txt
else
    if ! pip install python-dotenv psycopg2
    then
        echo ""
        echo "Installing libpq-dev python3-dev required by psycopg2"
        echo ""
        apt update
        apt install -y libpq-dev python3-dev
        if ! pip install psycopg2-binary
        then
            echo "Error: Could not install psycopg2-binary"
            exit 1
        fi
        if ! pip install python-dotenv
        then
            echo "Error: Could not install python-dotenv and psycopg2"
            exit 1
        fi
    fi
    echo ""
    echo "Freezing supabase_test_requirements.txt"
    pip freeze > supabase_test_requirements.txt
fi

echo ""
echo "Running supabase_test.py"
echo ""
python3 supabase_test.py

if [ "$1" = "remove_venv" ]; then
    echo ""
    echo "Deactivating and removing python virtual environment"
    deactivate
    rm -rf venv
fi

echo ""
echo "Testing url calls"

if [ "$SUPABASE_TEST_TABLE_NAME" = "" ]; then
    SUPABASE_TEST_TABLE_NAME="messages"
fi
if [ "$SUPABASE_TEST_COLUMN_NAME" = "" ]; then
    SUPABASE_TEST_COLUMN_NAME="session_id"
fi
if [ "$SUPABASE_TEST_COLUMN_VALUE" = "" ]; then
    SUPABASE_TEST_COLUMN_VALUE="4843ad1a-b28b-45fe-a871-b69c0ee290b8"
fi
if [ "$SUPABASE_TEST_ORDER_BY" = "" ]; then
    SUPABASE_TEST_ORDER_BY="created_at"
fi

curl -X GET "https://${SUPABASE_PROJECT_REF_ID}.supabase.co/rest/v1/${SUPABASE_TEST_TABLE_NAME}?select=*&${SUPABASE_TEST_COLUMN_NAME}=eq.${SUPABASE_TEST_COLUMN_VALUE}&order=${SUPABASE_TEST_ORDER_BY}.asc" \
    -H "apikey: $SUPABASE_API_KEY " \
    -H "authorization: Bearer $SUPABASE_API_KEY"
echo ""

echo ""
echo "Testing supabase-cli installation"
if ! npx supabase --version
then
    echo ""
    echo "Installing supabase"
    if ! npm install -g -y supabase
    then
        echo "Error: Could not install supabase"
        exit 1
    fi
    if ! npx supabase --version
    then
        echo "Error: supabase is not installed"
        exit 1
    fi
fi

echo ""
echo "Supabase login (please follow the instructions)"
if ! npx supabase login
then
    echo "Error: Could not login to supabase"
    exit 1
fi
if ! npx supabase network-bans get --project-ref ${SUPABASE_PROJECT_REF_ID} --experimental
then
    echo "Error: Could not test supabase network-bans"
    exit 1
fi
echo ""
echo "If there are any banned IPs, use:"
echo "  docker exec -ti n8n-postgres-1 bash"
echo "  npx supabase network-bans remove --project-ref ${SUPABASE_PROJECT_REF_ID} --db-unban-ip 0.0.0.0 --experimental"
echo ""
echo "The result should be:"
echo "  Successfully removed bans for [0.0.0.0]."
echo ""
