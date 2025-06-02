import requests
import json
import time
from pathlib import Path

METABASE_URL = "http://localhost:3000"
METABASE_EMAIL = "admin@admin.com"
METABASE_PASSWORD = "admin"  # Anda bisa mengubah password ini

def setup_metabase():
    session = requests.Session()
    
    # Setup Metabase
    setup_data = {
        "token": None,
        "details": {
            "is_on_demand": False,
            "is_full_sync": False,
            "is_sample": False,
            "cache_ttl": None,
            "refingerprint": False,
            "auto_run_queries": True,
            "schedules": {},
            "details": {
                "dbname": "weather_db",
                "host": "postgres",
                "port": 5432,
                "user": "postgres",
                "password": "postgres",
                "schema": "weather"
            },
            "name": "Weather Database",
            "engine": "postgres"
        }
    }

    # Tunggu sampai Metabase siap
    max_retries = 30
    retry_count = 0
    while retry_count < max_retries:
        try:
            # Coba login
            login_data = {
                "username": METABASE_EMAIL,
                "password": METABASE_PASSWORD
            }
            response = session.post(f"{METABASE_URL}/api/session", json=login_data)
            
            if response.status_code == 200:
                print("Successfully logged in to Metabase")
                
                # Tambahkan database
                response = session.post(
                    f"{METABASE_URL}/api/database",
                    json=setup_data
                )
                
                if response.status_code == 200:
                    print("Successfully added PostgreSQL database to Metabase")
                    return True
                else:
                    print(f"Failed to add database: {response.text}")
                    return False
                    
        except requests.exceptions.ConnectionError:
            print(f"Waiting for Metabase to be ready... ({retry_count + 1}/{max_retries})")
            time.sleep(10)
            retry_count += 1
    
    raise Exception("Could not connect to Metabase")

def main():
    try:
        setup_metabase()
        print("\nSetup completed successfully!")
        print("You can now access Metabase at http://localhost:3000")
        print("Login with:")
        print(f"Email: {METABASE_EMAIL}")
        print("Password: admin123")
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    main() 