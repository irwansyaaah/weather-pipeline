-- Drop existing table if exists
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

-- Create indexes for better query performance
CREATE INDEX idx_weather_data_city ON weather.weather_data(city);
CREATE INDEX idx_weather_data_country ON weather.weather_data(country);
CREATE INDEX idx_weather_data_timestamp ON weather.weather_data(timestamp);
CREATE INDEX idx_weather_data_temperature ON weather.weather_data(temperature);
CREATE INDEX idx_weather_data_humidity ON weather.weather_data(humidity);
CREATE INDEX idx_weather_data_pressure ON weather.weather_data(pressure);
CREATE INDEX idx_weather_data_wind_speed ON weather.weather_data(wind_speed);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION weather.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at
CREATE TRIGGER update_weather_data_updated_at
    BEFORE UPDATE ON weather.weather_data
    FOR EACH ROW
    EXECUTE FUNCTION weather.update_updated_at_column(); 