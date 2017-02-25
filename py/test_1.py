import weather_data as wd
import pandas as pd

stop_list = pd.read_csv("https://raw.githubusercontent.com/ankush2611/marta-gtfs-ML/master/google_transit/stops.txt")

lat,lon=wd.id_coor(100004,stop_list)


response=wd.coor_weather(lat,lon)

#response = str(response.text)
        
#response=response.replace("\\","")
print("something")            
print(response)
