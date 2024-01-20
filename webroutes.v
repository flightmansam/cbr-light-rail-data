import vweb
// import x.json2
import json
import cbr_data
import time
import stops {Location}

// @["/test/:stop_id"; get]
// pub fn (mut app App) test(stop_id string) vweb.Result {
// 	println(app)
// 	return app.json("{yee:${stop_id}}")
// } 

@["/live"]
pub fn (mut app App) live() vweb.Result {

	mut locs := []Location{}
	mut data := &cbr_data.Data{}

	lock app.sd_data {
		data = app.sd_data.data
		app.sd_data.last_request = time.now()
	}

	locs = cbr_data.get_locations(data)

	return app.json(locs)
} 