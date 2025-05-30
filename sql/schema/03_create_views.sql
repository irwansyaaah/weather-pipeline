-- Create view for daily sales summary
CREATE OR REPLACE VIEW retail.daily_sales_summary AS
SELECT 
    InvoiceDate as date,
    Country,
    COUNT(DISTINCT InvoiceNo) as total_invoices,
    COUNT(DISTINCT CustomerID) as total_customers,
    SUM(Quantity) as total_quantity,
    SUM(Quantity * UnitPrice) as total_revenue,
    AVG(UnitPrice) as avg_unit_price
FROM retail.retail
GROUP BY InvoiceDate, Country
ORDER BY InvoiceDate DESC, Country;

-- Create view for product performance
CREATE OR REPLACE VIEW retail.product_performance AS
SELECT 
    StockCode,
    Description,
    COUNT(DISTINCT InvoiceNo) as total_invoices,
    SUM(Quantity) as total_quantity,
    SUM(Quantity * UnitPrice) as total_revenue,
    AVG(UnitPrice) as avg_unit_price
FROM retail.retail
GROUP BY StockCode, Description
ORDER BY total_revenue DESC;

-- Create view for customer analysis
CREATE OR REPLACE VIEW retail.customer_analysis AS
SELECT 
    CustomerID,
    Country,
    COUNT(DISTINCT InvoiceNo) as total_invoices,
    SUM(Quantity) as total_quantity,
    SUM(Quantity * UnitPrice) as total_spent,
    AVG(UnitPrice) as avg_unit_price
FROM retail.retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID, Country
ORDER BY total_spent DESC;

-- Create view for country analysis
CREATE OR REPLACE VIEW retail.country_analysis AS
SELECT 
    Country,
    COUNT(DISTINCT InvoiceNo) as total_invoices,
    COUNT(DISTINCT CustomerID) as total_customers,
    SUM(Quantity) as total_quantity,
    SUM(Quantity * UnitPrice) as total_revenue,
    AVG(UnitPrice) as avg_unit_price
FROM retail.retail
GROUP BY Country
ORDER BY total_revenue DESC;

-- Create view for daily weather summary
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
GROUP BY city, country, DATE(timestamp)
ORDER BY date DESC, city;

-- Create view for city weather statistics
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
GROUP BY city, country
ORDER BY city;

-- Create view for weather alerts
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
        ELSE NULL
    END as alert_type
FROM weather.weather_data
WHERE 
    temperature > 35 OR
    temperature < 0 OR
    humidity > 90 OR
    pressure < 980 OR
    wind_speed > 20
ORDER BY timestamp DESC;

-- Create view for country weather comparison
CREATE OR REPLACE VIEW weather.country_weather_comparison AS
SELECT 
    country,
    COUNT(DISTINCT city) as total_cities,
    AVG(temperature) as avg_temperature,
    AVG(humidity) as avg_humidity,
    AVG(pressure) as avg_pressure,
    AVG(wind_speed) as avg_wind_speed,
    MODE() WITHIN GROUP (ORDER BY weather_description) as most_common_weather
FROM weather.weather_data
GROUP BY country
ORDER BY country; 