# n8n/examples/supabase_test.py
# Test supabase connection
# 2025-01-22 | CR
#
# Requirements:
# pip install python-dotenv psycopg2

import psycopg2
from dotenv import load_dotenv
import os

# Load environment variables from .env
load_dotenv()

# Fetch variables
USER = os.getenv("SUPABASE_USR")
PASSWORD = os.getenv("SUPABASE_PSW")
HOST = os.getenv("SUPABASE_URL")
PORT = os.getenv("SUPABASE_PORT")
DBNAME = os.getenv("SUPABASE_DB")

print("")
print("Test connection to the Supabase database from Python...")
print("")
print(f"USER: {USER}")
print(f"PASSWORD: {PASSWORD}")
print(f"HOST: {HOST}")
print(f"PORT: {PORT}")
print(f"DBNAME: {DBNAME}")
print("")

# Connect to the database
try:
    connection = psycopg2.connect(
        user=USER,
        password=PASSWORD,
        host=HOST,
        port=PORT,
        dbname=DBNAME
    )
    print("Connection successful!")

    # Create a cursor to execute SQL queries
    cursor = connection.cursor()

    # Example query
    cursor.execute("SELECT NOW();")
    result = cursor.fetchone()
    print("Current Time:", result)

    # Close the cursor and connection
    cursor.close()
    connection.close()
    print("Connection closed.")

except Exception as e:
    print(f"Failed to connect: {e}")
