# Weather Data Pipeline

This project implements an ETL (Extract, Transform, Load) pipeline for weather data using Apache Airflow. The pipeline extracts weather data from an API, transforms it, and loads it into a database.

## Project Structure

```
weather_data_pipeline/
├── dags/                   # Airflow DAGs directory
│   └── weather_etl.py      # Main ETL DAG definition
├── scripts/                # ETL scripts
│   ├── extract.py          # Data extraction script
│   ├── transform.py        # Data transformation script
│   └── load.py            # Data loading script
├── data/                   # Data directory
│   ├── raw/               # Raw data storage
│   ├── processed/         # Processed data storage
│   └── interim/           # Intermediate data storage
├── tests/                  # Test files
│   └── __init__.py
├── logs/                   # Airflow logs (gitignored)
├── plugins/               # Airflow plugins directory
├── Dockerfile             # Container definition
├── docker-compose.yml     # Docker Compose configuration
├── requirements.txt       # Python dependencies
├── .env                   # Environment variables (gitignored)
├── .gitignore            # Git ignore rules
└── README.md             # Project documentation
```

## Setup

1. Create a `.env` file with the following variables:
   ```
   WEATHER_API_KEY=your_api_key
   DB_HOST=your_db_host
   DB_PORT=your_db_port
   DB_NAME=your_db_name
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   ```

2. Build and start the containers:
   ```bash
   docker-compose up --build
   ```

3. Access the Airflow web interface at `http://localhost:8080`

## Dependencies

- Python 3.8+
- Apache Airflow
- PostgreSQL
- Docker & Docker Compose

## Usage

The pipeline runs automatically according to the schedule defined in the DAG. You can also trigger it manually through the Airflow web interface.

## Development

1. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run tests:
   ```bash
   pytest tests/
   ```

## License

MIT 