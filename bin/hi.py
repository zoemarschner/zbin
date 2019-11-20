import argparse
from datetime import datetime
import requests, json, geocoder

#a just for fun command that greets me and gets the weather :)

lat_long = []

def get_weather():
	"""
	gets the weather at the stored lat and long, using the Dark Sky API: https://darksky.net/dev
	"""

	KEY = "b3cd0645a6301cdcdffd485fdc0f524c"

	contents = requests.get(f"https://api.darksky.net/forecast/{KEY}/{lat_long[0]},{lat_long[1]}")
	data = json.loads(contents.content)
	icon = data["currently"].get('icon', None)
	iconStr = "" if icon is None else " and "
	if icon == "clear-day":
		iconStr += "☀️"
	elif icon == "clear-night":
		iconStr += "🌙"
	elif icon == "rain":
		iconStr += "🌧️"
	elif icon == "snow":
		iconStr += "❄️"
	elif icon == "sleet":
		iconStr += "🌨️"
	elif icon == "wind":
		iconStr += "🌪️"
	elif icon == "fog":
		iconStr += "☁️"
	elif icon == "cloudy":
		iconStr += "☁️"
	elif icon == "partly-cloudy-day":
		iconStr += "⛅"
	elif icon == "partly-cloudy-night":
		iconStr += "🌙"

	weekStr = f"This week, expect {data['daily']['summary'][0].lower() + data['daily']['summary'][1:]}"
	dayStr = f"Today, expect {data['hourly']['summary'][0].lower() + data['hourly']['summary'][1:]}"
	return [f"It's {data['currently']['temperature']}°F" + iconStr, dayStr, weekStr]

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
	print(weather_data[2])
else:
	print(f"{greeting} {weather_data[0]}")
