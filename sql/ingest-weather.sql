COPY weather_db FROM '/data/transformed/weather_data_20250530_122606.csv' DELIMITER AS ',' CSV HEADER;
SELECT * FROM weather_db LIMIT 5;