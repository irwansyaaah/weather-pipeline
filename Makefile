version: "3.8"

.PHONY: up down init clean logs metabase upload-metabase postgres setup-metabase

# Start all services
up:
	docker-compose up -d

# Stop all services
down:
	docker-compose down

# Initialize the environment
init:
	mkdir -p data/raw data/transformed data/analytics logs plugins
	docker-compose up -d postgres
	sleep 10  # Wait for postgres to be ready
	docker-compose up -d airflow-webserver airflow-scheduler

# Clean up all data and containers
clean:
	docker-compose down -v
	rm -rf data logs plugins

# View logs
logs:
	docker-compose logs -f

# Create database tables
init-db:
	docker-compose exec postgres psql -U airflow -d weather_db -c "\dt"

# Test database connection
test-db:
	docker-compose exec postgres pg_isready -U airflow -d weather_db

# Start Metabase
metabase:
	@echo '__________________________________________________________'
	@echo 'Creating Metabase Instance ...'
	@echo '__________________________________________________________'
	@docker-compose up -d metabase
	@echo '==========================================================='

# Upload CSV to Metabase
upload-metabase:
	python scripts/upload_to_metabase.py 

# Start PostgreSQL
postgres:
	docker-compose up -d postgres
	sleep 10  # Wait for postgres to be ready
	docker-compose exec postgres psql -U postgres -c "CREATE SCHEMA IF NOT EXISTS weather;"
	docker-compose exec postgres psql -U postgres -d weather_db -f /docker-entrypoint-initdb.d/init.sql 

# Setup Metabase with PostgreSQL
setup-metabase:
	python scripts/setup_metabase.py