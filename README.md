# Welcome to the code base for the data/API side of the [Canberra Light Rail Tracker](https://cbr-transport.au).

## About
I live in the inner North in Canberra, ACT. We have a [light rail network](https://en.wikipedia.org/wiki/Light_rail_in_Canberra) managed by our local goverment organisation, [Transport Canberra](https://www.transport.act.gov.au/). I was inspred to make this sign to help me catch the light rail without looking like a hot mess as I pegg it to the station or faff about at the stop for 15 minutes when I could be at home chilling. The beautiful light rail wizards at Transport Canberra decided to [give out all of the vehicle location data](https://www.transport.act.gov.au/contact-us/information-for-developers) to anyone freely (CC BY 4.0) to make cool stuff. I wanted a challenge so I went down this rabbit hole and here we are today. This repo contains all the data side of things for my API, https://data.cbr-transport.au. The API is used from my replica of the Transport Canberra stop signage in [this github repo](https://github.com/flightmansam/cbr-light-rail-react).

This API is written using vlang/V. There reason I chose to use it is I wanted a challenge to force myself to jump into the language and this project was the short straw! You can read more about the benefits of vlang [here](https://vlang.io/)! I have been happy with how it has worked for my usecase.

There is no rate limiting or credentials required for this API. But please fork it and run it yourself if you intend to do anything heavy.

## The API

### `/live` - Get anything active on the route.

E.g. `https://data.cbr-transport.au/live` returns:
```jsonc
[
  {
    "stop": "nlr",         // current target stop
    "dest": "alg",         // final destination
    "trip_id": "204",      // Transport Canberra trip id
    "seq": 4,              // how long along the route
    "status": "stopped_at" //status of the trip 
  },
  ...
]
```



### `/arrivals/<stop_idx>` - Get any scheduled arrivals for this particular stop.
stop_idx is an int between 1 and 14 for each consecutive stop on the current Canberra Light Rail network. 1 is Alinga Street and 14 is Gungahlin Place. 

E.g. `https://data.cbr-transport.au/arrivals/1` is for all of the scheduled arrivals for Alinga Street and returns:
```jsonc
[
  {
    "Location": {
      "stop": "epc",            // current target stop
      "dest": "ggn",            // final destination
      "trip_id": "73",          // Transport Canberra trip id
      "seq": 8,                 // how long along the route
      "status": "in_transit_to" //status of the trip 
    },
    "time": 1708947000, // scheduled arrival time at this stop
    "time_min": 2.57    // minutes from now 
  },
  ...
]
```
