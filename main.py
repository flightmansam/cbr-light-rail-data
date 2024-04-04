from fastapi import FastAPI

import asyncio
from datetime import datetime
from async_utils import periodic
from cbr_data import get_locations, get_arrivals, get_data, get_live_data, Data

app = FastAPI()
app.data = get_data()
app.last_request = datetime.now()

async def update_data(app):
    if (datetime.now() - app.last_request).total_seconds() <= 30:
        app.data.feed_data = get_live_data()
    elif len(app.data.feed_data) > 0:
        app.data.feed_data = None

@app.on_event("startup")
def init_data():
    task = asyncio.create_task(periodic(15.0, update_data, app))

@app.get("/live")
async def live():
    app.last_request = datetime.now()
    if app.data.feed_data is None:
        app.data.feed_data = get_live_data()
    return get_locations(app.data)

@app.get("/arrivals/{seq}")
async def arrival(seq:int):
    app.last_request = datetime.now()
    if app.data.feed_data is None:
        app.data.feed_data = get_live_data()
    return get_arrivals(app.data, seq)