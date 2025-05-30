-- Create the weather database
CREATE DATABASE weather_db;

-- Connect to the weather database
\c weather_db;

-- Create the weather schema
CREATE SCHEMA IF NOT EXISTS weather;

-- Set the search path
SET search_path TO weather, public; 