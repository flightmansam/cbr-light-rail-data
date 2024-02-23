module cbr_data

import transit_realtime
import vibe
import os
import compress.szip { extract_zip_to_dir }
import encoding.csv
import utils
import stops {Location, Arrival, Status, Stop, get_dest, get_stop}
import time
import arrays
import datatypes

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

	if os.exists(lightrail_pb){
		os.rm(lightrail_pb)!
	}

	print('Downloading lightrail.pb...')
	response := vibe.download_file('http://files.transport.act.gov.au/feeds/lightrail.pb', lightrail_pb) or {
		return []transit_realtime.FeedEntity{}
	}

	live_file := read_bytes(lightrail_pb)!
	unpacked := transit_realtime.feedmessage_unpack(live_file) or { return []transit_realtime.FeedEntity{} }
	active := unpacked.entity
	println("done.")
	return active
}

pub fn get_data() !&Data {
	mut data := Data{}

	temp_dir := os.join_path(os.temp_dir(), 'cbr_light_rail')
	if !os.exists(temp_dir) {
		os.mkdir(temp_dir)!
	}

	lightrail_route_zip := os.join_path(temp_dir, 'route_info.zip')

	if os.exists(lightrail_route_zip){
		os.rm(lightrail_route_zip)!
	}

	print('Downloading lightrail_route.zip...')
	_ := vibe.download_file('https://www.transport.act.gov.au/googletransit/google_transit_lr.zip',
			lightrail_route_zip)!
	println('done.')

	print('Unzipping lightrail_route.zip...')
	extract_zip_to_dir(lightrail_route_zip, temp_dir)!
	print('done.')

	trips_file := os.read_file(os.join_path(temp_dir, 'trips.txt'))!
	trips_decode := csv.decode[utils.Trips](trips_file)

	stops_file := os.read_file(os.join_path(temp_dir, 'stops.txt'))!
	stops_decode := csv.decode[utils.Stops](stops_file)

	stops_times_file := os.read_file(os.join_path(temp_dir, 'stop_times.txt'))!
	mut stops_times_decode := csv.decode[utils.Stop_times](stops_times_file)

	// join the service ID to the stop_times
	mut trip_id_to_service_id := map[string]string{}
	mut trip_id_to_direction_id := map[string]string{}
	for i, trip in trips_decode{
		trip_id_to_service_id[trip.trip_id] = trip.service_id
		trip_id_to_direction_id[trip.trip_id] = trip.direction_id
	}

	for i, mut stop in stops_times_decode{
		stop.service_id = trip_id_to_service_id[stop.trip_id]
		stop.direction_id = trip_id_to_direction_id[stop.trip_id]
		// stops_times_decode[i] = stop
	}

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
			route_dir := trip[0].direction_id
			stop := get_stop(route_id, route_dir, seq)
			dest := get_dest(route_id, route_dir)

			if stop != Stop.nan && dest != Stop.nan {
				loc := Location{
					stop: stop
					dest: dest
					trip_id: trip_id
					seq: seq
					status: status
				}
				locations << loc
			}


		}
	}
	return locations
}


pub fn get_arrivals(data &Data, seq int) []Arrival {
	mut locations := get_locations(data)
	mut next_trips := datatypes.Set[string]{}
	current_trips := locations.map(it.trip_id)

	for i, loc in locations {
		valid_trips := get_next_trip_ids(data, loc.trip_id)
		for j, v in valid_trips{
			if j <= 2 && v !in current_trips {
				next_trips.add(v)
			}
		}
	}

	for nxt, _ in next_trips.elements {
		trip := data.trips.filter(it.trip_id == nxt)
		if trip.len > 0{
			loc := Location{
				stop: Stop.nan
				dest: get_dest(trip[0].route_id, trip[0].direction_id)
				trip_id: nxt
				seq: 0
				status: Status.scheduled
			}
			locations << loc

		}


	}

	mut arrivals := []Arrival{}
	n := time.now()
	n_time_strip := n.ddmmy() // I HATE THAT I HAVE TO DO THIS!!

	for i, entity in locations {
		stop_times := data.stop_times.filter(it.trip_id == entity.trip_id
				&& it.stop_sequence == '${seq}')

		if stop_times.len > 0 {
			stop_time := stop_times[0]
			mut hr := stop_time.departure_time[0..2].int()
			if (hr >= 24) {hr = hr - 24}
			mut departure_time := time.parse_format(n_time_strip + ' ' + '${hr:02}' +stop_time.departure_time[2..stop_time.departure_time.len],
				'DD.MM.YYYY HH:mm:ss') or { time.now() } // V needs better ways to deal with time
			if departure_time.hour == 0 && n.hour == 23 {
				departure_time = departure_time.add_days(1)
			}
			departure_min := f32(departure_time.unix_time() - n.unix_time()) / 60.0
			arr := Arrival{
				Location:entity
				time: departure_time
				time_min: departure_min
			}
			arrivals << arr
		}

	}

	return arrivals
}

pub fn get_next_trip_ids(data &Data, trip_id string) []string {

	trip := data.trips.filter(it.trip_id == trip_id)[0]
	stop := data.stop_times.filter(it.trip_id == trip_id)
	tm := arrays.min(stop.map(it.arrival_time)) or {stop[0].arrival_time}

	mut valid_trips := data.stop_times.filter(
		it.service_id == trip.service_id && 
		it.arrival_time >= tm && 
		it.stop_sequence == '1' &&
		it.direction_id == trip.direction_id)

	if valid_trips.len > 0{
		valid_trips.sort(a.arrival_time < b.arrival_time)
		
		return valid_trips.map(it.trip_id)
	} 

	return []

}

fn read_bytes(path string) ![]u8 {

	def := []u8

	if !os.exists(path) {
		return def
	}

	mut fp := os.open_file(path, 'rb') or {
		eprintln("Failed to open the file: $err")
		return def
	}

	fsize := os.file_size(path)
	
	if fsize == 0 {
		eprintln("file size 0, need to slurp this")
		return def
	}

	res := fp.read_bytes(int(fsize))
	nr_read_elements := res.len

	if nr_read_elements == 0 && fsize > 0 {
		return error('read failed')
	}

	fp.close()
	return res
}