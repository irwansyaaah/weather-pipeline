-- Create schema
CREATE SCHEMA IF NOT EXISTS weather;

-- Set search path
SET search_path TO weather, public;

-- Create weather_data table
CREATE TABLE IF NOT EXISTS weather.weather_data (
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
CREATE INDEX IF NOT EXISTS idx_weather_data_city ON weather.weather_data(city);
CREATE INDEX IF NOT EXISTS idx_weather_data_country ON weather.weather_data(country);
CREATE INDEX IF NOT EXISTS idx_weather_data_timestamp ON weather.weather_data(timestamp);
CREATE INDEX IF NOT EXISTS idx_weather_data_temperature ON weather.weather_data(temperature);
CREATE INDEX IF NOT EXISTS idx_weather_data_humidity ON weather.weather_data(humidity);
CREATE INDEX IF NOT EXISTS idx_weather_data_pressure ON weather.weather_data(pressure);
CREATE INDEX IF NOT EXISTS idx_weather_data_wind_speed ON weather.weather_data(wind_speed);

-- Create views
CREATE OR REPLACE VIEW weather.daily_weather_summary AS
SELECT 
    city,
    country,
    DATE(timestamp) as date,
    AVG(temperature) as avg_temperature,
    MAX(temperature) as max_temperature,
    MIN(temperature) as min_temperature,
    AVG(humidity) as avg_humidity,
    AVG(pressure) as avg_pressure,
    AVG(wind_speed) as avg_wind_speed,
    MODE() WITHIN GROUP (ORDER BY weather_description) as most_common_weather
FROM weather.weather_data
GROUP BY city, country, DATE(timestamp);

CREATE OR REPLACE VIEW weather.city_weather_stats AS
SELECT 
    city,
    country,
    COUNT(*) as total_records,
    MIN(timestamp) as first_record,
    MAX(timestamp) as last_record,
    AVG(temperature) as avg_temperature,
    STDDEV(temperature) as temperature_stddev,
    AVG(humidity) as avg_humidity,
    AVG(pressure) as avg_pressure,
    AVG(wind_speed) as avg_wind_speed
FROM weather.weather_data
GROUP BY city, country;

CREATE OR REPLACE VIEW weather.weather_alerts AS
SELECT 
    city,
    country,
    timestamp,
    temperature,
    humidity,
    pressure,
    wind_speed,
    weather_description,
    CASE 
        WHEN temperature > 35 THEN 'High Temperature Alert'
        WHEN temperature < 0 THEN 'Low Temperature Alert'
        WHEN humidity > 90 THEN 'High Humidity Alert'
        WHEN pressure < 980 THEN 'Low Pressure Alert'
        WHEN wind_speed > 20 THEN 'High Wind Alert'
    END as alert_type
FROM weather.weather_data
WHERE 
    temperature > 35 OR 
    temperature < 0 OR 
    humidity > 90 OR 
    pressure < 980 OR 
    wind_speed > 20;

CREATE OR REPLACE VIEW weather.country_weather_comparison AS
SELECT 
    country,
    COUNT(DISTINCT city) as cities_monitored,
    AVG(temperature) as avg_temperature,
    AVG(humidity) as avg_humidity,
    AVG(pressure) as avg_pressure,
    AVG(wind_speed) as avg_wind_speed,
    MODE() WITHIN GROUP (ORDER BY weather_description) as most_common_weather
FROM weather.weather_data
GROUP BY country; 