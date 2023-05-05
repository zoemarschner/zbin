import argparse
from datetime import datetime
import requests, json, geocoder, os

#a just for fun command that greets me and gets the weather :)

lat_long = []

def get_weather(units_metric=False):
	"""
	gets the weather at the stored lat and long, using the Dark Sky API: https://darksky.net/dev
	"""

	KEY = os.environ.get("OPEN_WEATHER_KEY")

	contents = requests.get(f"https://api.openweathermap.org/data/2.5/weather?lat={lat_long[0]}&lon={lat_long[1]}&appid={KEY}")
	data = json.loads(contents.content)
	icon = data["weather"][0].get('icon', None)
	iconStr = "" if icon is None else " and "
	if icon == "01d":
		iconStr += "☀️"
	elif icon == "01n":
		iconStr += "🌙"
	elif icon in ["02d", "02n"]:
		iconStr += "⛅"
	elif icon in ["03d", "03n", "04d", "04n"]:
		iconStr += "☁️"
	elif icon in ["09d", "09n"] :
		iconStr += "🌧️"
	elif icon in ["10d", "10n"]:
		iconStr += "🌦"
	elif icon in ["11d", "11n"]:
		iconStr += "🌩"
	elif icon in ["13d", "13n"]:
		iconStr += "❄️"
	elif icon in ["50d", "50n"]:
		iconStr += "🌫"

	conv_f = kelvin_to_celsius if units_metric else kelvin_to_farenheit
	units = "C" if units_metric else "F"

	dayStr = f"Today, expect {data['weather'][0]['description'].lower()} with a high of {conv_f(data['main']['temp_max']):.1f}°{units} and low of {conv_f(data['main']['temp_min']):.1f}°{units}."
	return [f"It's {conv_f(data['main']['temp']):.1f}°{units}" + iconStr, dayStr]

def kelvin_to_farenheit(temp):
	return kelvin_to_celsius(temp) * 9/5 + 32

def kelvin_to_celsius(temp):
	return (temp - 273.15)

def get_location():
	"""
	uses geocoder package to get latitude and longitude from ip adress
	"""
	global lat_long
	loc = geocoder.ip('me')
	lat_long = loc.latlng
	return f"You're in {loc.address} and your ISP is {loc.org}"

def get_greeting(name):
	"""
	returns appropriate greeting based on time of day:
		good morning if between 5 and 10 am
		good night if between midnight and 5
		hi otherwise
	"""
	hour = datetime.now().hour
	if hour < 5:
		return f"Good night {name}!"
	elif hour < 10:
		return f"Good morning {name}!"
	else:
		return f"Hi {name}!"

parser = argparse.ArgumentParser(description='Just a fun script to say hi!')
parser.add_argument('-l', dest='long', action='store_const',
                    const=True, default=False, help='show longer version of the output')
args = parser.parse_args()

greeting = get_greeting("Zoë")
location_data = get_location()
weather_data = get_weather()

if args.long:
	print(greeting)
	print(location_data)
	print(weather_data[0])
	print(weather_data[1])
else:
	print(f"{greeting} {weather_data[0]}")
