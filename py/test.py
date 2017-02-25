import requests

import weather_data as wd
import simplejson as json
import pandas as pd
#!/usr/bin/env python
import threading, logging, time

from kafka import KafkaConsumer, KafkaProducer




#print(response)


class Producer(threading.Thread):
	

    
    daemon = True
    def run(self):
    	stop_list = pd.read_csv("https://raw.githubusercontent.com/ankush2611/marta-gtfs-ML/master/google_transit/stops.txt")

        lat,lon=wd.id_coor(100004,stop_list)

        


        producer = KafkaProducer(bootstrap_servers='localhost:9092')

        while True:
            response=wd.coor_weather(lat,lon)

            #response = str(response.text)
        
            #response=response.replace("\\","")
            
            #print(response)
            producer.send('Weather', response)
        
            time.sleep(1)
