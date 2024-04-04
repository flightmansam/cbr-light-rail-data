module stops

import time

pub enum Status {
	incoming_at   = 0
	stopped_at    = 1
	in_transit_to = 2
	scheduled = 3
}

pub struct Location {
pub mut:
	stop     Stop      // stop that vehicle is currently travelling to/is at
	dest     Stop      // final stop of the route
	trip_id  string
	seq int       // how far along the published route the vehicle is (1 beginning .. n end)
	status   Status // whether the vehicle is incoming_at, stopped_at, in_transit_to, scheduled current_stop
}

pub struct Arrival {
	Location
pub mut:
	time          time.Time // scheduled arrival time to current_stop (accounting for day rollover)
	time_min      f32       // float minutes until arrival at current_stop
}

pub enum Stop {
	alg
	ela
	ipa
	mcr
	dkn
	swn
	plp
	epc
	sfd
	wsn
	nlr
	mpn
	mck
	ggn

	nan
}

const route_head_signs = {
	Stop.alg: 'Alinga Street'
	Stop.ggn: 'Gungahlin Place'
}

const route_names = {
	Stop.alg: "Alinga Street"
	Stop.ggn: "Gungahlin Pl"
}

const stop_short_names = {
	Stop.alg: 'Alinga St'
	Stop.ela: 'Elouera St'
	Stop.ipa: 'Ipima St'
	Stop.mcr: 'Macarthur Av'
	Stop.dkn: 'Dickson'
	Stop.swn: 'Swinden St'
	Stop.plp: 'Phillip Av'
	Stop.epc: 'EPIC'
	Stop.sfd: 'Sandford St'
	Stop.wsn: 'Well Station'
	Stop.nlr: 'Nullarbor Av'
	Stop.mpn: 'Mapleton Av'
	Stop.mck: 'Manning Clk'
	Stop.ggn: 'Gungahlin Pl'
}

pub const stop_to_idx = {
	Stop.alg: 1
	Stop.ela: 2
	Stop.ipa: 3
	Stop.mcr: 4
	Stop.dkn: 5
	Stop.swn: 6
	Stop.plp: 7
	Stop.alg: 1
	Stop.epc: 8
	Stop.sfd: 9
	Stop.wsn: 10
	Stop.nlr: 11
	Stop.mpn: 12
	Stop.mck: 13
	Stop.ggn: 14
}

pub const idx_to_stop = {
	1:  Stop.alg
	2:  Stop.ela
	3:  Stop.ipa
	4:  Stop.mcr
	5:  Stop.dkn
	6:  Stop.swn
	7:  Stop.plp
	8:  Stop.epc
	9:  Stop.sfd
	10: Stop.wsn
	11: Stop.nlr
	12: Stop.mpn
	13: Stop.mck
	14: Stop.ggn
}

pub fn get_dest(route_id string, route_dir string) Stop {
	if route_id == 'ACTO001' {
		return match route_dir {
			"1" {Stop.alg}
			"0" {Stop.ggn}
			else {Stop.nan}
		}	
	} else if route_id == 'X1'{
		return match route_dir {
			"1" {Stop.sfd}
			"0" {Stop.ggn}
			else {Stop.nan}
		}
	} else if route_id == 'X2'{
		return match route_dir {
			"1" {Stop.sfd}
			"0" {Stop.epc}
			else {Stop.nan}
		}
	} else {
		return Stop.nan
	}
}

pub fn get_stop(route_id string, route_dir string, seq int) Stop {
	if route_id == 'ACTO001' {
		return match route_dir {
			"1" {stops.idx_to_stop[15 - seq]}
			"0" {stops.idx_to_stop[seq]}
			else {Stop.nan}
		}
		
	} else if route_id == 'X1'{
		return match route_dir {
			"1" {stops.idx_to_stop[15 - seq]}
			"0" {stops.idx_to_stop[seq]}
			else {Stop.nan}
		}
	} else if route_id == 'X2'{
		return match route_dir {
			"1" {stops.idx_to_stop[15 - seq]}
			"0" {stops.idx_to_stop[seq]}
			else {Stop.nan}
		}
	} else {
		return Stop.nan
	}
}