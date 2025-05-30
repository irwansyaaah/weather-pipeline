from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import sys
import os

# Add the dags directory to the Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dags.extract import extract_weather_data
from dags.transform import transform_weather_data
from dags.load import load_weather_data

# Default arguments for the DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Create the DAG
dag = DAG(
    'weather_etl_pipeline',
    default_args=default_args,
    description='ETL pipeline for weather data collection',
    schedule_interval='0 */3 * * *',  # Run every 3 hours
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['weather', 'etl'],
)

# Define the tasks
extract_task = PythonOperator(
    task_id='extract_weather_data',
    python_callable=extract_weather_data,
    dag=dag,
)

transform_task = PythonOperator(
    task_id='transform_weather_data',
    python_callable=transform_weather_data,
    dag=dag,
)

load_task = PythonOperator(
    task_id='load_weather_data',
    python_callable=load_weather_data,
    dag=dag,
)

# Set task dependencies
extract_task >> transform_task >> load_task 