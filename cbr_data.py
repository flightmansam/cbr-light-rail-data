from datetime import datetime, time, timedelta
from typing import List
from google.transit import gtfs_realtime_pb2
from zipfile import ZipFile, BadZipFile
import pycurl
from io import BytesIO
import pandas as pd

from route_info import *

GTFS_RT_URL =    'http://files.transport.act.gov.au/feeds/lightrail.pb'
GTFS_ROUTE_URL = 'https://www.transport.act.gov.au/googletransit/google_transit_lr.zip'

def get_curl_bytes(url: str) -> BytesIO:
    buffer = BytesIO()
    c: Curl = pycurl.Curl()
    c.setopt(c.URL, url)
    c.setopt(c.WRITEDATA, buffer)
    c.perform()

    print(c.getinfo(pycurl.RESPONSE_CODE))
    if c.getinfo(pycurl.RESPONSE_CODE) not in [200, 410, 301]:
        return BytesIO()

    c.close()    

    return buffer
    
def load_route_file_csv(file_name: str, zf: ZipFile):
    if file_name in zf.namelist():
        with zf.open(file_name, 'r') as fh:
            return pd.read_csv(fh)

def get_live_data() -> list:
    feed = gtfs_realtime_pb2.FeedMessage()

    response = get_curl_bytes(GTFS_RT_URL)
    feed.ParseFromString(response.getvalue())

    return feed.entity    

def get_data() -> Data:

    data = Data()

    try:
        lightrail_route = get_curl_bytes(GTFS_ROUTE_URL)
        with ZipFile(lightrail_route, 'r') as zf:
            data.trips = load_route_file_csv('trips.txt', zf)
            data.stops = load_route_file_csv('stops.txt', zf)
            data.stop_times = load_route_file_csv('stop_times.txt', zf)
        
        # Join serviceID and direction to stop times
        data.stop_times = data.trips[['trip_id', 'service_id', 'direction_id']].merge(data.stop_times, left_on='trip_id', right_on='trip_id')

        data.feed_data = get_live_data()
        

    except BadZipFile as e:
        lightrail_route = 'google_transit_lr.zip'

        with ZipFile(lightrail_route, 'r') as zf:
            data.trips = load_route_file_csv('trips.txt', zf)
            data.stops = load_route_file_csv('stops.txt', zf)
            data.stop_times = load_route_file_csv('stop_times.txt', zf)
        
        # Join serviceID and direction to stop times
        data.stop_times = data.trips[['trip_id', 'service_id', 'direction_id']].merge(data.stop_times, left_on='trip_id', right_on='trip_id')

        data.feed_data = get_live_data()
        

    else:
        return data    



    return data

def get_dest(route_id, route_dir):
    print(type(route_id), type(route_dir))
    match (route_id, route_dir):
        case ('ACTO001', 1): return Stop.alg
        case ('ACTO001', 0): return Stop.ggn
        case ('X1',      1): return Stop.sfd
        case ('X1',      0): return Stop.ggn
        case ('X2',      1): return Stop.sfd
        case ('X2',      0): return Stop.epc 
        case _: return Stop.nan

def get_stop(route_dir, seq):
    match route_dir:
        case 1: return Stop(15 - seq)
        case 0: return Stop(seq)
        case _:   return Stop.nan

def get_next_trip_ids(data: Data, trip_id: str) -> List[str]:
    trip = data.trips.loc[data.trips.trip_id == int(trip_id)].iloc[0]
    stop = data.stop_times.loc[data.stop_times.trip_id == int(trip_id)]
    tm = stop.arrival_time.min()

    valid_trips: DataFrame = data.stop_times.loc[
        (data.stop_times.service_id == trip.service_id) &
        (data.stop_times.arrival_time >= tm) &
        (data.stop_times.stop_sequence == 1) &
        (data.stop_times.direction_id == trip.direction_id) ]
    if valid_trips.shape[0] > 0:
        valid_trips.sort_values(by='arrival_time', inplace=True)

        return valid_trips.trip_id.to_list()

def get_locations(data: Data) -> List[Location]:

    locations = []

    for i, entity in enumerate(data.feed_data):
        trip_id = entity.vehicle.trip.trip_id
        if trip_id == '': continue
        stop_id = entity.vehicle.stop_id
        seq = entity.vehicle.current_stop_sequence
        status = Status(entity.vehicle.current_status)
        trip = data.trips.loc[data.trips.trip_id == int(trip_id)]

        if trip.shape[0] > 0:
            trip = trip.iloc[0]
            route_id = trip.route_id
            route_dir = trip.direction_id
            stop = get_stop(route_dir, seq)
            dest = get_dest(route_id, route_dir)

            if stop != Stop.nan and dest != Stop.nan:
                loc = Location(
                    stop=stop,
                    dest=dest,
                    trip_id=trip_id,
                    seq=seq,
                    status=status
                )
                locations.append(loc)
    
    return locations   

def get_arrivals(data: Data, seq: int) -> List[Arrival]:
    locations = get_locations(data)
    next_trips = set()
    current_trips = [str(l.trip_id) for l in locations]

    for loc in locations:
        valid_trips = get_next_trip_ids(data, loc.trip_id)
        for i, v in enumerate(valid_trips):
            v = str(v)
            if i <= 4 and v not in current_trips: next_trips.add(v)

    for nxt in next_trips:
        trip = data.trips.loc[data.trips.trip_id == int(nxt)]

        if trip.shape[0] > 0:
            trip = trip.iloc[0]
            loc = Location(
                stop=Stop.nan,
                dest=get_dest(trip.route_id, trip.direction_id),
                trip_id=str(nxt),
                seq=0,
                status=Status.scheduled
            )
            locations.append(loc)   

    arrivals = []
    n = datetime.now()

    for loc in locations:
        
        stop_times = data.stop_times.loc[
            (data.stop_times.trip_id == int(loc.trip_id)) & 
            (data.stop_times.stop_sequence == int(seq))]

        if stop_times.shape[0] > 0:
            stop_time = stop_times.departure_time.iloc[0]

            hr = int(stop_time[0:2])
            if hr >= 24: hr -= 24
            mn = int(stop_time[3:5])
            sec = int(stop_time[6:8])

            departure_time = datetime.combine(n.date(), time(hour=hr, minute=mn, second=sec))
            if departure_time.hour == 0 and n.hour == 23:
                departure_time += timedelta(days=1)

            departure_min = (departure_time - n).total_seconds() / 60.0
            arrival = Arrival(
                Location=Location(
                    stop=loc.stop,
                    dest=loc.dest,
                    trip_id=loc.trip_id,
                    seq=loc.seq,
                    status=loc.status),
                time= departure_time,
                time_min=departure_min
            )
            arrivals.append(arrival)

    return arrivals


if __name__ == "__main__":
    d = get_data()

    print(get_arrivals(d, 1))    


    

    
