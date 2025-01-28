
#!/bin/sh
# github_profile_reader_test.sh
# 2025-01-22 | CR

# Usage:
# sh ./n8n/agent_tools/github_profile_reader_test.sh 

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

cd "${SCRIPTS_DIR}"

echo ""
echo "Checking for existing python virtual environment"
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
echo "Installing python-dotenv and other dependencies"
if [ -f github_profile_reader_requirements.txt ]; then
    pip install -r github_profile_reader_requirements.txt
else
    if ! pip install requests beautifulsoup4
    then
        echo "Error: Could not install requests and beautifulsoup4"
        exit 1
    fi
    echo ""
    echo "Freezing github_profile_reader_requirements.txt"
    pip freeze > github_profile_reader_requirements.txt
fi

echo ""
echo "Running github_profile_reader_test.py"
echo ""
python3 github_profile_reader_test.py

if [ "$1" = "remove_venv" ]; then
    echo ""
    echo "Deactivating and removing python virtual environment"
    deactivate
    rm -rf venv
fi

echo ""
echo "Done"
