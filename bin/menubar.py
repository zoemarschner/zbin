import requests, json, os
import geolocate

def get_weather():
	"""
	gets the weather at the stored lat and long, using the Dark Sky API: https://darksky.net/dev
	"""

	KEY = os.environ.get("OPEN_WEATHER_KEY")

	contents = requests.get(f"https://api.openweathermap.org/data/2.5/weather?lat={lat_long[0]}&lon={lat_long[1]}&appid={KEY}")
	data = json.loads(contents.content)
	icon = data["weather"][0].get('icon', None)
	iconStr = "" if icon is None else " and "
	
	fill_str = '.fill'
	icons = {'01d':"sun.max",'01n':"moon.stars",'02d':"cloud.sun",'02n':"cloud.moon",'03d':"cloud",'03n':"cloud",'04d':"smoke",'04n':"smoke",'09d':"cloud.rain",'09n':"cloud.rain",'10d':"cloud.sun.rain",'10n':"cloud.moon.rain",'11d':"cloud.sun.bolt",'11n':"cloud.moon.bolt",'13d':"cloud.snow",'13n':"cloud.snow",'50d':"cloud.fog",'50n':"cloud.fog"}
	iconEmoji = f'{icons.get(icon, None)}{fill_str}'

	tempk = data['main']['temp_max']
	tempc = tempk - 273.15
	tempf = tempc * 9/5 + 32

	return iconEmoji, f"{tempf:.0f}°F", f"{tempc:.0f}°C"


def get_location():
	"""
	uses geocoder package to get latitude and longitude from ip adress
	"""
	global lat_long
	loc = geolocate.ip('me')
	lat_long = loc.latlng
	return loc.address[0: loc.address.index(',')]


try:
	loc = get_location()
	emoji, tempf, tempc = get_weather()

	print(f"{tempf} :{emoji}:")
	print(f"{tempc} :{emoji}:")
except Exception:
	print("...")
