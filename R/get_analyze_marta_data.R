library(ggplot2); library(dplyr); library(stringr); library(readr); library(lubridate)


### Get APC Data (North Avenue Corridor)
# Source Link: http://opendata.itsmarta.com/hackathon/2017/February/APC/apcdata_NorthAve.csv

# See [APC Data Dictionary](data_notes/apc-data-dictionary.md) for dataset info

## Get apc data (North Avenue corridor) ----
apcdata <- read_csv("data_raw/opendata.itsmarta.com/apcdata_NorthAve.csv",
                    col_types = "ccccccccccccc") %>%
     mutate(calendar_day = mdy(calendar_day),
            route = as.integer(route),
            ons = as.integer(ons),
            offs = as.integer(offs),
            latitude = as.numeric(latitude),
            longitude = as.numeric(longitude))

apc_year_geosummary <- apcdata %>% group_by(longitude, latitude) %>% summarise(ons_sum = sum(ons)) %>% ungroup() %>% filter(!is.na(latitude) & !is.na(longitude))
apc_year_ons_q90 <- quantile(apc_year_geosummary$ons_sum, .9)
apc_year_geosummary$ons_high <- sapply(apc_year_geosummary$ons_sum, function(x) ifelse(x >))

m <- leaflet(data = apc_year_geosummary) %>% addCircles(lng = apc_year_geosummary$longitude, lat = apc_year_geosummary$latitude, color = pal(apc_year_geosummary$count_high), radius = apc_year_geosummary$count) %>% addTiles()
m

### Get GTFS Data
# Source Links: http://opendata.itsmarta.com/hackathon/2017/February/GTFS/
     
#read_csv("http://opendata.itsmarta.com/hackathon/2017/February/GTFS/agency.csv")
#read_csv("http://opendata.itsmarta.com/hackathon/2017/February/GTFS/calendar.csv")
#read_csv("http://opendata.itsmarta.com/hackathon/2017/February/GTFS/calendar_dates.csv")
#read_csv("http://opendata.itsmarta.com/hackathon/2017/February/GTFS/routes.csv")
#read_csv("http://opendata.itsmarta.com/hackathon/2017/February/GTFS/shapes.csv")
#read_csv("http://opendata.itsmarta.com/hackathon/2017/February/GTFS/stop_times.csv")
gtfs_stops <- read_csv("http://opendata.itsmarta.com/hackathon/2017/February/GTFS/stops.csv")
#read_csv("http://opendata.itsmarta.com/hackathon/2017/February/GTFS/trips.csv")

library(leaflet)
pal <- colorNumeric(c("red", "blue"), 1:2)

m <- leaflet(data = avl_year_geosummary) %>% addCircles(lng = avl_year_geosummary$longitude, lat = avl_year_geosummary$latitude, color = pal(avl_year_geosummary$count_high), radius = avl_year_geosummary$count) %>% addTiles()
m

### Get AVL Data
# Source Links to files on opendata.itsmarta.com
# 
# * [avl_otpdata_week.csv](http://opendata.itsmarta.com/hackathon/2017/February/AVL_OTP/avl_otpdata_week.csv)
# * [avl_otpdata_month.csv](http://opendata.itsmarta.com/hackathon/2017/February/AVL_OTP/avl_otpdata_month.csv)
# * [avl_otpdata_year.csv](http://opendata.itsmarta.com/hackathon/2017/February/AVL_OTP/avl_otpdata_year.csv)
# 
# See [AVL Data Dictionary](data_notes/avl_otpdata-data-dictionary.md) for dataset info

# ## Get avl data ----

### Parking Data
Source Links to files on opendata.itsmarta.com:
     
# * [Parking_Info.csv](http://opendata.itsmarta.com/hackathon/2017/February/Parking_Data/Parking_Info.csv)
# * [Station.csv](http://opendata.itsmarta.com/hackathon/2017/February/Parking_Data/Station.csv)

parking <- 
     left_join(read_csv("data_raw/opendata.itsmarta.com/Parking_Info.csv", col_types = "iiiii_"),
               read_csv("data_raw/opendata.itsmarta.com/Station.csv", col_types = "ici"),
               by = "STATION_ID") %>%
     mutate(PERCENT_FILLED = ifelse(is.na(NUMBER_OF_CARS_PARKED) | is.na(NUMBER_OF_SPACES),
                                    NA, NUMBER_OF_CARS_PARKED / NUMBER_OF_SPACES))
parking

prep_avl_data <- function(timeframe){
     if(timeframe == "week"){
          avldf_raw <- read_csv("data_raw/opendata.itsmarta.com/avl_otpdata_week.csv",
                                col_types = paste(rep("c", times = 19), collapse = ""))
     } else if(timeframe == "month"){
          avldf_raw <- read_csv("data_raw/opendata.itsmarta.com/avl_otpdata_month.csv",
                                col_types = paste(rep("c", times = 19), collapse = ""))
     } else if(timeframe == "year"){
          avldf_raw <- read_csv("data_raw/opendata.itsmarta.com/avl_otpdata_year.csv",
                                col_types = paste(rep("c", times = 19), collapse = ""))
     }
     avldf <- 
          avldf_raw %>%
          mutate(calendar_day = dmy(calendar_day),
                 scheduled_time = as.integer(scheduled_time),
                 actual_arrival_time = as.integer(actual_arrival_time),
                 actual_depart_time = as.integer(actual_depart_time),
                 adherence_seconds = as.integer(adherence_seconds),
                 latitude = as.numeric(latitude) / 10000000,
                 longitude = as.numeric(longitude) / 10000000)
     
     avldf$adherence_category <- 
          cut(avldf$adherence_seconds, breaks = c(-10000, -300, 300, 10000))
     
     longitude_group8 <- avldf %>% select(longitude) %>% distinct() %>% arrange(longitude) %>% mutate(longitude_group = ntile(longitude, n = 8))
     
     latitude_group8 <- avldf %>% select(latitude) %>% distinct() %>% arrange(latitude) %>% mutate(latitude_group = ntile(latitude, n = 8))
     
     avldf <- 
          avldf %>% 
          left_join(longitude_group8, by = "longitude") %>% 
          left_join(latitude_group8, by = "latitude")
     
     return(avldf)
}

## Get AVL Data ----
# avl_week <- prep_avl_data("week")
# avl_month <- prep_avl_data("month")
if(file.exists("data_processed/avl_year_processed.rds")){
     avl_year <- read_rds("data_processed/avl_year_processed.rds")
} else{
     avl_year <- prep_avl_data("year")
}

if(!file.exists("data_processed/avl_year_processed.rds")){
     write_rds(avl_year, "data_processed/avl_year_processed.rds")
}
if(!file.exists("data_processed/avl_year_processed.csv")){
     write_csv(avl_year, "data_processed/avl_year_processed.csv", na = "")
}

avl_year$adherence_znorm <- (avl_year$adherence_seconds - mean(avl_year$adherence_seconds)) / sd(avl_year$adherence_seconds)

adherence_histogram <- function(df, plot_filename){
     
     p <- 
          ggplot() + 
          geom_bar(data = df, aes(adherence_seconds)) + 
          geom_vline(data = df, 
                     xintercept = quantile(df$adherence_seconds, 
                                           probs = c(.01, .99)), color = "red") + 
          geom_vline(data = df, 
                     xintercept = quantile(df$adherence_seconds, 
                                           probs = c(.1, .9)), color = "orange") +
          geom_vline(data = df, 
                     xintercept = quantile(df$adherence_seconds, 
                                           probs = c(.25, .75)), color = "green3") + 
          geom_vline(data = df, 
                     xintercept = quantile(df$adherence_seconds, 
                                           probs = c(.5)), color = "blue") + 
          geom_label(
               data = data_frame(
                    adherence_seconds = quantile(df$adherence_seconds, 
                                                 probs = c(.01, .1, .25, .5, .75, .9, .99)),
                    count = 575), 
               aes(adherence_seconds, count, label = round(adherence_seconds, 0))) + 
          ggtitle("AVL Data (week): Adherence Seconds", 
                  subtitle = "Colored lines show quantiles - Red: 1%/99%, Orange: 10%/90%, Green = 25%/75%, Blue = 50% (median)")
     
     # Side Effect: PNG file
     ggsave(filename = paste0("data_analysis/avl_adherence_histogram", plot_filename, ".png"),
            width = 10, height = 2.5)
     
     # Return: plot
     return(p)
}

avl_year_summary_latlon <- 
     avl_year %>% group_by(longitude_group, latitude_group) %>% 
     summarise(adh_median = median(adherence_seconds), 
               adh_iqr = IQR(adherence_seconds),
               count = n(), 
               lon_min = min(longitude), lon_max = max(longitude), 
               lon_mid = (lon_min + lon_max) / 2,
               lat_min = min(latitude), lat_max = max(latitude),
               lat_mid = (lat_min + lat_max) / 2)

ggplot(avl_year_summary_latlon) + geom_point(aes(lon_mid, lat_mid, color = adh_median, size = count)) +
     scale_color_continuous(low = "red", high = "green") +
     scale_size_area()

ggplot(avl_year_summary_latlon) + geom_point(aes(count, adh_median, size = adh_iqr, color = )) + scale_size_area()