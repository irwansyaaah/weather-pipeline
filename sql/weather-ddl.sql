SELECT 'CREATE DATABASE weather'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'weather')\gexec

\copy weather.weather_data(
    city, country, timestamp, temperature, feels_like, humidity, pressure, wind_speed, wind_direction,
    weather_description, clouds, sunrise, sunset
) FROM '/tmp/weather_data.csv' DELIMITER ',' CSV HEADER;