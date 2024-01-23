module cbr_data

import transit_realtime
import vibe
import os
import compress.szip { extract_zip_to_dir }
import encoding.csv
import utils
import stops {Location, Arrival, Status, Stop}
import time


pub struct Data {
pub mut:
	feed_data  []transit_realtime.FeedEntity
	trips      []utils.Trips
	stop_times []utils.Stop_times
	stops      []utils.Stops
}

pub fn get_live_data() ![]transit_realtime.FeedEntity {
	temp_dir := os.join_path(os.temp_dir(), 'cbr_light_rail')
	if !os.exists(temp_dir) {
		os.mkdir(temp_dir)!
	}

	lightrail_pb := os.join_path(temp_dir, 'lightrail.pb')

	println('Downloading lightrail.pb...')
	response := vibe.download_file('http://files.transport.act.gov.au/feeds/lightrail.pb', lightrail_pb) or {
		return []transit_realtime.FeedEntity{}
	}
	print("status= ")
	println(response.status)


	live_file := os.read_bytes(lightrail_pb)!
	println("bytes read")
	unpacked := transit_realtime.feedmessage_unpack(live_file) or { return []transit_realtime.FeedEntity{} }
	println("unpacked")
	active := unpacked.entity
	println('...done!')
	return active
}

pub fn get_data() !&Data {
	mut data := Data{}

	temp_dir := os.join_path(os.temp_dir(), 'cbr_light_rail')
	if !os.exists(temp_dir) {
		os.mkdir(temp_dir)!
	}

	lightrail_route_zip := os.join_path(temp_dir, 'route_info.zip')

	if !os.exists(lightrail_route_zip) {
		_ := vibe.download_file('https://www.transport.act.gov.au/googletransit/google_transit_lr.zip',
			lightrail_route_zip)!
		println('Downloading lightrail_route.zip...')
		extract_zip_to_dir(lightrail_route_zip, temp_dir)!
		println('Unzipping lightrail_route.zip...')
	}

	trips_file := os.read_file(os.join_path(temp_dir, 'trips.txt'))!
	trips_decode := csv.decode[utils.Trips](trips_file)

	stops_file := os.read_file(os.join_path(temp_dir, 'stops.txt'))!
	stops_decode := csv.decode[utils.Stops](stops_file)

	stops_times_file := os.read_file(os.join_path(temp_dir, 'stop_times.txt'))!
	stops_times_decode := csv.decode[utils.Stop_times](stops_times_file)

	data.feed_data = get_live_data()!
	data.stop_times = stops_times_decode
	data.stops = stops_decode
	data.trips = trips_decode

	return &data
}

// current locations of active vehicles on the ACT001 route
pub fn get_locations(data &Data) []Location {
	mut locations := []Location{}

	for i, entity in data.feed_data {
		trip_id := entity.vehicle.trip.trip_id
		stop_id := entity.vehicle.stop_id
		seq := entity.vehicle.current_stop_sequence
		status := match entity.vehicle.current_status {
			.incoming_at { Status.incoming_at}
			.stopped_at {Status.stopped_at}
			.in_transit_to {Status.in_transit_to}
		}
		
		trip := data.trips.filter(it.trip_id==trip_id)
		if trip_id.len > 0 {
			route_id := trip[0].route_id
			if route_id == 'ACTO001' {
				route_dir := trip[0].direction_id

				dest := match route_dir {
					"1" {Stop.alg}
					"0" {Stop.ggn}
					else {Stop.nan}
				}

				stop := match route_dir {
					"1" {stops.idx_to_stop[15 - seq]}
					"0" {stops.idx_to_stop[seq]}
					else {Stop.nan}
				}

				loc := Location{
					stop: stop
					dest: dest
					trip_id: trip_id
					seq: seq
					status: status
				}
				locations << loc
				
			} 
			// else {
			// 	println("[WARN]: '${route_id}' is a non standard route id! ")
			// }	
		}
	}
	return locations
}


pub fn get_arrivals(data &Data, seq int) []Arrival {
	locations := get_locations(data)
	mut arrivals := []Arrival{}
	n := time.now()
	n_time_strip := n.ddmmy() // I HATE THAT I HAVE TO DO THIS!!

	for i, entity in locations {
		stop_times := data.stop_times.filter(it.trip_id == entity.trip_id
				&& it.stop_sequence == '${seq}')

		if stop_times.len > 0 {
			stop_time := stop_times[0]
			mut hr := stop_time.arrival_time[0..2].int()
			if (hr >= 24) {hr = hr - 24}
			mut arrival_time := time.parse_format(n_time_strip + ' ' + '${hr:02}' +stop_time.arrival_time[2..stop_time.arrival_time.len],
				'DD.MM.YYYY HH:mm:ss') or { time.now() } // V needs better ways to deal with time
			if arrival_time.hour == 0 && n.hour == 23 {
				arrival_time = arrival_time.add_days(1)
			}
			arrival_min := f32(arrival_time.unix_time() - n.unix_time()) / 60.0
			arr := Arrival{
				Location:entity
				time: arrival_time
				time_min: arrival_min
			}
			arrivals << arr
		}

	}

	return arrivals
}

		// route_id
		// current_status := entity.vehicle.current_status
		// scheduled_stops := ctx.tcc_data.stop_times.filter(it.trip_id == trip_id
		// 	&& it.stop_id == stop_id && it.stop_headsign == route_head_signs[ctx.selected_route])
		// if scheduled_stops.len > 0 {
		// 	scheduled_stop := scheduled_stops[0]
		// 	stop_seq := scheduled_stop.stop_sequence.int()

		// 	current_stop := match ctx.selected_route {
		// 		.alg { idx_to_stop[15 - stop_seq] }
		// 		.ggn { idx_to_stop[stop_seq] }
		// 		else { Stop.alg }
		// 	}

		// 	mut arr := Arrival{
		// 		current_stop: current_stop
		// 		current_stop_seq: stop_seq
		// 		current_status: current_status
		// 	}