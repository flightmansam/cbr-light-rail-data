from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.encoders import jsonable_encoder

import asyncio
from datetime import datetime
from async_utils import periodic
from cbr_data import get_locations, get_arrivals, get_data, get_live_data, Data, Status, Location, Stop

app = FastAPI()
app.data = get_data()
app.last_request = datetime.now()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

CUSTOM_ENCODERS = {
    Stop: lambda obj: obj.name,
    Status: lambda obj: obj.name
}

async def update_data(app):
    if (datetime.now() - app.last_request).total_seconds() <= 30:
        app.data.feed_data = get_live_data()
    elif app.data.feed_data is not None and  len(app.data.feed_data) > 0:
        app.data.feed_data = None

@app.on_event("startup")
def init_data():
    task = asyncio.create_task(periodic(15.0, update_data, app))

@app.get("/live")
async def live():
    app.last_request = datetime.now()
    if app.data.feed_data is None:
        app.data.feed_data = get_live_data()
    ret = get_locations(app.data)
    return jsonable_encoder(ret, custom_encoder=CUSTOM_ENCODERS)

@app.get("/arrivals/{seq}")
async def arrival(seq:int):
    app.last_request = datetime.now()
    if app.data.feed_data is None:
        app.data.feed_data = get_live_data()
    ret = get_arrivals(app.data, seq)
    return jsonable_encoder(ret, custom_encoder=CUSTOM_ENCODERS)
