module main

import vweb
import time
import transit_realtime
import cbr_data  {Data, get_data, get_live_data}

const http_port = 4050
const request_alive_time_seconds = 60.0 * 0.5 // how long to keep downloading data from cbr_data infowhen to sleep

struct SdData {
	mut:
	data  &Data = &Data{}
	last_request time.Time
}

struct App {
	vweb.Context
	sd_data shared SdData
}

pub fn (mut app App) before_request() {
	app.add_header('Access-Control-Allow-Origin', '*')
	// println('[Vweb] ${app.Context.req.method} ${app.Context.req.url}')
}


fn data_handling(shared data SdData) {
	mut now := time.now()
	lock data {
			data.data = get_data() or {&Data{}}
			data.last_request = now
	}

	mut last := now

	for true {
		now = time.now()
		mut last_request := now

		rlock data {
			last_request = data.last_request
		}
		
		if (now - last_request).seconds() < request_alive_time_seconds {
			if (now - last).seconds() > 15.0{
						new_data := get_live_data() or {[]transit_realtime.FeedEntity{}}
						lock data {
							data.data.feed_data = new_data
						}
						last = now;
					}
		} else {
			lock data {
				data.data.feed_data = []transit_realtime.FeedEntity{}
			}
			
		}
		
	}
}

fn main() {
	shared sd_data := &SdData{}
	// mut app :=new_app(shared sd_data)
	mut app := App{
		sd_data: sd_data
	}

	spawn data_handling(shared sd_data)
	vweb.run_at(app, vweb.RunParams{port: http_port}) or { panic(err) }
}
