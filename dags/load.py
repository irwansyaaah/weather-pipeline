import pandas as pd
import os
from datetime import datetime
import logging
from sqlalchemy import create_engine, text
import glob
from pathlib import Path
import pyarrow as pa
import pyarrow.parquet as pq

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Database configuration
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "weather_db")

# Directory configuration
TRANSFORMED_DATA_DIR = "data/transformed"
ANALYTICS_DATA_DIR = "data/analytics"

# Create necessary directories
os.makedirs(ANALYTICS_DATA_DIR, exist_ok=True)

def get_db_connection():
    """Create database connection"""
    try:
        connection_string = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
        engine = create_engine(connection_string)
        return engine
    except Exception as e:
        logger.error(f"Error creating database connection: {str(e)}")
        raise

def create_tables(engine):
    """Create necessary tables if they don't exist"""
    try:
        with engine.connect() as conn:
            # Create weather_data table
            conn.execute(text("""
                CREATE TABLE IF NOT EXISTS weather_data (
                    id SERIAL PRIMARY KEY,
                    city VARCHAR(100),
                    country VARCHAR(100),
                    timestamp TIMESTAMP,
                    temperature FLOAT,
                    feels_like FLOAT,
                    humidity FLOAT,
                    pressure FLOAT,
                    wind_speed FLOAT,
                    wind_direction FLOAT,
                    weather_description VARCHAR(100),
                    clouds FLOAT,
                    sunrise TIME,
                    sunset TIME,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """))
            conn.commit()
            logger.info("Database tables created successfully")
    except Exception as e:
        logger.error(f"Error creating database tables: {str(e)}")
        raise

def get_latest_transformed_file():
    """Get the latest transformed data file"""
    try:
        files = glob.glob(os.path.join(TRANSFORMED_DATA_DIR, "weather_data_*.csv"))
        if not files:
            logger.warning("No transformed data files found")
            return None
        return max(files, key=os.path.getctime)
    except Exception as e:
        logger.error(f"Error getting latest transformed file: {str(e)}")
        return None

def load_to_database(df, engine):
    """Load data into PostgreSQL database"""
    try:
        # Convert timestamp strings to datetime objects
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        df['sunrise'] = pd.to_datetime(df['sunrise']).dt.time
        df['sunset'] = pd.to_datetime(df['sunset']).dt.time
        
        # Load data to database
        df.to_sql('weather_data', engine, if_exists='append', index=False)
        logger.info(f"Successfully loaded {len(df)} records to database")
        return True
    except Exception as e:
        logger.error(f"Error loading data to database: {str(e)}")
        return False

def save_to_parquet(df):
    """Save data to Parquet format for analytics"""
    try:
        # Generate filename with timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        parquet_file = os.path.join(ANALYTICS_DATA_DIR, f'weather_data_{timestamp}.parquet')
        
        # Convert DataFrame to PyArrow Table
        table = pa.Table.from_pandas(df)
        
        # Write to Parquet file
        pq.write_table(table, parquet_file)
        logger.info(f"Successfully saved data to Parquet file: {parquet_file}")
        return True
    except Exception as e:
        logger.error(f"Error saving data to Parquet: {str(e)}")
        return False

def load_weather_data():
    """Main function to load weather data to database and save as Parquet"""
    try:
        # Get latest transformed data file
        latest_file = get_latest_transformed_file()
        if not latest_file:
            logger.error("No transformed data file found to load")
            return False

        # Read transformed data
        df = pd.read_csv(latest_file)
        
        # Create database connection
        engine = get_db_connection()
        
        # Create tables if they don't exist
        create_tables(engine)
        
        # Load to database
        db_success = load_to_database(df, engine)
        
        # Save to Parquet
        parquet_success = save_to_parquet(df)
        
        return db_success and parquet_success

    except Exception as e:
        logger.error(f"Error in load_weather_data: {str(e)}")
        return False

if __name__ == "__main__":
    load_weather_data() 