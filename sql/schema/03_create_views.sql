CREATE OR REPLACE VIEW weather.city_weather_stats AS
SELECT 
    city,
    country,
    COUNT(*) AS total_records,
    MIN(timestamp) AS first_record,
    MAX(timestamp) AS last_record,
    AVG(temperature) AS avg_temperature,
    STDDEV(temperature) AS temperature_stddev,
    AVG(humidity) AS avg_humidity,
    AVG(pressure) AS avg_pressure,
    AVG(wind_speed) AS avg_wind_speed
FROM weather.weather_data
GROUP BY city, country;