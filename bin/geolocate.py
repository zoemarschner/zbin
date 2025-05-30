## helper function for "hi.py" that implements a more robust ip geolocation,
## without relying on the geocoder module which does not seem to be maintained

import requests


class IpInfo:
	def __init__(self, latlng, address, org):
		self.latlng = latlng
		self.address = address
		self.org = org


"""
Implements the functionallity of geocoder. This function takes either an ip_address, or
"me" (in which case it uses your ip address). It returns a IpInfo class with this info:
- latlng: tuple of latitude and longitude
- address: name for your location
- org: name or your ISP
(this is designed to have drop in compatability with goecoder module)
"""
def ip(ip_address):
	query = "" if ip_address == "me" else ip_address
	
	response = requests.get(f'http://ip-api.com/json/{query}').json()

	latlng = (response["lat"], response["lon"])
	address = f"{response["city"]}, {response["regionName"]}, {response["country"]}"
	org = response["org"]

	return IpInfo(latlng, address, org)

if __name__ == "__main__":
	ip('me')