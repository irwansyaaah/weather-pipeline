# Weather Database Schema

This directory contains SQL files for setting up the weather database schema. Follow these steps to set up the database:

## Setup Steps

1. Connect to PostgreSQL as superuser:
   ```
   Host: localhost
   Port: 5432
   Database: postgres
   Username: postgres
   Password: postgres
   ```

2. Create the database and schema:
   ```sql
   -- Create the database
   CREATE DATABASE weather_db;

   -- Connect to the new database
   \c weather_db;

   -- Create the schema
   CREATE SCHEMA weather;

   -- Set the search path
   SET search_path TO weather, public;
   ```

3. Create the table and indexes:
   ```sql
   -- Create weather_data table
   CREATE TABLE weather.weather_data (
       city VARCHAR(100),
       country VARCHAR(2),
       timestamp TIMESTAMP,
       temperature DECIMAL(5,2),
       feels_like DECIMAL(5,2),
       humidity INTEGER,
       pressure INTEGER,
       wind_speed DECIMAL(5,2),
       wind_direction INTEGER,
       weather_description VARCHAR(100),
       clouds INTEGER,
       sunrise TIME,
       sunset TIME,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Create indexes
   CREATE INDEX idx_weather_data_city ON weather.weather_data(city);
   CREATE INDEX idx_weather_data_country ON weather.weather_data(country);
   CREATE INDEX idx_weather_data_timestamp ON weather.weather_data(timestamp);
   CREATE INDEX idx_weather_data_temperature ON weather.weather_data(temperature);
   CREATE INDEX idx_weather_data_humidity ON weather.weather_data(humidity);
   CREATE INDEX idx_weather_data_pressure ON weather.weather_data(pressure);
   CREATE INDEX idx_weather_data_wind_speed ON weather.weather_data(wind_speed);
   ```

## Schema Structure

### Tables

#### weather_data
Main table storing weather measurements:
- `city`: City name (VARCHAR(100))
- `country`: Country code (VARCHAR(2))
- `timestamp`: Measurement timestamp (TIMESTAMP)
- `temperature`: Temperature in Celsius (DECIMAL(5,2))
- `feels_like`: "Feels like" temperature (DECIMAL(5,2))
- `humidity`: Humidity percentage (INTEGER)
- `pressure`: Atmospheric pressure (INTEGER)
- `wind_speed`: Wind speed in m/s (DECIMAL(5,2))
- `wind_direction`: Wind direction in degrees (INTEGER)
- `weather_description`: Weather condition description (VARCHAR(100))
- `clouds`: Cloud coverage percentage (INTEGER)
- `sunrise`: Sunrise time (TIME)
- `sunset`: Sunset time (TIME)
- `created_at`: Record creation timestamp
- `updated_at`: Record last update timestamp

### Views

#### daily_weather_summary
Daily aggregated weather data by city:
- Average, max, and min temperatures
- Average humidity and pressure
- Average wind speed
- Most common weather condition

#### city_weather_stats
City-level weather statistics:
- Total number of records
- First and last record timestamps
- Average temperature with standard deviation
- Average humidity, pressure, and wind speed

#### weather_alerts
View for monitoring extreme weather conditions:
- High temperature alerts (>35°C)
- Low temperature alerts (<0°C)
- High humidity alerts (>90%)
- Low pressure alerts (<980 hPa)
- High wind alerts (>20 m/s)

#### country_weather_comparison
Country-level weather comparison:
- Number of cities monitored
- Average temperature
- Average humidity and pressure
- Average wind speed
- Most common weather condition

## Indexes

The following indexes are created for better query performance:
- `idx_weather_data_city`: For city-based queries
- `idx_weather_data_country`: For country-based queries
- `idx_weather_data_timestamp`: For time-based queries
- `idx_weather_data_temperature`: For temperature-based queries
- `idx_weather_data_humidity`: For humidity-based queries
- `idx_weather_data_pressure`: For pressure-based queries
- `idx_weather_data_wind_speed`: For wind speed-based queries

## Verification

After setup, verify the database structure:
```sql
-- List schemas
\dn

-- List tables in weather schema
\dt weather.*

-- List indexes
\di weather.*
```

## Data Import

To import data from CSV:
1. Right-click on the `weather_data` table in DBeaver
2. Select "Import Data"
3. Choose your CSV file
4. Map the columns correctly
5. Click "Start" to import

## Sample Queries

1. Get latest weather for each city:
```sql
SELECT DISTINCT ON (city) *
FROM weather.weather_data
ORDER BY city, timestamp DESC;
```

2. Get average temperature by country:
```sql
SELECT country, AVG(temperature) as avg_temperature
FROM weather.weather_data
GROUP BY country
ORDER BY avg_temperature DESC;
```

3. Get cities with high humidity:
```sql
SELECT city, country, humidity, temperature
FROM weather.weather_data
WHERE humidity > 80
ORDER BY humidity DESC;
```

## Maintenance

Regular maintenance tasks:
1. Monitor table size
2. Check index usage
3. Update statistics
4. Clean up old data if needed

To check table size:
```sql
SELECT pg_size_pretty(pg_total_relation_size('weather.weather_data'));
```

To analyze table:
```sql
ANALYZE weather.weather_data;
```

## Metabase Dashboard Setup

### 1. Connect Metabase to PostgreSQL
1. Open Metabase (usually at http://localhost:3000)
2. Click "Add your data"
3. Select "PostgreSQL"
4. Fill in the connection details:
   ```
   Name: Weather Database
   Host: localhost
   Port: 5432
   Database name: weather_db
   Username: postgres
   Password: postgres
   ```
5. Click "Save"

### 2. Create Questions (Queries)

#### Temperature Dashboard
1. Create a new question
2. Select "Native query"
3. Use this query for temperature trends:
   ```sql
   SELECT 
       city,
       DATE(timestamp) as date,
       AVG(temperature) as avg_temperature,
       MAX(temperature) as max_temperature,
       MIN(temperature) as min_temperature
   FROM weather.weather_data
   GROUP BY city, DATE(timestamp)
   ORDER BY date DESC, city;
   ```
4. Save as "Temperature Trends by City"
5. Create visualization:
   - Choose "Line chart"
   - X-axis: date
   - Y-axis: avg_temperature
   - Series: city

#### Weather Conditions Dashboard
1. Create a new question
2. Use this query for weather conditions:
   ```sql
   SELECT 
       weather_description,
       COUNT(*) as count,
       AVG(temperature) as avg_temperature,
       AVG(humidity) as avg_humidity
   FROM weather.weather_data
   GROUP BY weather_description
   ORDER BY count DESC;
   ```
3. Save as "Weather Conditions Distribution"
4. Create visualization:
   - Choose "Pie chart"
   - Value: count
   - Label: weather_description

#### City Comparison Dashboard
1. Create a new question
2. Use this query for city comparison:
   ```sql
   SELECT 
       city,
       AVG(temperature) as avg_temperature,
       AVG(humidity) as avg_humidity,
       AVG(pressure) as avg_pressure,
       AVG(wind_speed) as avg_wind_speed
   FROM weather.weather_data
   GROUP BY city
   ORDER BY avg_temperature DESC;
   ```
3. Save as "City Weather Comparison"
4. Create visualization:
   - Choose "Bar chart"
   - X-axis: city
   - Y-axis: avg_temperature

### 3. Create Dashboard

1. Click "New" → "Dashboard"
2. Name it "Weather Analysis Dashboard"
3. Add the questions you created:
   - Temperature Trends by City
   - Weather Conditions Distribution
   - City Weather Comparison

4. Add filters:
   - Date range filter
   - City filter
   - Country filter

5. Arrange the visualizations:
   - Temperature trends at the top
   - Weather conditions in the middle
   - City comparison at the bottom

### 4. Dashboard Features

1. Auto-refresh:
   - Click the clock icon
   - Set to refresh every 3 hours (matching ETL schedule)

2. Export options:
   - Click the download icon
   - Choose format (CSV, JSON, XLSX)

3. Sharing:
   - Click the share icon
   - Generate public link or embed code

### 5. Additional Tips

1. Create alerts:
   - Click the bell icon on any question
   - Set conditions (e.g., temperature > 35°C)
   - Choose notification method

2. Use the "X-ray" feature:
   - Click the lightbulb icon
   - Let Metabase suggest visualizations

3. Create saved questions:
   - Save common queries
   - Add to multiple dashboards

4. Use filters:
   - Add date range filters
   - Add city/country filters
   - Add weather condition filters 