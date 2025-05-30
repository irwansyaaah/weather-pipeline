FROM apache/airflow:2.7.1

USER root

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        postgresql-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

# Copy requirements file
COPY requirements.txt /requirements.txt

# Install Python dependencies
RUN pip install --no-cache-dir -r /requirements.txt

# Copy project files
COPY dags/ /opt/airflow/dags/
COPY scripts/ /opt/airflow/scripts/

# Set environment variables
ENV PYTHONPATH=/app:$PYTHONPATH

# Command to run (e.g., if you run a single script)
# CMD ["python", "scripts/extract.py"]