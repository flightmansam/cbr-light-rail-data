module utils

import math { atan2, cos, pow, sin }

pub struct Geo_location_t {
	latitude  f64
	longitude f64
}

fn dg_to_rad(d f64) f64 {
	return d * 3.1415926535897931 / 180
}

pub fn haversine_distance(pa Geo_location_t, pb Geo_location_t) f64 {
	earth_radius := 6371000
	lat_a := dg_to_rad(pa.latitude)
	lat_b := dg_to_rad(pb.latitude)
	lat_diff := dg_to_rad(pb.latitude - pa.latitude)
	lon_diff := dg_to_rad(pb.longitude - pa.longitude)
	a := pow(sin(lat_diff / 2), 2) + cos(lat_a) * cos(lat_b) * pow(sin(lon_diff / 2), 2)
	c := 2 * atan2(C.sqrt(a), C.sqrt(1 - a))
	return c * earth_radius
}
