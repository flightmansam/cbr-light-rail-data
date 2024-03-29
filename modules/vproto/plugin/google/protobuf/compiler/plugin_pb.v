// Generated by vproto - Do not modify
module compiler

import emily33901.vproto
import vproto.plugin.google.protobuf

pub struct Version {
mut:
	unknown_fields []vproto.UnknownField
pub mut:
	major      int
	has_major  bool
	minor      int
	has_minor  bool
	patch      int
	has_patch  bool
	suffix     string
	has_suffix bool
}

pub fn new_version() Version {
	return Version{}
}

pub fn (o &Version) pack() []byte {
	mut res := []byte{}
	if o.has_major {
		res << vproto.pack_int32_field(o.major, 1)
	}
	if o.has_minor {
		res << vproto.pack_int32_field(o.minor, 2)
	}
	if o.has_patch {
		res << vproto.pack_int32_field(o.patch, 3)
	}
	if o.has_suffix {
		res << vproto.pack_string_field(o.suffix, 4)
	}
	return res
}

pub fn version_unpack(buf []byte) ?Version {
	mut res := Version{}
	mut total := 0
	for total < buf.len {
		mut i := 0
		buf_before_wire_type := buf[total..]
		tag_wiretype := vproto.unpack_tag_wire_type(buf_before_wire_type) or {
			return error('malformed protobuf (couldnt parse tag & wire type)')
		}
		cur_buf := buf_before_wire_type[tag_wiretype.consumed..]
		match tag_wiretype.tag {
			1 {
				res.has_major = true
				ii, v := vproto.unpack_int32_field(cur_buf, tag_wiretype.wire_type)
				res.major = v
				i = ii
			}
			2 {
				res.has_minor = true
				ii, v := vproto.unpack_int32_field(cur_buf, tag_wiretype.wire_type)
				res.minor = v
				i = ii
			}
			3 {
				res.has_patch = true
				ii, v := vproto.unpack_int32_field(cur_buf, tag_wiretype.wire_type)
				res.patch = v
				i = ii
			}
			4 {
				res.has_suffix = true
				ii, v := vproto.unpack_string_field(cur_buf, tag_wiretype.wire_type)
				res.suffix = v
				i = ii
			}
			else {
				ii, v := vproto.unpack_unknown_field(cur_buf, tag_wiretype.wire_type)
				res.unknown_fields << vproto.UnknownField{tag_wiretype.wire_type, tag_wiretype.tag, v}
				i = ii
			}
		}
		if i == 0 {
			return error('malformed protobuf (didnt unpack a field)')
		}
		total += tag_wiretype.consumed + i
	}
	return res
}

pub fn pack_version(o Version, num u32) []byte {
	return vproto.pack_message_field(o.pack(), num)
}

pub fn unpack_version(buf []byte, tag_wiretype vproto.WireType) (int, Version) {
	i, v := vproto.unpack_message_field(buf, tag_wiretype)
	unpacked := version_unpack(v) or { panic('') }
	return i, unpacked
}

pub struct CodeGeneratorRequest {
mut:
	unknown_fields []vproto.UnknownField
pub mut:
	file_to_generate     []string
	parameter            string
	has_parameter        bool
	proto_file           []protobuf.FileDescriptorProto
	compiler_version     Version
	has_compiler_version bool
}

pub fn new_codegeneratorrequest() CodeGeneratorRequest {
	return CodeGeneratorRequest{}
}

pub fn (o &CodeGeneratorRequest) pack() []byte {
	mut res := []byte{}
	// [packed=false]
	for _, x in o.file_to_generate {
		res << vproto.pack_string_field(x, 1)
	}
	if o.has_parameter {
		res << vproto.pack_string_field(o.parameter, 2)
	}
	// [packed=false]
	for _, x in o.proto_file {
		res << protobuf.pack_filedescriptorproto(x, 15)
	}
	if o.has_compiler_version {
		res << pack_version(o.compiler_version, 3)
	}
	return res
}

pub fn codegeneratorrequest_unpack(buf []byte) ?CodeGeneratorRequest {
	mut res := CodeGeneratorRequest{}
	mut total := 0
	for total < buf.len {
		mut i := 0
		buf_before_wire_type := buf[total..]
		tag_wiretype := vproto.unpack_tag_wire_type(buf_before_wire_type) or {
			return error('malformed protobuf (couldnt parse tag & wire type)')
		}
		cur_buf := buf_before_wire_type[tag_wiretype.consumed..]
		match tag_wiretype.tag {
			1 {
				// [packed=false]
				ii, v := vproto.unpack_string_field(cur_buf, tag_wiretype.wire_type)
				res.file_to_generate << v
				i = ii
			}
			2 {
				res.has_parameter = true
				ii, v := vproto.unpack_string_field(cur_buf, tag_wiretype.wire_type)
				res.parameter = v
				i = ii
			}
			15 {
				// [packed=false]
				ii, v := protobuf.unpack_filedescriptorproto(cur_buf, tag_wiretype.wire_type)
				res.proto_file << v
				i = ii
			}
			3 {
				res.has_compiler_version = true
				ii, v := unpack_version(cur_buf, tag_wiretype.wire_type)
				res.compiler_version = v
				i = ii
			}
			else {
				ii, v := vproto.unpack_unknown_field(cur_buf, tag_wiretype.wire_type)
				res.unknown_fields << vproto.UnknownField{tag_wiretype.wire_type, tag_wiretype.tag, v}
				i = ii
			}
		}
		if i == 0 {
			return error('malformed protobuf (didnt unpack a field)')
		}
		total += tag_wiretype.consumed + i
	}
	return res
}

pub fn pack_codegeneratorrequest(o CodeGeneratorRequest, num u32) []byte {
	return vproto.pack_message_field(o.pack(), num)
}

pub fn unpack_codegeneratorrequest(buf []byte, tag_wiretype vproto.WireType) (int, CodeGeneratorRequest) {
	i, v := vproto.unpack_message_field(buf, tag_wiretype)
	unpacked := codegeneratorrequest_unpack(v) or { panic('') }
	return i, unpacked
}

pub struct CodeGeneratorResponseFile {
mut:
	unknown_fields []vproto.UnknownField
pub mut:
	name                string
	has_name            bool
	insertion_point     string
	has_insertion_point bool
	content             string
	has_content         bool
}

pub fn new_codegeneratorresponsefile() CodeGeneratorResponseFile {
	return CodeGeneratorResponseFile{}
}

pub fn (o &CodeGeneratorResponseFile) pack() []byte {
	mut res := []byte{}
	if o.has_name {
		res << vproto.pack_string_field(o.name, 1)
	}
	if o.has_insertion_point {
		res << vproto.pack_string_field(o.insertion_point, 2)
	}
	if o.has_content {
		res << vproto.pack_string_field(o.content, 15)
	}
	return res
}

pub fn codegeneratorresponsefile_unpack(buf []byte) ?CodeGeneratorResponseFile {
	mut res := CodeGeneratorResponseFile{}
	mut total := 0
	for total < buf.len {
		mut i := 0
		buf_before_wire_type := buf[total..]
		tag_wiretype := vproto.unpack_tag_wire_type(buf_before_wire_type) or {
			return error('malformed protobuf (couldnt parse tag & wire type)')
		}
		cur_buf := buf_before_wire_type[tag_wiretype.consumed..]
		match tag_wiretype.tag {
			1 {
				res.has_name = true
				ii, v := vproto.unpack_string_field(cur_buf, tag_wiretype.wire_type)
				res.name = v
				i = ii
			}
			2 {
				res.has_insertion_point = true
				ii, v := vproto.unpack_string_field(cur_buf, tag_wiretype.wire_type)
				res.insertion_point = v
				i = ii
			}
			15 {
				res.has_content = true
				ii, v := vproto.unpack_string_field(cur_buf, tag_wiretype.wire_type)
				res.content = v
				i = ii
			}
			else {
				ii, v := vproto.unpack_unknown_field(cur_buf, tag_wiretype.wire_type)
				res.unknown_fields << vproto.UnknownField{tag_wiretype.wire_type, tag_wiretype.tag, v}
				i = ii
			}
		}
		if i == 0 {
			return error('malformed protobuf (didnt unpack a field)')
		}
		total += tag_wiretype.consumed + i
	}
	return res
}

pub fn pack_codegeneratorresponsefile(o CodeGeneratorResponseFile, num u32) []byte {
	return vproto.pack_message_field(o.pack(), num)
}

pub fn unpack_codegeneratorresponsefile(buf []byte, tag_wiretype vproto.WireType) (int, CodeGeneratorResponseFile) {
	i, v := vproto.unpack_message_field(buf, tag_wiretype)
	unpacked := codegeneratorresponsefile_unpack(v) or { panic('') }
	return i, unpacked
}

pub struct CodeGeneratorResponse {
mut:
	unknown_fields []vproto.UnknownField
pub mut:
	error_     string
	has_error_ bool
	file       []CodeGeneratorResponseFile
}

pub fn new_codegeneratorresponse() CodeGeneratorResponse {
	return CodeGeneratorResponse{}
}

pub fn (o &CodeGeneratorResponse) pack() []byte {
	mut res := []byte{}
	if o.has_error_ {
		res << vproto.pack_string_field(o.error_, 1)
	}
	// [packed=false]
	for _, x in o.file {
		res << pack_codegeneratorresponsefile(x, 15)
	}
	return res
}

pub fn codegeneratorresponse_unpack(buf []byte) ?CodeGeneratorResponse {
	mut res := CodeGeneratorResponse{}
	mut total := 0
	for total < buf.len {
		mut i := 0
		buf_before_wire_type := buf[total..]
		tag_wiretype := vproto.unpack_tag_wire_type(buf_before_wire_type) or {
			return error('malformed protobuf (couldnt parse tag & wire type)')
		}
		cur_buf := buf_before_wire_type[tag_wiretype.consumed..]
		match tag_wiretype.tag {
			1 {
				res.has_error_ = true
				ii, v := vproto.unpack_string_field(cur_buf, tag_wiretype.wire_type)
				res.error_ = v
				i = ii
			}
			15 {
				// [packed=false]
				ii, v := unpack_codegeneratorresponsefile(cur_buf, tag_wiretype.wire_type)
				res.file << v
				i = ii
			}
			else {
				ii, v := vproto.unpack_unknown_field(cur_buf, tag_wiretype.wire_type)
				res.unknown_fields << vproto.UnknownField{tag_wiretype.wire_type, tag_wiretype.tag, v}
				i = ii
			}
		}
		if i == 0 {
			return error('malformed protobuf (didnt unpack a field)')
		}
		total += tag_wiretype.consumed + i
	}
	return res
}

pub fn pack_codegeneratorresponse(o CodeGeneratorResponse, num u32) []byte {
	return vproto.pack_message_field(o.pack(), num)
}

pub fn unpack_codegeneratorresponse(buf []byte, tag_wiretype vproto.WireType) (int, CodeGeneratorResponse) {
	i, v := vproto.unpack_message_field(buf, tag_wiretype)
	unpacked := codegeneratorresponse_unpack(v) or { panic('') }
	return i, unpacked
}
