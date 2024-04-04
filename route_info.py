from dataclasses import dataclass, field
from enum import IntEnum, auto
import pandas as pd
from datetime import datetime

@dataclass
class Data:
    feed_data:  list = field(default_factory=list)
    trips:      pd.DataFrame = field(default_factory=pd.DataFrame)
    stop_times: pd.DataFrame = field(default_factory=pd.DataFrame)
    stops:      pd.DataFrame = field(default_factory=pd.DataFrame)

class Stop(IntEnum):
    alg = 1
    ela = auto()
    ipa = auto()
    mcr = auto()
    dkn = auto()
    swn = auto()
    plp = auto()
    epc = auto()
    sfd = auto()
    wsn = auto()
    nlr = auto()
    mpn = auto()
    mck = auto()
    ggn = auto()

    nan = auto()


class Status(IntEnum):
    incoming_at =   0
    stopped_at =    auto()
    in_transit_to = auto()
    scheduled =     auto()

@dataclass
class Location:
    stop: Stop
    dest: Stop
    trip_id: str
    seq: int
    status: Status    

@dataclass
class Arrival:
    Location: Location = None
    time: datetime = None
    time_min: float = None