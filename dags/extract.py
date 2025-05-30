import requests
import time
import os
from dotenv import load_dotenv
import json
from datetime import datetime, timedelta
import logging
import hashlib
from pathlib import Path

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

API_KEY = os.getenv("OPENWEATHER_API_KEY")
BASE_URL = "https://api.openweathermap.org/data/2.5/weather"
CITIES = [
    "Jakarta", "Surabaya", "Bandung",  # Indonesia
    "Tokyo", "Singapore", "Seoul",     # Asia
    "London", "Paris", "Berlin",       # Europe
    "New York", "Los Angeles"          # America
]
RAW_DATA_DIR = "data/raw"
CACHE_DIR = "data/cache"
CACHE_EXPIRY = timedelta(hours=3)  # Cache data for 3 hours

# Create necessary directories
os.makedirs(RAW_DATA_DIR, exist_ok=True)
os.makedirs(CACHE_DIR, exist_ok=True)

def should_collect_data() -> bool:
    """Check if it's time to collect data (every 3 hours)"""
    current_hour = datetime.now().hour
    return current_hour % 3 == 0

def get_cache_key(city: str) -> str:
    """Generate a cache key for a city"""
    return hashlib.md5(city.lower().encode()).hexdigest()

def get_cached_data(city: str) -> dict:
    """Get cached data for a city if it exists and is not expired"""
    cache_key = get_cache_key(city)
    cache_file = os.path.join(CACHE_DIR, f"{cache_key}.json")
    
    if os.path.exists(cache_file):
        try:
            with open(cache_file, 'r') as f:
                cached_data = json.load(f)
                cache_time = datetime.fromisoformat(cached_data['cache_timestamp'])
                if datetime.now() - cache_time < CACHE_EXPIRY:
                    logger.info(f"Using cached data for {city}")
                    return cached_data['data']
        except Exception as e:
            logger.error(f"Error reading cache for {city}: {str(e)}")
    
    return None

def save_to_cache(city: str, data: dict):
    """Save data to cache with timestamp"""
    cache_key = get_cache_key(city)
    cache_file = os.path.join(CACHE_DIR, f"{cache_key}.json")
    
    try:
        cache_data = {
            'data': data,
            'cache_timestamp': datetime.now().isoformat()
        }
        with open(cache_file, 'w') as f:
            json.dump(cache_data, f, indent=4)
        logger.info(f"Saved data to cache for {city}")
    except Exception as e:
        logger.error(f"Error saving cache for {city}: {str(e)}")

def save_raw_data(data: dict, city: str):
    """Save raw JSON data to a file"""
    try:
        # Generate filename with timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f'data/raw/weather_{city.lower().replace(" ", "_")}_{timestamp}.json'
        
        # Save data to file
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)
        
        logger.info(f"Raw data saved to {filename}")
        return filename
    except Exception as e:
        logger.error(f"Error saving raw data: {str(e)}")
        raise

def get_weather_data(city: str, max_retries: int = 5, backoff_factor: int = 2) -> dict:
    """Get weather data with retry logic and rate limiting"""
    # Check cache first
    cached_data = get_cached_data(city)
    if cached_data:
        return cached_data

    params = {
        "q": city,
        "appid": API_KEY,
        "units": "metric"  # Get temperature in Celsius
    }

    for attempt in range(max_retries):
        try:
            response = requests.get(BASE_URL, params=params)
            response.raise_for_status()
            data = response.json()
            
            # Save to cache
            save_to_cache(city, data)
            return data

        except requests.exceptions.HTTPError as e:
            if response.status_code == 429:  # Too Many Requests
                wait_time = backoff_factor * (2 ** attempt)
                logger.warning(f"Rate limit hit for {city}. Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
            elif response.status_code >= 500:  # Server error
                wait_time = backoff_factor * (2 ** attempt)
                logger.warning(f"Server error for {city}. Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
            else:
                logger.error(f"HTTP error for {city}: {str(e)}")
                break

        except requests.exceptions.RequestException as e:
            logger.error(f"Request failed for {city}: {str(e)}")
            if attempt < max_retries - 1:
                wait_time = backoff_factor * (2 ** attempt)
                logger.warning(f"Retrying in {wait_time} seconds...")
                time.sleep(wait_time)
            else:
                break

    logger.error(f"Failed to get data for {city} after {max_retries} retries")
    return None

def extract_weather_data():
    """Extract weather data for all cities"""
    if not should_collect_data():
        logger.info("Not time to collect data yet (only collecting every 3 hours)")
        return False

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    successful_extractions = 0
    
    for city in CITIES:
        try:
            data = get_weather_data(city)
            if data:
                filename = save_raw_data(data, city)
                successful_extractions += 1
                logger.info(f"Successfully extracted and saved raw data for {city} to {filename}")
            else:
                logger.error(f"Failed to get data for {city}")
        except Exception as e:
            logger.error(f"Error processing {city}: {str(e)}")
    
    logger.info(f"Completed extraction: {successful_extractions}/{len(CITIES)} cities processed successfully")
    return successful_extractions > 0  # Return True if at least one city was processed successfully

if __name__ == "__main__":
    extract_weather_data()