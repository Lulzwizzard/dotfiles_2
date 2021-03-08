#!/bin/python
# -*- coding: utf-8 -*-

import requests
import os

CITY = "2861650"
API_KEY = "b88aad9fbcde4b5e4522a8c4a7100a8c"
UNITS = "Metric"
UNIT_KEY = "C"
LANG = "en"

response = os.system("ping -c 1 google.de")

if response == 0:
    REQ = requests.get("http://api.openweathermap.org/data/2.5/weather?id={}&lang={}&appid={}&units={}".format(CITY, LANG,  API_KEY, UNITS))
    try:
        # HTTP CODE = OK
        if REQ.status_code == 200:
            CURRENT = REQ.json()["weather"][0]["description"].capitalize()
            TEMP = int(float(REQ.json()["main"]["temp"]))
            print("{}, {} °{}".format(CURRENT, TEMP, UNIT_KEY))
        else:
#           print("Error: BAD HTTP STATUS CODE " + str(REQ.status_code))
            print("Error, Bad HTTP Status Code")
    except (ValueError, IOError):
        print("Error: Unable print the data")
else:
    print("Not Connected")
