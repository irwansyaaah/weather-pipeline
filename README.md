# Weather Data Pipeline

A comprehensive data pipeline for collecting, processing, and analyzing weather data using modern data engineering tools and practices.

## 🚀 Features

- **Data Collection**: Automated weather data collection from multiple cities
- **Data Processing**: ETL pipeline using Apache Airflow
- **Data Storage**: PostgreSQL database for structured data storage
- **Data Analysis**: Jupyter notebooks with PySpark for data analysis
- **Data Visualization**: Metabase dashboards for data visualization
- **Data Quality**: DataHub for data quality monitoring
- **Streaming**: Kafka for real-time data streaming
- **Big Data Processing**: Apache Spark for distributed data processing

## 🛠️ Tech Stack

- **Orchestration**: Apache Airflow
- **Database**: PostgreSQL
- **Data Processing**: Apache Spark
- **Data Analysis**: Jupyter Notebooks
- **Data Visualization**: Metabase
- **Data Quality**: DataHub
- **Message Queue**: Apache Kafka
- **Containerization**: Docker
- **Scripting**: Python, PowerShell

## 📋 Prerequisites

- Docker and Docker Compose
- PowerShell (for Windows users)
- Git

## 🚀 Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/irwansyaaah/weather-pipeline.git
   cd weather-pipeline
   ```

2. Initialize the environment:
   ```powershell
   .\setup.ps1 init
   ```

3. Start the services:
   ```powershell
   .\setup.ps1 up
   ```

## 🔧 Available Commands

- Initialize environment:
  ```powershell
  .\setup.ps1 init
  ```

- Start services:
  ```powershell
  .\setup.ps1 up
  ```

- Stop services:
  ```powershell
  .\setup.ps1 down
  ```

- View logs:
  ```powershell
  .\setup.ps1 logs [service]
  ```

- Initialize database:
  ```powershell
  .\setup.ps1 init-db
  ```

- Test database connection:
  ```powershell
  .\setup.ps1 test-db
  ```

- Get Jupyter token:
  ```powershell
  .\setup.ps1 jupyter-token
  ```

- Restart a service:
  ```powershell
  .\setup.ps1 restart [service]
  ```

- Build Docker images:
  ```powershell
  .\setup.ps1 build [service]
  ```

- Rebuild and restart a service:
  ```powershell
  .\setup.ps1 rebuild [service]
  ```

- Clean environment:
  ```powershell
  .\setup.ps1 clean
  ```

## 🌐 Service Access

- **Metabase**: http://localhost:3000
- **Airflow**: http://localhost:8080
- **Jupyter**: http://localhost:8888
- **Spark UI**: http://localhost:8080
- **DataHub**: http://localhost:9002
- **PostgreSQL**: localhost:5432
- **Kafka**: localhost:9092
- **Zookeeper**: localhost:2181

## 📊 Database Schema

The project uses a PostgreSQL database with the following structure:

### Tables
- `weather.weather_data`: Main table for weather measurements
- `weather.daily_weather_summary`: Daily aggregated weather data
- `weather.city_weather_stats`: City-level weather statistics
- `weather.weather_alerts`: Weather alerts and notifications
- `weather.country_weather_comparison`: Country-level weather comparison

### Views
- Daily weather summary
- City weather statistics
- Weather alerts
- Country weather comparison

## 📈 Data Flow

1. **Data Collection**: Weather data is collected from various sources
2. **Data Processing**: Data is processed using Apache Airflow DAGs
3. **Data Storage**: Processed data is stored in PostgreSQL
4. **Data Analysis**: Data is analyzed using Jupyter notebooks
5. **Data Visualization**: Results are visualized in Metabase
6. **Data Quality**: Data quality is monitored using DataHub

## 🔐 Security

- All services are containerized and isolated
- Database credentials are managed through environment variables
- Airflow authentication is enabled
- Metabase authentication is required
- DataHub authentication is required
<<<<<<< HEAD

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request
=======
>>>>>>> bae940fd48d2bf734813bfb689e1af4fc40c8ffb
