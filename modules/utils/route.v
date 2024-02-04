module utils

pub struct Trips {
pub:
	route_id              string
	service_id            string
	trip_id               string
	trip_headsign         string
	direction_id          string
	block_id              string
	shape_id              string
	wheelchair_accessible string
	bikes_allowed         string
}

pub struct Stops {
pub:
	stop_id             string
	stop_name           string
	stop_lat            string
	stop_lon            string
	stop_url            string
	location_type       string
	wheelchair_boarding string
	parent_station      string
}

pub struct Stop_times {
pub mut:
	trip_id        string
	arrival_time   string
	departure_time string
	stop_id        string
	stop_sequence  string
	stop_headsign  string
	direction_id   string
	pickup_type    string
	drop_off_type  string
	timepoint      string
	service_id 	   string
}