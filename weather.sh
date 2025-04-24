#!/bin/bash

# ========== Configuration ==========
CITY="Innopolis"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
OUTPUT_DIR="$HOME/Documents/weather_reports"
UNITS="metric"

mkdir -p "$OUTPUT_DIR"

OUTPUT_FILE="$OUTPUT_DIR/weather_report_${CITY}_${TIMESTAMP}.txt"

# ========== Load environment variables ==========
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)  # Load API_KEY from .env file
fi

if [ -z "$API_KEY" ]; then
  echo "API key is missing! Please check your .env file."
  exit 1
fi

# ========== API Call ==========
WEATHER_JSON=$(curl -s "https://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=${UNITS}")


# ========== Parse JSON ==========
TEMP_C=$(echo "$WEATHER_JSON" | jq '.main.temp')
FEELS_LIKE_C=$(echo "$WEATHER_JSON" | jq '.main.feels_like')
HUMIDITY=$(echo "$WEATHER_JSON" | jq '.main.humidity')
WIND_SPEED=$(echo "$WEATHER_JSON" | jq '.wind.speed')
WIND_DIR=$(echo "$WEATHER_JSON" | jq '.wind.deg')
CLOUDS=$(echo "$WEATHER_JSON" | jq '.clouds.all')
PRESSURE=$(echo "$WEATHER_JSON" | jq '.main.pressure')
SUNRISE=$(echo "$WEATHER_JSON" | jq '.sys.sunrise')
SUNSET=$(echo "$WEATHER_JSON" | jq '.sys.sunset')
DESCRIPTION=$(echo "$WEATHER_JSON" | jq -r '.weather[0].description')

# ========== Time Conversion ==========
if [[ "$SUNRISE" != "null" && "$SUNSET" != "null" ]]; then
  SUNRISE_TIME=$(date -d "@$SUNRISE" +"%Y-%m-%d %H:%M:%S")
  SUNSET_TIME=$(date -d "@$SUNSET" +"%Y-%m-%d %H:%M:%S")
else
  SUNRISE_TIME="Not available"
  SUNSET_TIME="Not available"
fi

# ========== Output Formatting ==========
{
echo "Weather Report for $CITY"
echo "------------------------------------"
echo "Temperature: $TEMP_C°C"
echo "Feels Like: $FEELS_LIKE_C°C"
echo "Humidity: $HUMIDITY%"
echo "Wind Speed: $WIND_SPEED m/s"
echo "Wind Direction: $WIND_DIR°"
echo "Cloud Coverage: $CLOUDS%"
echo "Pressure: $PRESSURE hPa"
echo "Sunrise: $SUNRISE_TIME"
echo "Sunset: $SUNSET_TIME"
echo "Weather Description: $DESCRIPTION"
echo "------------------------------------"
} > "$OUTPUT_FILE"

echo "Weather data saved to $OUTPUT_FILE"
