
# coding: utf-8

# In[1]:

from IPython.display import display
import pandas as pd
import numpy as np
import json as js
import urllib
import requests
from pymongo import MongoClient
import threading, logging, time
from kafka import KafkaConsumer, KafkaProducer
import simplejson as json


# In[2]:

stop_list = pd.read_csv("https://raw.githubusercontent.com/ankush2611/marta-gtfs-ML/master/google_transit/stops.txt")


# In[3]:

# Function to find coordinates from stop_id
def id_coor(n, df):
    target = df[df["stop_id"] == n]
    lat = round(float(target["stop_lat"]),2)
    lon = round(float(target["stop_lon"]),2)
    return lat, lon


# In[4]:

# Function to request real-time weather report by coordinates
def coor_weather(lat, lon):
    lati = str(lat)
    loni = str(lon)
    url = "http://api.openweathermap.org/data/2.5/weather?"+"lat="+lati+"&lon="+loni+"&appid=d491dc197b33dba3e9b6fd60d3ac8712"
    response = requests.get(url)
    response = str(response.text)
    response.replace("\\","")
    return response
    # with open('JSONData.json', 'a') as f:
    #       js.dump(response, f,separators=(',',':'))


# In[5]:


def name_id(name, df):
    target_name = df.loc[df["stop_name"] == name]
    i = target_name["stop_id"]
    return i


# In[6]:

# Function to request weather report by stop_id
# def id_weather(n, df):
#     lat, lon = id_coor(n, df)
#     report = coor_weather(lat, lon)
#     return report




