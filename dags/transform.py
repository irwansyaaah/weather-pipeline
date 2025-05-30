import pandas as pd
import json
import os
from datetime import datetime
import logging
from pathlib import Path
import glob

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

RAW_DATA_DIR = "data/raw"
TRANSFORMED_DATA_DIR = "data/transformed"

def ensure_directories():
    """Ensure all required directories exist"""
    os.makedirs(TRANSFORMED_DATA_DIR, exist_ok=True)

def get_latest_raw_files():
    """Get the latest raw data files for each city"""
    try:
        # Get all raw data files
        raw_files = glob.glob(os.path.join(RAW_DATA_DIR, "weather_*.json"))
        if not raw_files:
            logger.warning("No raw data files found")
            return []

        # Group files by city
        city_files = {}
        for file in raw_files:
            try:
                city = file.split('_')[1]  # Extract city name from filename
                if city not in city_files:
                    city_files[city] = []
                city_files[city].append(file)
            except Exception as e:
                logger.error(f"Error processing file {file}: {str(e)}")

        # Get latest file for each city
        latest_files = []
        for city, files in city_files.items():
            try:
                latest_file = max(files, key=os.path.getctime)
                latest_files.append(latest_file)
            except Exception as e:
                logger.error(f"Error getting latest file for {city}: {str(e)}")

        return latest_files
    except Exception as e:
        logger.error(f"Error getting latest raw files: {str(e)}")
        return []

def transform_weather_data():
    """Transform raw weather data into a structured format"""
    try:
        ensure_directories()
        latest_files = get_latest_raw_files()
        
        if not latest_files:
            logger.error("No raw data files to transform")
            return False

        transformed_data = []
        successful_transforms = 0

        for file in latest_files:
            try:
                with open(file, 'r') as f:
                    raw_data = json.load(f)

                # Extract relevant data
                city_data = {
                    'city': raw_data['name'],
                    'country': raw_data['sys']['country'],
                    'timestamp': datetime.fromtimestamp(raw_data['dt']).strftime('%Y-%m-%d %H:%M:%S'),
                    'temperature': raw_data['main']['temp'],
                    'feels_like': raw_data['main']['feels_like'],
                    'humidity': raw_data['main']['humidity'],
                    'pressure': raw_data['main']['pressure'],
                    'wind_speed': raw_data['wind']['speed'],
                    'wind_direction': raw_data['wind'].get('deg', None),
                    'weather_description': raw_data['weather'][0]['description'],
                    'clouds': raw_data['clouds']['all'],
                    'sunrise': datetime.fromtimestamp(raw_data['sys']['sunrise']).strftime('%H:%M:%S'),
                    'sunset': datetime.fromtimestamp(raw_data['sys']['sunset']).strftime('%H:%M:%S')
                }
                transformed_data.append(city_data)
                successful_transforms += 1
                logger.info(f"Successfully transformed data for {city_data['city']}")

            except KeyError as e:
                logger.error(f"Missing key in data for {file}: {str(e)}")
            except Exception as e:
                logger.error(f"Error transforming data from {file}: {str(e)}")

        if transformed_data:
            # Create DataFrame
            df = pd.DataFrame(transformed_data)
            
            # Generate output filename with timestamp
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            output_file = os.path.join(TRANSFORMED_DATA_DIR, f'weather_data_{timestamp}.csv')
            
            # Save to CSV
            df.to_csv(output_file, index=False)
            logger.info(f"Transformed data saved to {output_file}")
            
            # Also save as JSON for flexibility
            json_file = os.path.join(TRANSFORMED_DATA_DIR, f'weather_data_{timestamp}.json')
            df.to_json(json_file, orient='records', indent=4)
            logger.info(f"Transformed data also saved to {json_file}")
            
            logger.info(f"Completed transformation: {successful_transforms}/{len(latest_files)} files processed successfully")
            return True
        else:
            logger.error("No data was successfully transformed")
            return False

    except Exception as e:
        logger.error(f"Error in transform_weather_data: {str(e)}")
        return False

if __name__ == "__main__":
    transform_weather_data() 