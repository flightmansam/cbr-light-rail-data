# import pycurl
import requests

FIRE_RATING_API = "https://corsproxy.io/?url=http://esa.act.gov.au/feeds/firedangerrating.xml" #A request has been made to esa.act.gov.au to allow CORS
WEATHER_DATA_API = "https://api.met.no/weatherapi/locationforecast/2.0/complete?lat=-35.2601639&lon=149.1328195&altitude=577"


def get_fire_rating():
    ...

def get_weather_data():    
    out = {}
    response = requests.get(WEATHER_DATA_API)
    if response:
        data = response.json()
        instant = data.properties.timeseries[0].data.instant.details
        out["currentTemp"] = instant.air_temperature
        out["currentTemp"] = instant.air_temperature
    else:
        return out
