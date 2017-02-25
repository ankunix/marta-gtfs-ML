import requests


import simplejson as json

#!/usr/bin/env python
import threading, logging, time

from kafka import KafkaConsumer, KafkaProducer




#print(response)


class Producer(threading.Thread):

    daemon = True
    def run(self):
        producer = KafkaProducer(bootstrap_servers='localhost:9092')

        while True:
            response = requests.get("http://developer.itsmarta.com/BRDRestService/RestBusRealTimeService/GetAllBus")

            response = str(response.text)
        
            response=response.replace("\\","")
            
            #print(response)
            producer.send('GTFS', response)
        
            time.sleep(1)









