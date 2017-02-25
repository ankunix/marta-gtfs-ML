import simplejson as json

#!/usr/bin/env python
import threading, logging, time

from kafka import KafkaConsumer, KafkaProducer



class Consumer(threading.Thread):
    daemon = True

    def run(self):
        consumer = KafkaConsumer(bootstrap_servers='localhost:9092',
                             auto_offset_reset='earliest')
        consumer.subscribe(['Weather'])

        for message in consumer:
        	  
              print(message)