# Welcome to the code base for the data/API side of the [Canberra Light Rail Tracker](https://cbr-transport.au).

## About
I live in the inner North in Canberra, ACT. We have a [light rail network](https://en.wikipedia.org/wiki/Light_rail_in_Canberra) managed by our local goverment organisation, [Transport Canberra](https://www.transport.act.gov.au/). I was inspred to make this sign to help me catch the light rail without looking like a hot mess as I pegg it to the station or faff about at the stop for 15 minutes when I could be at home chilling. The beautiful light rail wizards at Transport Canberra decided to [give out all of the vehicle location data](https://www.transport.act.gov.au/contact-us/information-for-developers) to anyone freely (CC BY 4.0) to make cool stuff. I wanted a challenge so I went down this rabbit hole and here we are today. This repo contains all the data side of things for my API, https://data.cbr-transport.au. The API is used from my replica of the Transport Canberra stop signage in [this github repo](https://github.com/flightmansam/cbr-light-rail-react).

This API is written using vlang/V. There reason I chose to use it is I wanted a challenge to force myself to jump into the language and this project was the short straw! You can read more about the benefits of vlang [here](https://vlang.io/)! I have been happy with how it has worked for my usecase.

## The API

### /live - Get anything active on the route.

E.g. `https://data.cbr-transport.au/live` returns:
```json
{
[
  "todo"
]
}

```



### /arrivals/<stop_idx> - Get anything active on the route.

E.g. `https://data.cbr-transport.au/arrivals/1` is for all of the scheduled arrivals for Alinga Street and returns:
```json
{
[
  "todo"
]
}

```
