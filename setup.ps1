# PowerShell script for managing the ETL pipeline

# Function to start all services
function Start-Services {
    Write-Host "Starting all services..."
    docker-compose up -d
    Write-Host "Services started. Access points:"
    Write-Host "- Metabase: http://localhost:3000"
    Write-Host "- Airflow: http://localhost:8080"
    Write-Host "- Jupyter: http://localhost:8888"
    Write-Host "- Spark UI: http://localhost:8080"
    Write-Host "- DataHub: http://localhost:9002"
}

# Function to stop all services
function Stop-Services {
    Write-Host "Stopping all services..."
    docker-compose down
    Write-Host "Services stopped"
}

# Function to initialize the environment
function Initialize-Environment {
    Write-Host "Creating necessary directories..."
    New-Item -ItemType Directory -Force -Path data/raw
    New-Item -ItemType Directory -Force -Path data/transformed
    New-Item -ItemType Directory -Force -Path data/analytics
    New-Item -ItemType Directory -Force -Path logs
    New-Item -ItemType Directory -Force -Path plugins
    New-Item -ItemType Directory -Force -Path notebooks
    New-Item -ItemType Directory -Force -Path dags

    Write-Host "Starting services..."
    Start-Services

    Write-Host "Waiting for PostgreSQL to be ready..."
    Start-Sleep -Seconds 10

    Write-Host "Environment initialized successfully!"
}

# Function to clean up the environment
function Clean-Environment {
    Write-Host "Stopping services..."
    Stop-Services

    Write-Host "Removing data directories..."
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue data
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue logs
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue plugins
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue notebooks
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue dags

    Write-Host "Removing Docker volumes..."
    docker volume rm weather_data_pipeline_postgres_data
    docker volume rm weather_data_pipeline_metabase_data
    docker volume rm weather_data_pipeline_spark_data
    docker volume rm weather_data_pipeline_datahub_data

    Write-Host "Environment cleaned up"
}

# Function to show logs
function Show-Logs {
    param (
        [string]$Service = ""
    )
    
    if ($Service) {
        docker-compose logs -f $Service
    } else {
        docker-compose logs -f
    }
}

# Function to initialize database
function Initialize-Database {
    Write-Host "Initializing database..."
    docker-compose exec postgres psql -U postgres -d weather_db -f /docker-entrypoint-initdb.d/init.sql
    Write-Host "Database initialized"
}

# Function to test database connection
function Test-Database {
    Write-Host "Testing database connection..."
    docker-compose exec postgres psql -U postgres -d weather_db -c "SELECT version();"
}

# Function to get Jupyter token
function Get-JupyterToken {
    Write-Host "Getting Jupyter token..."
    docker-compose exec jupyter jupyter server list
}

# Function to restart a specific service
function Restart-Service {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Service
    )
    Write-Host "Restarting $Service..."
    docker-compose restart $Service
}

# Function to build Docker images
function Build-Images {
    param (
        [string]$Service = ""
    )
    
    if ($Service) {
        Write-Host "Building $Service image..."
        docker-compose build $Service
    } else {
        Write-Host "Building all images..."
        docker-compose build
    }
}

# Function to rebuild and restart a service
function Rebuild-Service {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Service
    )
    Write-Host "Rebuilding and restarting $Service..."
    docker-compose up -d --build $Service
}

# Main script
Write-Host "Weather Data Pipeline Management Script"
Write-Host "----------------------------------------"
Write-Host "Available commands:"
Write-Host "1. Initialize-Environment - Create directories and start services"
Write-Host "2. Start-Services - Start all services"
Write-Host "3. Stop-Services - Stop all services"
Write-Host "4. Show-Logs [service] - Show logs (optional: specify service)"
Write-Host "5. Initialize-Database - Initialize database tables"
Write-Host "6. Test-Database - Test database connection"
Write-Host "7. Clean-Environment - Stop services and remove data"
Write-Host "8. Get-JupyterToken - Get Jupyter access token"
Write-Host "9. Restart-Service [service] - Restart a specific service"
Write-Host "10. Build-Images [service] - Build Docker images (optional: specify service)"
Write-Host "11. Rebuild-Service [service] - Rebuild and restart a service"
Write-Host "----------------------------------------"

# Main script
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('up', 'down', 'init', 'clean', 'logs', 'init-db', 'test-db', 'jupyter-token', 'restart', 'build', 'rebuild')]
    [string]$Command,
    [string]$Service = ""
)

switch ($Command) {
    'up' { Start-Services }
    'down' { Stop-Services }
    'init' { Initialize-Environment }
    'clean' { Clean-Environment }
    'logs' { Show-Logs -Service $Service }
    'init-db' { Initialize-Database }
    'test-db' { Test-Database }
    'jupyter-token' { Get-JupyterToken }
    'restart' { Restart-Service -Service $Service }
    'build' { Build-Images -Service $Service }
    'rebuild' { Rebuild-Service -Service $Service }
} 