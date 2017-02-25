import test as pd
import consume as cs
 
import simplejson as json

#!/usr/bin/env python
import threading, logging, time

from kafka import KafkaConsumer, KafkaProducer




def main():
    threads = [
    pd.Producer(),
    cs.Consumer()
              ]

    for t in threads:
         t.start()

    time.sleep(10)

if __name__ == "__main__":
    logging.basicConfig(
    format='%(asctime)s.%(msecs)s:%(name)s:%(thread)d:%(levelname)s:%(process)d:%(message)s',
    level=logging.INFO
    )


main()