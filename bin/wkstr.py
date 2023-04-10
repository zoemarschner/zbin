import argparse
import os, json, sys, math
import datetime

"""
set the WEEK STRINGS as enviroment variable, so that it can be referenced in code
for example, for labelling folders of research pictures
the format is WKSTR_[day of week symobl] = [month][day]_[yr] 
the week "starts" at the next day--so if it is Tuesday 
"""

WEEK_SYMBOLS = ['M', 'T', 'W', 'Th', 'F', 'S', 'Su']

def strings_for_next_week(wrap=False):
	today = datetime.date.today()
	out = {}

	for i in range(7):
		date = datetime.date.today() + datetime.timedelta(days=i + (1 if wrap else 0)) 
		date_symbol = WEEK_SYMBOLS[date.isoweekday()-1]

		daystr = date.strftime("%b%-dth_%y")
		daystr = daystr.replace('th', ordinal_for(date.day)).lower()

		out[f'WKSTR_{date_symbol}'] =  f'{daystr}'

	return out

def ordinal_for(day):
	if day >= 10 and day <= 20: return "th"
	if day % 10 == 1: return "st"
	if day % 10 == 2: return "nd"
	if day % 10 == 2: return "rd"
	return "th"
	
def print_export_command(variables):
	print('export ', end='')
	for name, value in variables.items():
		print(f'{name}={value} ', end='')

parser = argparse.ArgumentParser(description=' Sets the WEEK STRINGS as enviorment variables. \nThe format is WKSTR_[day of week symobl] = [month][day]_[yr]')
parser.add_argument('-w', dest='wrap', action='store_const',
                    const=True, default=False, help='Wrap the week, so that the week string for the current weekday will be set to the date for the next instance of that day')
args = parser.parse_args()

print_export_command(strings_for_next_week(wrap=args.wrap))
