from datetime import date, datetime

#For downloading from openweather
from geopy.geocoders import Nominatim
import requests
import os
import pathlib
import json

# For upleoading to firebase
import firebase_admin
from firebase_admin import credentials, firestore, storage

# For uploading to RethinkDB
# from rethinkdb import RethinkDB

#Notes on script, include failsafes for when download or upload fails

API_URL = 'https://api.openweathermap.org/data/2.5/onecall?lat='
API_KEY = '&exclude=minutely&appid=fb0d1900dd53606d67411c84f0a8c8b3'

cred = credentials.Certificate('../weather-anywhere-jmmariano-firebase-adminsdk-2rf1e-4024a5cf53.json');
firebase_admin.initialize_app(cred)
fstore = firestore.client()
# DOWNLOAD_DIR = '/home/jm/Desktop/forecasts'

today_day = date.today().strftime('%Y-%m-%d')
today_month = date.today().strftime('%Y-%m')
today_exact = datetime.now().isoformat()
# Creates directory to store .json files
# currDir = DOWNLOAD_DIR + '/' + today_day
# pathlib.Path(currDir).mkdir(parents=True, exist_ok=True)

# Check if forecast_files collection exists, create if none
fstore.collection('forecast_files').document(today_month).set({"initial" : "initial insert"});
month_doc = fstore.collection('forecast_files').document(today_month)
print('Initialized forecast database')

# Check if users collection exists, create if none
fstore.collection('users').document('super-user').set({"initial" : "initial insert"});
print('Initialized user database')

# Check if users collection exists, create if none
fstore.collection('weather_reports').document(today_month).set({"initial" : "initial insert"});
print('Initialized reports database')

# For uploading to RethinkDB
# r = RethinkDB()
# r.connect('localhost', 28015).repl()

# Format code for better readability

# try :
# 	r.db_create('forecast_files').run()
# except:
# 	print('Alredy initialized forecast database')
#
# try :
# 	r.db('forecast_files').table_create(date.today().strftime('%Y-%m')).run()
# except:
# 	print('Alredy initialized forecast table')
#
# try :
# 	r.db_create('users').run()
# except:
# 	print('Alredy initialized users database')
#
# try :
# 	r.db('users').table_create('reg_users').run()
# except:
# 	print('Alredy initialized user table')

geolocator = Nominatim(user_agent = 'sp_script')

with open('../config/municipalities.json', 'r') as file:
	list_data = file.read()

	json_data = json.loads(list_data)
	aggregated = []

	# Remove (if 'city' in i) statement to include municipalities
	for i in json_data:
		if 'city' in i:
			loop_lock = True
			while loop_lock == True:
				try:
					name = i['name'] + ', ' + i['province'] + ', Philippines'
					forecast_id = today_day + '-' + i['name'] + ',' + i['province']

					location = geolocator.geocode(name)

					# Fetches .json file from API
					currUrl = API_URL + str(location.latitude) + '&lon=' + str(location.longitude) + API_KEY
					response = requests.get(currUrl).json()
					# r.db('forecast_files').table(date.today().strftime('%Y-%m')).insert(
					# 	{
					# 		"id" : today_day + '-' + i['name'],
					# 		"last_modified" : today_exact,
					# 		"city" : i['name'],
					# 		"province" : i['province'],
					# 		"weather_data" : response,
					# 	}, conflict="update").run()
					forecast = {
						'last_modified' : today_exact,
						'city' : i['name'],
						'province' : i['province'],
						'weather_data' : response,
					}

					month_doc.collection(i['name'] + ',' + i['province']).document(forecast_id).set(forecast);

					print('Updated ' + i['name'])
					loop_lock = False
				except:
					print('Trying again...')
