DROP TABLE IF EXISTS weather.weather_data;

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
