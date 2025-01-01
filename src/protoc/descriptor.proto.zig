const std = @import("std");
const gremlin = @import("gremlin");

// structs
const FileDescriptorSetWire = struct {
    const FILE_WIRE: gremlin.ProtoWireNumber = 1;
};

pub const FileDescriptorSet = struct {
    // fields
    file: ?[]const ?FileDescriptorProto = null,

    pub fn calcProtobufSize(self: *const FileDescriptorSet) usize {
        var res: usize = 0;
        if (self.file) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorSetWire.FILE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const FileDescriptorSet, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const FileDescriptorSet, target: *gremlin.Writer) void {
        if (self.file) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(FileDescriptorSetWire.FILE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(FileDescriptorSetWire.FILE_WIRE, 0);
                }
            }
        }
    }
};

pub const FileDescriptorSetReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _file_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!FileDescriptorSetReader {
        var buf = gremlin.Reader.init(src);
        var res = FileDescriptorSetReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                FileDescriptorSetWire.FILE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._file_bufs == null) {
                        res._file_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._file_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const FileDescriptorSetReader) void {
        if (self._file_bufs) |arr| {
            arr.deinit();
        }
    }
    pub fn getFile(self: *const FileDescriptorSetReader, allocator: std.mem.Allocator) gremlin.Error![]FileDescriptorProtoReader {
        if (self._file_bufs) |bufs| {
            var result = try std.ArrayList(FileDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try FileDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]FileDescriptorProtoReader{};
    }
};

const FileDescriptorProtoWire = struct {
    const NAME_WIRE: gremlin.ProtoWireNumber = 1;
    const PACKAGE_WIRE: gremlin.ProtoWireNumber = 2;
    const DEPENDENCY_WIRE: gremlin.ProtoWireNumber = 3;
    const PUBLIC_DEPENDENCY_WIRE: gremlin.ProtoWireNumber = 10;
    const WEAK_DEPENDENCY_WIRE: gremlin.ProtoWireNumber = 11;
    const MESSAGE_TYPE_WIRE: gremlin.ProtoWireNumber = 4;
    const ENUM_TYPE_WIRE: gremlin.ProtoWireNumber = 5;
    const SERVICE_WIRE: gremlin.ProtoWireNumber = 6;
    const EXTENSION_WIRE: gremlin.ProtoWireNumber = 7;
    const OPTIONS_WIRE: gremlin.ProtoWireNumber = 8;
    const SOURCE_CODE_INFO_WIRE: gremlin.ProtoWireNumber = 9;
    const SYNTAX_WIRE: gremlin.ProtoWireNumber = 12;
};

pub const FileDescriptorProto = struct {
    // fields
    name: ?[]const u8 = null,
    package: ?[]const u8 = null,
    dependency: ?[]const ?[]const u8 = null,
    public_dependency: ?[]const i32 = null,
    weak_dependency: ?[]const i32 = null,
    message_type: ?[]const ?DescriptorProto = null,
    enum_type: ?[]const ?EnumDescriptorProto = null,
    service: ?[]const ?ServiceDescriptorProto = null,
    extension: ?[]const ?FieldDescriptorProto = null,
    options: ?FileOptions = null,
    source_code_info: ?SourceCodeInfo = null,
    syntax: ?[]const u8 = null,

    pub fn calcProtobufSize(self: *const FileDescriptorProto) usize {
        var res: usize = 0;
        if (self.name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.package) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.PACKAGE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.dependency) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.DEPENDENCY_WIRE);
                if (maybe_v) |v| {
                    res += gremlin.sizes.sizeUsize(v.len) + v.len;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.public_dependency) |arr| {
            if (arr.len == 0) {} else if (arr.len == 1) {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.PUBLIC_DEPENDENCY_WIRE) + gremlin.sizes.sizeI32(arr[0]);
            } else {
                var packed_size: usize = 0;
                for (arr) |v| {
                    packed_size += gremlin.sizes.sizeI32(v);
                }
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.PUBLIC_DEPENDENCY_WIRE) + gremlin.sizes.sizeUsize(packed_size) + packed_size;
            }
        }
        if (self.weak_dependency) |arr| {
            if (arr.len == 0) {} else if (arr.len == 1) {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.WEAK_DEPENDENCY_WIRE) + gremlin.sizes.sizeI32(arr[0]);
            } else {
                var packed_size: usize = 0;
                for (arr) |v| {
                    packed_size += gremlin.sizes.sizeI32(v);
                }
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.WEAK_DEPENDENCY_WIRE) + gremlin.sizes.sizeUsize(packed_size) + packed_size;
            }
        }
        if (self.message_type) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.MESSAGE_TYPE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.enum_type) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.ENUM_TYPE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.service) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.SERVICE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.extension) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.EXTENSION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.OPTIONS_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        if (self.source_code_info) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.SOURCE_CODE_INFO_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        if (self.syntax) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileDescriptorProtoWire.SYNTAX_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        return res;
    }

    pub fn encode(self: *const FileDescriptorProto, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const FileDescriptorProto, target: *gremlin.Writer) void {
        if (self.name) |v| {
            if (v.len > 0) {
                target.appendBytes(FileDescriptorProtoWire.NAME_WIRE, v);
            }
        }
        if (self.package) |v| {
            if (v.len > 0) {
                target.appendBytes(FileDescriptorProtoWire.PACKAGE_WIRE, v);
            }
        }
        if (self.dependency) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    target.appendBytes(FileDescriptorProtoWire.DEPENDENCY_WIRE, v);
                } else {
                    target.appendBytesTag(FileDescriptorProtoWire.DEPENDENCY_WIRE, 0);
                }
            }
        }
        if (self.public_dependency) |arr| {
            if (arr.len == 0) {} else if (arr.len == 1) {
                target.appendInt32(FileDescriptorProtoWire.PUBLIC_DEPENDENCY_WIRE, arr[0]);
            } else {
                var packed_size: usize = 0;
                for (arr) |v| {
                    packed_size += gremlin.sizes.sizeI32(v);
                }
                target.appendBytesTag(FileDescriptorProtoWire.PUBLIC_DEPENDENCY_WIRE, packed_size);
                for (arr) |v| {
                    target.appendInt32WithoutTag(v);
                }
            }
        }
        if (self.weak_dependency) |arr| {
            if (arr.len == 0) {} else if (arr.len == 1) {
                target.appendInt32(FileDescriptorProtoWire.WEAK_DEPENDENCY_WIRE, arr[0]);
            } else {
                var packed_size: usize = 0;
                for (arr) |v| {
                    packed_size += gremlin.sizes.sizeI32(v);
                }
                target.appendBytesTag(FileDescriptorProtoWire.WEAK_DEPENDENCY_WIRE, packed_size);
                for (arr) |v| {
                    target.appendInt32WithoutTag(v);
                }
            }
        }
        if (self.message_type) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(FileDescriptorProtoWire.MESSAGE_TYPE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(FileDescriptorProtoWire.MESSAGE_TYPE_WIRE, 0);
                }
            }
        }
        if (self.enum_type) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(FileDescriptorProtoWire.ENUM_TYPE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(FileDescriptorProtoWire.ENUM_TYPE_WIRE, 0);
                }
            }
        }
        if (self.service) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(FileDescriptorProtoWire.SERVICE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(FileDescriptorProtoWire.SERVICE_WIRE, 0);
                }
            }
        }
        if (self.extension) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(FileDescriptorProtoWire.EXTENSION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(FileDescriptorProtoWire.EXTENSION_WIRE, 0);
                }
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(FileDescriptorProtoWire.OPTIONS_WIRE, size);
                v.encodeTo(target);
            }
        }
        if (self.source_code_info) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(FileDescriptorProtoWire.SOURCE_CODE_INFO_WIRE, size);
                v.encodeTo(target);
            }
        }
        if (self.syntax) |v| {
            if (v.len > 0) {
                target.appendBytes(FileDescriptorProtoWire.SYNTAX_WIRE, v);
            }
        }
    }
};

pub const FileDescriptorProtoReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _name: ?[]const u8 = null,
    _package: ?[]const u8 = null,
    _dependency: ?std.ArrayList([]const u8) = null,
    _public_dependency_offsets: ?std.ArrayList(usize) = null,
    _public_dependency_wires: ?std.ArrayList(gremlin.ProtoWireType) = null,
    _weak_dependency_offsets: ?std.ArrayList(usize) = null,
    _weak_dependency_wires: ?std.ArrayList(gremlin.ProtoWireType) = null,
    _message_type_bufs: ?std.ArrayList([]const u8) = null,
    _enum_type_bufs: ?std.ArrayList([]const u8) = null,
    _service_bufs: ?std.ArrayList([]const u8) = null,
    _extension_bufs: ?std.ArrayList([]const u8) = null,
    _options_buf: ?[]const u8 = null,
    _source_code_info_buf: ?[]const u8 = null,
    _syntax: ?[]const u8 = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!FileDescriptorProtoReader {
        var buf = gremlin.Reader.init(src);
        var res = FileDescriptorProtoReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                FileDescriptorProtoWire.NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._name = result.value;
                },
                FileDescriptorProtoWire.PACKAGE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._package = result.value;
                },
                FileDescriptorProtoWire.DEPENDENCY_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._dependency == null) {
                        res._dependency = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._dependency.?.append(result.value);
                },
                FileDescriptorProtoWire.PUBLIC_DEPENDENCY_WIRE => {
                    if (res._public_dependency_offsets == null) {
                        res._public_dependency_offsets = std.ArrayList(usize).init(allocator);
                        res._public_dependency_wires = std.ArrayList(gremlin.ProtoWireType).init(allocator);
                    }
                    try res._public_dependency_offsets.?.append(offset);
                    try res._public_dependency_wires.?.append(tag.wire);
                    if (tag.wire == gremlin.ProtoWireType.bytes) {
                        const length_result = try buf.readVarInt(offset);
                        offset += length_result.size + @as(usize, @intCast(length_result.value));
                    } else {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                    }
                },
                FileDescriptorProtoWire.WEAK_DEPENDENCY_WIRE => {
                    if (res._weak_dependency_offsets == null) {
                        res._weak_dependency_offsets = std.ArrayList(usize).init(allocator);
                        res._weak_dependency_wires = std.ArrayList(gremlin.ProtoWireType).init(allocator);
                    }
                    try res._weak_dependency_offsets.?.append(offset);
                    try res._weak_dependency_wires.?.append(tag.wire);
                    if (tag.wire == gremlin.ProtoWireType.bytes) {
                        const length_result = try buf.readVarInt(offset);
                        offset += length_result.size + @as(usize, @intCast(length_result.value));
                    } else {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                    }
                },
                FileDescriptorProtoWire.MESSAGE_TYPE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._message_type_bufs == null) {
                        res._message_type_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._message_type_bufs.?.append(result.value);
                },
                FileDescriptorProtoWire.ENUM_TYPE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._enum_type_bufs == null) {
                        res._enum_type_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._enum_type_bufs.?.append(result.value);
                },
                FileDescriptorProtoWire.SERVICE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._service_bufs == null) {
                        res._service_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._service_bufs.?.append(result.value);
                },
                FileDescriptorProtoWire.EXTENSION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._extension_bufs == null) {
                        res._extension_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._extension_bufs.?.append(result.value);
                },
                FileDescriptorProtoWire.OPTIONS_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._options_buf = result.value;
                },
                FileDescriptorProtoWire.SOURCE_CODE_INFO_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._source_code_info_buf = result.value;
                },
                FileDescriptorProtoWire.SYNTAX_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._syntax = result.value;
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const FileDescriptorProtoReader) void {
        if (self._dependency) |arr| {
            arr.deinit();
        }
        if (self._public_dependency_offsets) |arr| {
            arr.deinit();
        }
        if (self._public_dependency_wires) |arr| {
            arr.deinit();
        }
        if (self._weak_dependency_offsets) |arr| {
            arr.deinit();
        }
        if (self._weak_dependency_wires) |arr| {
            arr.deinit();
        }
        if (self._message_type_bufs) |arr| {
            arr.deinit();
        }
        if (self._enum_type_bufs) |arr| {
            arr.deinit();
        }
        if (self._service_bufs) |arr| {
            arr.deinit();
        }
        if (self._extension_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getName(self: *const FileDescriptorProtoReader) []const u8 {
        return self._name orelse &[_]u8{};
    }
    pub inline fn getPackage(self: *const FileDescriptorProtoReader) []const u8 {
        return self._package orelse &[_]u8{};
    }
    pub fn getDependency(self: *const FileDescriptorProtoReader) []const []const u8 {
        if (self._dependency) |arr| {
            return arr.items;
        }
        return &[_][]u8{};
    }
    pub fn getPublicDependency(self: *const FileDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]i32 {
        if (self._public_dependency_offsets) |offsets| {
            if (offsets.items.len == 0) return &[_]i32{};

            var result = std.ArrayList(i32).init(allocator);
            errdefer result.deinit();

            for (offsets.items, self._public_dependency_wires.?.items) |start_offset, wire_type| {
                if (wire_type == .bytes) {
                    const length_result = try self.buf.readVarInt(start_offset);
                    var offset = start_offset + length_result.size;
                    const end_offset = offset + @as(usize, @intCast(length_result.value));

                    while (offset < end_offset) {
                        const value_result = try self.buf.readInt32(offset);
                        try result.append(value_result.value);
                        offset += value_result.size;
                    }
                } else {
                    const value_result = try self.buf.readInt32(start_offset);
                    try result.append(value_result.value);
                }
            }
            return result.toOwnedSlice();
        }
        return &[_]i32{};
    }
    pub fn getWeakDependency(self: *const FileDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]i32 {
        if (self._weak_dependency_offsets) |offsets| {
            if (offsets.items.len == 0) return &[_]i32{};

            var result = std.ArrayList(i32).init(allocator);
            errdefer result.deinit();

            for (offsets.items, self._weak_dependency_wires.?.items) |start_offset, wire_type| {
                if (wire_type == .bytes) {
                    const length_result = try self.buf.readVarInt(start_offset);
                    var offset = start_offset + length_result.size;
                    const end_offset = offset + @as(usize, @intCast(length_result.value));

                    while (offset < end_offset) {
                        const value_result = try self.buf.readInt32(offset);
                        try result.append(value_result.value);
                        offset += value_result.size;
                    }
                } else {
                    const value_result = try self.buf.readInt32(start_offset);
                    try result.append(value_result.value);
                }
            }
            return result.toOwnedSlice();
        }
        return &[_]i32{};
    }
    pub fn getMessageType(self: *const FileDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]DescriptorProtoReader {
        if (self._message_type_bufs) |bufs| {
            var result = try std.ArrayList(DescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try DescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]DescriptorProtoReader{};
    }
    pub fn getEnumType(self: *const FileDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]EnumDescriptorProtoReader {
        if (self._enum_type_bufs) |bufs| {
            var result = try std.ArrayList(EnumDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try EnumDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]EnumDescriptorProtoReader{};
    }
    pub fn getService(self: *const FileDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]ServiceDescriptorProtoReader {
        if (self._service_bufs) |bufs| {
            var result = try std.ArrayList(ServiceDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try ServiceDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]ServiceDescriptorProtoReader{};
    }
    pub fn getExtension(self: *const FileDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]FieldDescriptorProtoReader {
        if (self._extension_bufs) |bufs| {
            var result = try std.ArrayList(FieldDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try FieldDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]FieldDescriptorProtoReader{};
    }
    pub fn getOptions(self: *const FileDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error!FileOptionsReader {
        if (self._options_buf) |buf| {
            return try FileOptionsReader.init(allocator, buf);
        }
        return try FileOptionsReader.init(allocator, &[_]u8{});
    }
    pub fn getSourceCodeInfo(self: *const FileDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error!SourceCodeInfoReader {
        if (self._source_code_info_buf) |buf| {
            return try SourceCodeInfoReader.init(allocator, buf);
        }
        return try SourceCodeInfoReader.init(allocator, &[_]u8{});
    }
    pub inline fn getSyntax(self: *const FileDescriptorProtoReader) []const u8 {
        return self._syntax orelse &[_]u8{};
    }
};

const DescriptorProtoWire = struct {
    const NAME_WIRE: gremlin.ProtoWireNumber = 1;
    const FIELD_WIRE: gremlin.ProtoWireNumber = 2;
    const EXTENSION_WIRE: gremlin.ProtoWireNumber = 6;
    const NESTED_TYPE_WIRE: gremlin.ProtoWireNumber = 3;
    const ENUM_TYPE_WIRE: gremlin.ProtoWireNumber = 4;
    const EXTENSION_RANGE_WIRE: gremlin.ProtoWireNumber = 5;
    const ONEOF_DECL_WIRE: gremlin.ProtoWireNumber = 8;
    const OPTIONS_WIRE: gremlin.ProtoWireNumber = 7;
    const RESERVED_RANGE_WIRE: gremlin.ProtoWireNumber = 9;
    const RESERVED_NAME_WIRE: gremlin.ProtoWireNumber = 10;
};

pub const DescriptorProto = struct {
    // nested structs
    const ExtensionRangeWire = struct {
        const START_WIRE: gremlin.ProtoWireNumber = 1;
        const END_WIRE: gremlin.ProtoWireNumber = 2;
        const OPTIONS_WIRE: gremlin.ProtoWireNumber = 3;
    };

    pub const ExtensionRange = struct {
        // fields
        start: i32 = 0,
        end: i32 = 0,
        options: ?ExtensionRangeOptions = null,

        pub fn calcProtobufSize(self: *const ExtensionRange) usize {
            var res: usize = 0;
            if (self.start != 0) {
                res += gremlin.sizes.sizeWireNumber(DescriptorProto.ExtensionRangeWire.START_WIRE) + gremlin.sizes.sizeI32(self.start);
            }
            if (self.end != 0) {
                res += gremlin.sizes.sizeWireNumber(DescriptorProto.ExtensionRangeWire.END_WIRE) + gremlin.sizes.sizeI32(self.end);
            }
            if (self.options) |v| {
                const size = v.calcProtobufSize();
                if (size > 0) {
                    res += gremlin.sizes.sizeWireNumber(DescriptorProto.ExtensionRangeWire.OPTIONS_WIRE) + gremlin.sizes.sizeUsize(size) + size;
                }
            }
            return res;
        }

        pub fn encode(self: *const ExtensionRange, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
            const size = self.calcProtobufSize();
            if (size == 0) {
                return &[_]u8{};
            }
            const buf = try allocator.alloc(u8, self.calcProtobufSize());
            var writer = gremlin.Writer.init(buf);
            self.encodeTo(&writer);
            return buf;
        }

        pub fn encodeTo(self: *const ExtensionRange, target: *gremlin.Writer) void {
            if (self.start != 0) {
                target.appendInt32(DescriptorProto.ExtensionRangeWire.START_WIRE, self.start);
            }
            if (self.end != 0) {
                target.appendInt32(DescriptorProto.ExtensionRangeWire.END_WIRE, self.end);
            }
            if (self.options) |v| {
                const size = v.calcProtobufSize();
                if (size > 0) {
                    target.appendBytesTag(DescriptorProto.ExtensionRangeWire.OPTIONS_WIRE, size);
                    v.encodeTo(target);
                }
            }
        }
    };

    pub const ExtensionRangeReader = struct {
        _start: i32 = 0,
        _end: i32 = 0,
        _options_buf: ?[]const u8 = null,

        pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!ExtensionRangeReader {
            var buf = gremlin.Reader.init(src);
            var res = ExtensionRangeReader{};
            if (buf.buf.len == 0) {
                return res;
            }
            var offset: usize = 0;
            while (buf.hasNext(offset, 0)) {
                const tag = try buf.readTagAt(offset);
                offset += tag.size;
                switch (tag.number) {
                    DescriptorProto.ExtensionRangeWire.START_WIRE => {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                        res._start = result.value;
                    },
                    DescriptorProto.ExtensionRangeWire.END_WIRE => {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                        res._end = result.value;
                    },
                    DescriptorProto.ExtensionRangeWire.OPTIONS_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        res._options_buf = result.value;
                    },
                    else => {
                        offset = try buf.skipData(offset, tag.wire);
                    },
                }
            }
            return res;
        }
        pub fn deinit(_: *const ExtensionRangeReader) void {}

        pub inline fn getStart(self: *const ExtensionRangeReader) i32 {
            return self._start;
        }
        pub inline fn getEnd(self: *const ExtensionRangeReader) i32 {
            return self._end;
        }
        pub fn getOptions(self: *const ExtensionRangeReader, allocator: std.mem.Allocator) gremlin.Error!ExtensionRangeOptionsReader {
            if (self._options_buf) |buf| {
                return try ExtensionRangeOptionsReader.init(allocator, buf);
            }
            return try ExtensionRangeOptionsReader.init(allocator, &[_]u8{});
        }
    };

    const ReservedRangeWire = struct {
        const START_WIRE: gremlin.ProtoWireNumber = 1;
        const END_WIRE: gremlin.ProtoWireNumber = 2;
    };

    pub const ReservedRange = struct {
        // fields
        start: i32 = 0,
        end: i32 = 0,

        pub fn calcProtobufSize(self: *const ReservedRange) usize {
            var res: usize = 0;
            if (self.start != 0) {
                res += gremlin.sizes.sizeWireNumber(DescriptorProto.ReservedRangeWire.START_WIRE) + gremlin.sizes.sizeI32(self.start);
            }
            if (self.end != 0) {
                res += gremlin.sizes.sizeWireNumber(DescriptorProto.ReservedRangeWire.END_WIRE) + gremlin.sizes.sizeI32(self.end);
            }
            return res;
        }

        pub fn encode(self: *const ReservedRange, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
            const size = self.calcProtobufSize();
            if (size == 0) {
                return &[_]u8{};
            }
            const buf = try allocator.alloc(u8, self.calcProtobufSize());
            var writer = gremlin.Writer.init(buf);
            self.encodeTo(&writer);
            return buf;
        }

        pub fn encodeTo(self: *const ReservedRange, target: *gremlin.Writer) void {
            if (self.start != 0) {
                target.appendInt32(DescriptorProto.ReservedRangeWire.START_WIRE, self.start);
            }
            if (self.end != 0) {
                target.appendInt32(DescriptorProto.ReservedRangeWire.END_WIRE, self.end);
            }
        }
    };

    pub const ReservedRangeReader = struct {
        _start: i32 = 0,
        _end: i32 = 0,

        pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!ReservedRangeReader {
            var buf = gremlin.Reader.init(src);
            var res = ReservedRangeReader{};
            if (buf.buf.len == 0) {
                return res;
            }
            var offset: usize = 0;
            while (buf.hasNext(offset, 0)) {
                const tag = try buf.readTagAt(offset);
                offset += tag.size;
                switch (tag.number) {
                    DescriptorProto.ReservedRangeWire.START_WIRE => {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                        res._start = result.value;
                    },
                    DescriptorProto.ReservedRangeWire.END_WIRE => {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                        res._end = result.value;
                    },
                    else => {
                        offset = try buf.skipData(offset, tag.wire);
                    },
                }
            }
            return res;
        }
        pub fn deinit(_: *const ReservedRangeReader) void {}

        pub inline fn getStart(self: *const ReservedRangeReader) i32 {
            return self._start;
        }
        pub inline fn getEnd(self: *const ReservedRangeReader) i32 {
            return self._end;
        }
    };

    // fields
    name: ?[]const u8 = null,
    field: ?[]const ?FieldDescriptorProto = null,
    extension: ?[]const ?FieldDescriptorProto = null,
    nested_type: ?[]const ?DescriptorProto = null,
    enum_type: ?[]const ?EnumDescriptorProto = null,
    extension_range: ?[]const ?DescriptorProto.ExtensionRange = null,
    oneof_decl: ?[]const ?OneofDescriptorProto = null,
    options: ?MessageOptions = null,
    reserved_range: ?[]const ?DescriptorProto.ReservedRange = null,
    reserved_name: ?[]const ?[]const u8 = null,

    pub fn calcProtobufSize(self: *const DescriptorProto) usize {
        var res: usize = 0;
        if (self.name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.field) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.FIELD_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.extension) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.EXTENSION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.nested_type) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.NESTED_TYPE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.enum_type) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.ENUM_TYPE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.extension_range) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.EXTENSION_RANGE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.oneof_decl) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.ONEOF_DECL_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.OPTIONS_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        if (self.reserved_range) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.RESERVED_RANGE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.reserved_name) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(DescriptorProtoWire.RESERVED_NAME_WIRE);
                if (maybe_v) |v| {
                    res += gremlin.sizes.sizeUsize(v.len) + v.len;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const DescriptorProto, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const DescriptorProto, target: *gremlin.Writer) void {
        if (self.name) |v| {
            if (v.len > 0) {
                target.appendBytes(DescriptorProtoWire.NAME_WIRE, v);
            }
        }
        if (self.field) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(DescriptorProtoWire.FIELD_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(DescriptorProtoWire.FIELD_WIRE, 0);
                }
            }
        }
        if (self.extension) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(DescriptorProtoWire.EXTENSION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(DescriptorProtoWire.EXTENSION_WIRE, 0);
                }
            }
        }
        if (self.nested_type) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(DescriptorProtoWire.NESTED_TYPE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(DescriptorProtoWire.NESTED_TYPE_WIRE, 0);
                }
            }
        }
        if (self.enum_type) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(DescriptorProtoWire.ENUM_TYPE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(DescriptorProtoWire.ENUM_TYPE_WIRE, 0);
                }
            }
        }
        if (self.extension_range) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(DescriptorProtoWire.EXTENSION_RANGE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(DescriptorProtoWire.EXTENSION_RANGE_WIRE, 0);
                }
            }
        }
        if (self.oneof_decl) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(DescriptorProtoWire.ONEOF_DECL_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(DescriptorProtoWire.ONEOF_DECL_WIRE, 0);
                }
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(DescriptorProtoWire.OPTIONS_WIRE, size);
                v.encodeTo(target);
            }
        }
        if (self.reserved_range) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(DescriptorProtoWire.RESERVED_RANGE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(DescriptorProtoWire.RESERVED_RANGE_WIRE, 0);
                }
            }
        }
        if (self.reserved_name) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    target.appendBytes(DescriptorProtoWire.RESERVED_NAME_WIRE, v);
                } else {
                    target.appendBytesTag(DescriptorProtoWire.RESERVED_NAME_WIRE, 0);
                }
            }
        }
    }
};

pub const DescriptorProtoReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _name: ?[]const u8 = null,
    _field_bufs: ?std.ArrayList([]const u8) = null,
    _extension_bufs: ?std.ArrayList([]const u8) = null,
    _nested_type_bufs: ?std.ArrayList([]const u8) = null,
    _enum_type_bufs: ?std.ArrayList([]const u8) = null,
    _extension_range_bufs: ?std.ArrayList([]const u8) = null,
    _oneof_decl_bufs: ?std.ArrayList([]const u8) = null,
    _options_buf: ?[]const u8 = null,
    _reserved_range_bufs: ?std.ArrayList([]const u8) = null,
    _reserved_name: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!DescriptorProtoReader {
        var buf = gremlin.Reader.init(src);
        var res = DescriptorProtoReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                DescriptorProtoWire.NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._name = result.value;
                },
                DescriptorProtoWire.FIELD_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._field_bufs == null) {
                        res._field_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._field_bufs.?.append(result.value);
                },
                DescriptorProtoWire.EXTENSION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._extension_bufs == null) {
                        res._extension_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._extension_bufs.?.append(result.value);
                },
                DescriptorProtoWire.NESTED_TYPE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._nested_type_bufs == null) {
                        res._nested_type_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._nested_type_bufs.?.append(result.value);
                },
                DescriptorProtoWire.ENUM_TYPE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._enum_type_bufs == null) {
                        res._enum_type_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._enum_type_bufs.?.append(result.value);
                },
                DescriptorProtoWire.EXTENSION_RANGE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._extension_range_bufs == null) {
                        res._extension_range_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._extension_range_bufs.?.append(result.value);
                },
                DescriptorProtoWire.ONEOF_DECL_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._oneof_decl_bufs == null) {
                        res._oneof_decl_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._oneof_decl_bufs.?.append(result.value);
                },
                DescriptorProtoWire.OPTIONS_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._options_buf = result.value;
                },
                DescriptorProtoWire.RESERVED_RANGE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._reserved_range_bufs == null) {
                        res._reserved_range_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._reserved_range_bufs.?.append(result.value);
                },
                DescriptorProtoWire.RESERVED_NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._reserved_name == null) {
                        res._reserved_name = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._reserved_name.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const DescriptorProtoReader) void {
        if (self._field_bufs) |arr| {
            arr.deinit();
        }
        if (self._extension_bufs) |arr| {
            arr.deinit();
        }
        if (self._nested_type_bufs) |arr| {
            arr.deinit();
        }
        if (self._enum_type_bufs) |arr| {
            arr.deinit();
        }
        if (self._extension_range_bufs) |arr| {
            arr.deinit();
        }
        if (self._oneof_decl_bufs) |arr| {
            arr.deinit();
        }
        if (self._reserved_range_bufs) |arr| {
            arr.deinit();
        }
        if (self._reserved_name) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getName(self: *const DescriptorProtoReader) []const u8 {
        return self._name orelse &[_]u8{};
    }
    pub fn getField(self: *const DescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]FieldDescriptorProtoReader {
        if (self._field_bufs) |bufs| {
            var result = try std.ArrayList(FieldDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try FieldDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]FieldDescriptorProtoReader{};
    }
    pub fn getExtension(self: *const DescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]FieldDescriptorProtoReader {
        if (self._extension_bufs) |bufs| {
            var result = try std.ArrayList(FieldDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try FieldDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]FieldDescriptorProtoReader{};
    }
    pub fn getNestedType(self: *const DescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]DescriptorProtoReader {
        if (self._nested_type_bufs) |bufs| {
            var result = try std.ArrayList(DescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try DescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]DescriptorProtoReader{};
    }
    pub fn getEnumType(self: *const DescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]EnumDescriptorProtoReader {
        if (self._enum_type_bufs) |bufs| {
            var result = try std.ArrayList(EnumDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try EnumDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]EnumDescriptorProtoReader{};
    }
    pub fn getExtensionRange(self: *const DescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]DescriptorProto.ExtensionRangeReader {
        if (self._extension_range_bufs) |bufs| {
            var result = try std.ArrayList(DescriptorProto.ExtensionRangeReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try DescriptorProto.ExtensionRangeReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]DescriptorProto.ExtensionRangeReader{};
    }
    pub fn getOneofDecl(self: *const DescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]OneofDescriptorProtoReader {
        if (self._oneof_decl_bufs) |bufs| {
            var result = try std.ArrayList(OneofDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try OneofDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]OneofDescriptorProtoReader{};
    }
    pub fn getOptions(self: *const DescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error!MessageOptionsReader {
        if (self._options_buf) |buf| {
            return try MessageOptionsReader.init(allocator, buf);
        }
        return try MessageOptionsReader.init(allocator, &[_]u8{});
    }
    pub fn getReservedRange(self: *const DescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]DescriptorProto.ReservedRangeReader {
        if (self._reserved_range_bufs) |bufs| {
            var result = try std.ArrayList(DescriptorProto.ReservedRangeReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try DescriptorProto.ReservedRangeReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]DescriptorProto.ReservedRangeReader{};
    }
    pub fn getReservedName(self: *const DescriptorProtoReader) []const []const u8 {
        if (self._reserved_name) |arr| {
            return arr.items;
        }
        return &[_][]u8{};
    }
};

const ExtensionRangeOptionsWire = struct {
    const UNINTERPRETED_OPTION_WIRE: gremlin.ProtoWireNumber = 999;
};

pub const ExtensionRangeOptions = struct {
    // fields
    uninterpreted_option: ?[]const ?UninterpretedOption = null,

    pub fn calcProtobufSize(self: *const ExtensionRangeOptions) usize {
        var res: usize = 0;
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(ExtensionRangeOptionsWire.UNINTERPRETED_OPTION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const ExtensionRangeOptions, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const ExtensionRangeOptions, target: *gremlin.Writer) void {
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(ExtensionRangeOptionsWire.UNINTERPRETED_OPTION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(ExtensionRangeOptionsWire.UNINTERPRETED_OPTION_WIRE, 0);
                }
            }
        }
    }
};

pub const ExtensionRangeOptionsReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _uninterpreted_option_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!ExtensionRangeOptionsReader {
        var buf = gremlin.Reader.init(src);
        var res = ExtensionRangeOptionsReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                ExtensionRangeOptionsWire.UNINTERPRETED_OPTION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._uninterpreted_option_bufs == null) {
                        res._uninterpreted_option_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._uninterpreted_option_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const ExtensionRangeOptionsReader) void {
        if (self._uninterpreted_option_bufs) |arr| {
            arr.deinit();
        }
    }
    pub fn getUninterpretedOption(self: *const ExtensionRangeOptionsReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOptionReader {
        if (self._uninterpreted_option_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOptionReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOptionReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOptionReader{};
    }
};

const FieldDescriptorProtoWire = struct {
    const NAME_WIRE: gremlin.ProtoWireNumber = 1;
    const NUMBER_WIRE: gremlin.ProtoWireNumber = 3;
    const LABEL_WIRE: gremlin.ProtoWireNumber = 4;
    const TYPE_WIRE: gremlin.ProtoWireNumber = 5;
    const TYPE_NAME_WIRE: gremlin.ProtoWireNumber = 6;
    const EXTENDEE_WIRE: gremlin.ProtoWireNumber = 2;
    const DEFAULT_VALUE_WIRE: gremlin.ProtoWireNumber = 7;
    const ONEOF_INDEX_WIRE: gremlin.ProtoWireNumber = 9;
    const JSON_NAME_WIRE: gremlin.ProtoWireNumber = 10;
    const OPTIONS_WIRE: gremlin.ProtoWireNumber = 8;
    const PROTO3_OPTIONAL_WIRE: gremlin.ProtoWireNumber = 17;
};

pub const FieldDescriptorProto = struct {
    // nested enums
    pub const Type = enum(i32) {
        TYPE_DOUBLE = 1,
        TYPE_FLOAT = 2,
        TYPE_INT64 = 3,
        TYPE_UINT64 = 4,
        TYPE_INT32 = 5,
        TYPE_FIXED64 = 6,
        TYPE_FIXED32 = 7,
        TYPE_BOOL = 8,
        TYPE_STRING = 9,
        TYPE_GROUP = 10,
        TYPE_MESSAGE = 11,
        TYPE_BYTES = 12,
        TYPE_UINT32 = 13,
        TYPE_ENUM = 14,
        TYPE_SFIXED32 = 15,
        TYPE_SFIXED64 = 16,
        TYPE_SINT32 = 17,
        TYPE_SINT64 = 18,
        _PROTOBUF_UNKNOWN = 0,
    };

    pub const Label = enum(i32) {
        LABEL_OPTIONAL = 1,
        LABEL_REQUIRED = 2,
        LABEL_REPEATED = 3,
        _PROTOBUF_UNKNOWN = 0,
    };

    // fields
    name: ?[]const u8 = null,
    number: i32 = 0,
    label: FieldDescriptorProto.Label = @enumFromInt(0),
    type: FieldDescriptorProto.Type = @enumFromInt(0),
    type_name: ?[]const u8 = null,
    extendee: ?[]const u8 = null,
    default_value: ?[]const u8 = null,
    oneof_index: i32 = 0,
    json_name: ?[]const u8 = null,
    options: ?FieldOptions = null,
    proto3_optional: bool = false,

    pub fn calcProtobufSize(self: *const FieldDescriptorProto) usize {
        var res: usize = 0;
        if (self.name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.number != 0) {
            res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.NUMBER_WIRE) + gremlin.sizes.sizeI32(self.number);
        }
        if (@intFromEnum(self.label) != 0) {
            res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.LABEL_WIRE) + gremlin.sizes.sizeI32(@intFromEnum(self.label));
        }
        if (@intFromEnum(self.type) != 0) {
            res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.TYPE_WIRE) + gremlin.sizes.sizeI32(@intFromEnum(self.type));
        }
        if (self.type_name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.TYPE_NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.extendee) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.EXTENDEE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.default_value) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.DEFAULT_VALUE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.oneof_index != 0) {
            res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.ONEOF_INDEX_WIRE) + gremlin.sizes.sizeI32(self.oneof_index);
        }
        if (self.json_name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.JSON_NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.OPTIONS_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        if (self.proto3_optional != false) {
            res += gremlin.sizes.sizeWireNumber(FieldDescriptorProtoWire.PROTO3_OPTIONAL_WIRE) + gremlin.sizes.sizeBool(self.proto3_optional);
        }
        return res;
    }

    pub fn encode(self: *const FieldDescriptorProto, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const FieldDescriptorProto, target: *gremlin.Writer) void {
        if (self.name) |v| {
            if (v.len > 0) {
                target.appendBytes(FieldDescriptorProtoWire.NAME_WIRE, v);
            }
        }
        if (self.number != 0) {
            target.appendInt32(FieldDescriptorProtoWire.NUMBER_WIRE, self.number);
        }
        if (@intFromEnum(self.label) != 0) {
            target.appendInt32(FieldDescriptorProtoWire.LABEL_WIRE, @intFromEnum(self.label));
        }
        if (@intFromEnum(self.type) != 0) {
            target.appendInt32(FieldDescriptorProtoWire.TYPE_WIRE, @intFromEnum(self.type));
        }
        if (self.type_name) |v| {
            if (v.len > 0) {
                target.appendBytes(FieldDescriptorProtoWire.TYPE_NAME_WIRE, v);
            }
        }
        if (self.extendee) |v| {
            if (v.len > 0) {
                target.appendBytes(FieldDescriptorProtoWire.EXTENDEE_WIRE, v);
            }
        }
        if (self.default_value) |v| {
            if (v.len > 0) {
                target.appendBytes(FieldDescriptorProtoWire.DEFAULT_VALUE_WIRE, v);
            }
        }
        if (self.oneof_index != 0) {
            target.appendInt32(FieldDescriptorProtoWire.ONEOF_INDEX_WIRE, self.oneof_index);
        }
        if (self.json_name) |v| {
            if (v.len > 0) {
                target.appendBytes(FieldDescriptorProtoWire.JSON_NAME_WIRE, v);
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(FieldDescriptorProtoWire.OPTIONS_WIRE, size);
                v.encodeTo(target);
            }
        }
        if (self.proto3_optional != false) {
            target.appendBool(FieldDescriptorProtoWire.PROTO3_OPTIONAL_WIRE, self.proto3_optional);
        }
    }
};

pub const FieldDescriptorProtoReader = struct {
    _name: ?[]const u8 = null,
    _number: i32 = 0,
    _label: FieldDescriptorProto.Label = @enumFromInt(0),
    _type: FieldDescriptorProto.Type = @enumFromInt(0),
    _type_name: ?[]const u8 = null,
    _extendee: ?[]const u8 = null,
    _default_value: ?[]const u8 = null,
    _oneof_index: i32 = 0,
    _json_name: ?[]const u8 = null,
    _options_buf: ?[]const u8 = null,
    _proto3_optional: bool = false,

    pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!FieldDescriptorProtoReader {
        var buf = gremlin.Reader.init(src);
        var res = FieldDescriptorProtoReader{};
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                FieldDescriptorProtoWire.NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._name = result.value;
                },
                FieldDescriptorProtoWire.NUMBER_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._number = result.value;
                },
                FieldDescriptorProtoWire.LABEL_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._label = @enumFromInt(result.value);
                },
                FieldDescriptorProtoWire.TYPE_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._type = @enumFromInt(result.value);
                },
                FieldDescriptorProtoWire.TYPE_NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._type_name = result.value;
                },
                FieldDescriptorProtoWire.EXTENDEE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._extendee = result.value;
                },
                FieldDescriptorProtoWire.DEFAULT_VALUE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._default_value = result.value;
                },
                FieldDescriptorProtoWire.ONEOF_INDEX_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._oneof_index = result.value;
                },
                FieldDescriptorProtoWire.JSON_NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._json_name = result.value;
                },
                FieldDescriptorProtoWire.OPTIONS_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._options_buf = result.value;
                },
                FieldDescriptorProtoWire.PROTO3_OPTIONAL_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._proto3_optional = result.value;
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(_: *const FieldDescriptorProtoReader) void {}

    pub inline fn getName(self: *const FieldDescriptorProtoReader) []const u8 {
        return self._name orelse &[_]u8{};
    }
    pub inline fn getNumber(self: *const FieldDescriptorProtoReader) i32 {
        return self._number;
    }
    pub inline fn getLabel(self: *const FieldDescriptorProtoReader) FieldDescriptorProto.Label {
        return self._label;
    }
    pub inline fn getType(self: *const FieldDescriptorProtoReader) FieldDescriptorProto.Type {
        return self._type;
    }
    pub inline fn getTypeName(self: *const FieldDescriptorProtoReader) []const u8 {
        return self._type_name orelse &[_]u8{};
    }
    pub inline fn getExtendee(self: *const FieldDescriptorProtoReader) []const u8 {
        return self._extendee orelse &[_]u8{};
    }
    pub inline fn getDefaultValue(self: *const FieldDescriptorProtoReader) []const u8 {
        return self._default_value orelse &[_]u8{};
    }
    pub inline fn getOneofIndex(self: *const FieldDescriptorProtoReader) i32 {
        return self._oneof_index;
    }
    pub inline fn getJsonName(self: *const FieldDescriptorProtoReader) []const u8 {
        return self._json_name orelse &[_]u8{};
    }
    pub fn getOptions(self: *const FieldDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error!FieldOptionsReader {
        if (self._options_buf) |buf| {
            return try FieldOptionsReader.init(allocator, buf);
        }
        return try FieldOptionsReader.init(allocator, &[_]u8{});
    }
    pub inline fn getProto3Optional(self: *const FieldDescriptorProtoReader) bool {
        return self._proto3_optional;
    }
};

const OneofDescriptorProtoWire = struct {
    const NAME_WIRE: gremlin.ProtoWireNumber = 1;
    const OPTIONS_WIRE: gremlin.ProtoWireNumber = 2;
};

pub const OneofDescriptorProto = struct {
    // fields
    name: ?[]const u8 = null,
    options: ?OneofOptions = null,

    pub fn calcProtobufSize(self: *const OneofDescriptorProto) usize {
        var res: usize = 0;
        if (self.name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(OneofDescriptorProtoWire.NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(OneofDescriptorProtoWire.OPTIONS_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        return res;
    }

    pub fn encode(self: *const OneofDescriptorProto, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const OneofDescriptorProto, target: *gremlin.Writer) void {
        if (self.name) |v| {
            if (v.len > 0) {
                target.appendBytes(OneofDescriptorProtoWire.NAME_WIRE, v);
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(OneofDescriptorProtoWire.OPTIONS_WIRE, size);
                v.encodeTo(target);
            }
        }
    }
};

pub const OneofDescriptorProtoReader = struct {
    _name: ?[]const u8 = null,
    _options_buf: ?[]const u8 = null,

    pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!OneofDescriptorProtoReader {
        var buf = gremlin.Reader.init(src);
        var res = OneofDescriptorProtoReader{};
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                OneofDescriptorProtoWire.NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._name = result.value;
                },
                OneofDescriptorProtoWire.OPTIONS_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._options_buf = result.value;
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(_: *const OneofDescriptorProtoReader) void {}

    pub inline fn getName(self: *const OneofDescriptorProtoReader) []const u8 {
        return self._name orelse &[_]u8{};
    }
    pub fn getOptions(self: *const OneofDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error!OneofOptionsReader {
        if (self._options_buf) |buf| {
            return try OneofOptionsReader.init(allocator, buf);
        }
        return try OneofOptionsReader.init(allocator, &[_]u8{});
    }
};

const EnumDescriptorProtoWire = struct {
    const NAME_WIRE: gremlin.ProtoWireNumber = 1;
    const VALUE_WIRE: gremlin.ProtoWireNumber = 2;
    const OPTIONS_WIRE: gremlin.ProtoWireNumber = 3;
    const RESERVED_RANGE_WIRE: gremlin.ProtoWireNumber = 4;
    const RESERVED_NAME_WIRE: gremlin.ProtoWireNumber = 5;
};

pub const EnumDescriptorProto = struct {
    // nested structs
    const EnumReservedRangeWire = struct {
        const START_WIRE: gremlin.ProtoWireNumber = 1;
        const END_WIRE: gremlin.ProtoWireNumber = 2;
    };

    pub const EnumReservedRange = struct {
        // fields
        start: i32 = 0,
        end: i32 = 0,

        pub fn calcProtobufSize(self: *const EnumReservedRange) usize {
            var res: usize = 0;
            if (self.start != 0) {
                res += gremlin.sizes.sizeWireNumber(EnumDescriptorProto.EnumReservedRangeWire.START_WIRE) + gremlin.sizes.sizeI32(self.start);
            }
            if (self.end != 0) {
                res += gremlin.sizes.sizeWireNumber(EnumDescriptorProto.EnumReservedRangeWire.END_WIRE) + gremlin.sizes.sizeI32(self.end);
            }
            return res;
        }

        pub fn encode(self: *const EnumReservedRange, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
            const size = self.calcProtobufSize();
            if (size == 0) {
                return &[_]u8{};
            }
            const buf = try allocator.alloc(u8, self.calcProtobufSize());
            var writer = gremlin.Writer.init(buf);
            self.encodeTo(&writer);
            return buf;
        }

        pub fn encodeTo(self: *const EnumReservedRange, target: *gremlin.Writer) void {
            if (self.start != 0) {
                target.appendInt32(EnumDescriptorProto.EnumReservedRangeWire.START_WIRE, self.start);
            }
            if (self.end != 0) {
                target.appendInt32(EnumDescriptorProto.EnumReservedRangeWire.END_WIRE, self.end);
            }
        }
    };

    pub const EnumReservedRangeReader = struct {
        _start: i32 = 0,
        _end: i32 = 0,

        pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!EnumReservedRangeReader {
            var buf = gremlin.Reader.init(src);
            var res = EnumReservedRangeReader{};
            if (buf.buf.len == 0) {
                return res;
            }
            var offset: usize = 0;
            while (buf.hasNext(offset, 0)) {
                const tag = try buf.readTagAt(offset);
                offset += tag.size;
                switch (tag.number) {
                    EnumDescriptorProto.EnumReservedRangeWire.START_WIRE => {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                        res._start = result.value;
                    },
                    EnumDescriptorProto.EnumReservedRangeWire.END_WIRE => {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                        res._end = result.value;
                    },
                    else => {
                        offset = try buf.skipData(offset, tag.wire);
                    },
                }
            }
            return res;
        }
        pub fn deinit(_: *const EnumReservedRangeReader) void {}

        pub inline fn getStart(self: *const EnumReservedRangeReader) i32 {
            return self._start;
        }
        pub inline fn getEnd(self: *const EnumReservedRangeReader) i32 {
            return self._end;
        }
    };

    // fields
    name: ?[]const u8 = null,
    value: ?[]const ?EnumValueDescriptorProto = null,
    options: ?EnumOptions = null,
    reserved_range: ?[]const ?EnumDescriptorProto.EnumReservedRange = null,
    reserved_name: ?[]const ?[]const u8 = null,

    pub fn calcProtobufSize(self: *const EnumDescriptorProto) usize {
        var res: usize = 0;
        if (self.name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(EnumDescriptorProtoWire.NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.value) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(EnumDescriptorProtoWire.VALUE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(EnumDescriptorProtoWire.OPTIONS_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        if (self.reserved_range) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(EnumDescriptorProtoWire.RESERVED_RANGE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.reserved_name) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(EnumDescriptorProtoWire.RESERVED_NAME_WIRE);
                if (maybe_v) |v| {
                    res += gremlin.sizes.sizeUsize(v.len) + v.len;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const EnumDescriptorProto, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const EnumDescriptorProto, target: *gremlin.Writer) void {
        if (self.name) |v| {
            if (v.len > 0) {
                target.appendBytes(EnumDescriptorProtoWire.NAME_WIRE, v);
            }
        }
        if (self.value) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(EnumDescriptorProtoWire.VALUE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(EnumDescriptorProtoWire.VALUE_WIRE, 0);
                }
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(EnumDescriptorProtoWire.OPTIONS_WIRE, size);
                v.encodeTo(target);
            }
        }
        if (self.reserved_range) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(EnumDescriptorProtoWire.RESERVED_RANGE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(EnumDescriptorProtoWire.RESERVED_RANGE_WIRE, 0);
                }
            }
        }
        if (self.reserved_name) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    target.appendBytes(EnumDescriptorProtoWire.RESERVED_NAME_WIRE, v);
                } else {
                    target.appendBytesTag(EnumDescriptorProtoWire.RESERVED_NAME_WIRE, 0);
                }
            }
        }
    }
};

pub const EnumDescriptorProtoReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _name: ?[]const u8 = null,
    _value_bufs: ?std.ArrayList([]const u8) = null,
    _options_buf: ?[]const u8 = null,
    _reserved_range_bufs: ?std.ArrayList([]const u8) = null,
    _reserved_name: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!EnumDescriptorProtoReader {
        var buf = gremlin.Reader.init(src);
        var res = EnumDescriptorProtoReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                EnumDescriptorProtoWire.NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._name = result.value;
                },
                EnumDescriptorProtoWire.VALUE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._value_bufs == null) {
                        res._value_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._value_bufs.?.append(result.value);
                },
                EnumDescriptorProtoWire.OPTIONS_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._options_buf = result.value;
                },
                EnumDescriptorProtoWire.RESERVED_RANGE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._reserved_range_bufs == null) {
                        res._reserved_range_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._reserved_range_bufs.?.append(result.value);
                },
                EnumDescriptorProtoWire.RESERVED_NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._reserved_name == null) {
                        res._reserved_name = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._reserved_name.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const EnumDescriptorProtoReader) void {
        if (self._value_bufs) |arr| {
            arr.deinit();
        }
        if (self._reserved_range_bufs) |arr| {
            arr.deinit();
        }
        if (self._reserved_name) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getName(self: *const EnumDescriptorProtoReader) []const u8 {
        return self._name orelse &[_]u8{};
    }
    pub fn getValue(self: *const EnumDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]EnumValueDescriptorProtoReader {
        if (self._value_bufs) |bufs| {
            var result = try std.ArrayList(EnumValueDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try EnumValueDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]EnumValueDescriptorProtoReader{};
    }
    pub fn getOptions(self: *const EnumDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error!EnumOptionsReader {
        if (self._options_buf) |buf| {
            return try EnumOptionsReader.init(allocator, buf);
        }
        return try EnumOptionsReader.init(allocator, &[_]u8{});
    }
    pub fn getReservedRange(self: *const EnumDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]EnumDescriptorProto.EnumReservedRangeReader {
        if (self._reserved_range_bufs) |bufs| {
            var result = try std.ArrayList(EnumDescriptorProto.EnumReservedRangeReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try EnumDescriptorProto.EnumReservedRangeReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]EnumDescriptorProto.EnumReservedRangeReader{};
    }
    pub fn getReservedName(self: *const EnumDescriptorProtoReader) []const []const u8 {
        if (self._reserved_name) |arr| {
            return arr.items;
        }
        return &[_][]u8{};
    }
};

const EnumValueDescriptorProtoWire = struct {
    const NAME_WIRE: gremlin.ProtoWireNumber = 1;
    const NUMBER_WIRE: gremlin.ProtoWireNumber = 2;
    const OPTIONS_WIRE: gremlin.ProtoWireNumber = 3;
};

pub const EnumValueDescriptorProto = struct {
    // fields
    name: ?[]const u8 = null,
    number: i32 = 0,
    options: ?EnumValueOptions = null,

    pub fn calcProtobufSize(self: *const EnumValueDescriptorProto) usize {
        var res: usize = 0;
        if (self.name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(EnumValueDescriptorProtoWire.NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.number != 0) {
            res += gremlin.sizes.sizeWireNumber(EnumValueDescriptorProtoWire.NUMBER_WIRE) + gremlin.sizes.sizeI32(self.number);
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(EnumValueDescriptorProtoWire.OPTIONS_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        return res;
    }

    pub fn encode(self: *const EnumValueDescriptorProto, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const EnumValueDescriptorProto, target: *gremlin.Writer) void {
        if (self.name) |v| {
            if (v.len > 0) {
                target.appendBytes(EnumValueDescriptorProtoWire.NAME_WIRE, v);
            }
        }
        if (self.number != 0) {
            target.appendInt32(EnumValueDescriptorProtoWire.NUMBER_WIRE, self.number);
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(EnumValueDescriptorProtoWire.OPTIONS_WIRE, size);
                v.encodeTo(target);
            }
        }
    }
};

pub const EnumValueDescriptorProtoReader = struct {
    _name: ?[]const u8 = null,
    _number: i32 = 0,
    _options_buf: ?[]const u8 = null,

    pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!EnumValueDescriptorProtoReader {
        var buf = gremlin.Reader.init(src);
        var res = EnumValueDescriptorProtoReader{};
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                EnumValueDescriptorProtoWire.NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._name = result.value;
                },
                EnumValueDescriptorProtoWire.NUMBER_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._number = result.value;
                },
                EnumValueDescriptorProtoWire.OPTIONS_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._options_buf = result.value;
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(_: *const EnumValueDescriptorProtoReader) void {}

    pub inline fn getName(self: *const EnumValueDescriptorProtoReader) []const u8 {
        return self._name orelse &[_]u8{};
    }
    pub inline fn getNumber(self: *const EnumValueDescriptorProtoReader) i32 {
        return self._number;
    }
    pub fn getOptions(self: *const EnumValueDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error!EnumValueOptionsReader {
        if (self._options_buf) |buf| {
            return try EnumValueOptionsReader.init(allocator, buf);
        }
        return try EnumValueOptionsReader.init(allocator, &[_]u8{});
    }
};

const ServiceDescriptorProtoWire = struct {
    const NAME_WIRE: gremlin.ProtoWireNumber = 1;
    const METHOD_WIRE: gremlin.ProtoWireNumber = 2;
    const OPTIONS_WIRE: gremlin.ProtoWireNumber = 3;
};

pub const ServiceDescriptorProto = struct {
    // fields
    name: ?[]const u8 = null,
    method: ?[]const ?MethodDescriptorProto = null,
    options: ?ServiceOptions = null,

    pub fn calcProtobufSize(self: *const ServiceDescriptorProto) usize {
        var res: usize = 0;
        if (self.name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(ServiceDescriptorProtoWire.NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.method) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(ServiceDescriptorProtoWire.METHOD_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(ServiceDescriptorProtoWire.OPTIONS_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        return res;
    }

    pub fn encode(self: *const ServiceDescriptorProto, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const ServiceDescriptorProto, target: *gremlin.Writer) void {
        if (self.name) |v| {
            if (v.len > 0) {
                target.appendBytes(ServiceDescriptorProtoWire.NAME_WIRE, v);
            }
        }
        if (self.method) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(ServiceDescriptorProtoWire.METHOD_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(ServiceDescriptorProtoWire.METHOD_WIRE, 0);
                }
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(ServiceDescriptorProtoWire.OPTIONS_WIRE, size);
                v.encodeTo(target);
            }
        }
    }
};

pub const ServiceDescriptorProtoReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _name: ?[]const u8 = null,
    _method_bufs: ?std.ArrayList([]const u8) = null,
    _options_buf: ?[]const u8 = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!ServiceDescriptorProtoReader {
        var buf = gremlin.Reader.init(src);
        var res = ServiceDescriptorProtoReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                ServiceDescriptorProtoWire.NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._name = result.value;
                },
                ServiceDescriptorProtoWire.METHOD_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._method_bufs == null) {
                        res._method_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._method_bufs.?.append(result.value);
                },
                ServiceDescriptorProtoWire.OPTIONS_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._options_buf = result.value;
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const ServiceDescriptorProtoReader) void {
        if (self._method_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getName(self: *const ServiceDescriptorProtoReader) []const u8 {
        return self._name orelse &[_]u8{};
    }
    pub fn getMethod(self: *const ServiceDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error![]MethodDescriptorProtoReader {
        if (self._method_bufs) |bufs| {
            var result = try std.ArrayList(MethodDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try MethodDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]MethodDescriptorProtoReader{};
    }
    pub fn getOptions(self: *const ServiceDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error!ServiceOptionsReader {
        if (self._options_buf) |buf| {
            return try ServiceOptionsReader.init(allocator, buf);
        }
        return try ServiceOptionsReader.init(allocator, &[_]u8{});
    }
};

const MethodDescriptorProtoWire = struct {
    const NAME_WIRE: gremlin.ProtoWireNumber = 1;
    const INPUT_TYPE_WIRE: gremlin.ProtoWireNumber = 2;
    const OUTPUT_TYPE_WIRE: gremlin.ProtoWireNumber = 3;
    const OPTIONS_WIRE: gremlin.ProtoWireNumber = 4;
    const CLIENT_STREAMING_WIRE: gremlin.ProtoWireNumber = 5;
    const SERVER_STREAMING_WIRE: gremlin.ProtoWireNumber = 6;
};

pub const MethodDescriptorProto = struct {
    // fields
    name: ?[]const u8 = null,
    input_type: ?[]const u8 = null,
    output_type: ?[]const u8 = null,
    options: ?MethodOptions = null,
    client_streaming: bool = false,
    server_streaming: bool = false,

    pub fn calcProtobufSize(self: *const MethodDescriptorProto) usize {
        var res: usize = 0;
        if (self.name) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(MethodDescriptorProtoWire.NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.input_type) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(MethodDescriptorProtoWire.INPUT_TYPE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.output_type) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(MethodDescriptorProtoWire.OUTPUT_TYPE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(MethodDescriptorProtoWire.OPTIONS_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        if (self.client_streaming != false) {
            res += gremlin.sizes.sizeWireNumber(MethodDescriptorProtoWire.CLIENT_STREAMING_WIRE) + gremlin.sizes.sizeBool(self.client_streaming);
        }
        if (self.server_streaming != false) {
            res += gremlin.sizes.sizeWireNumber(MethodDescriptorProtoWire.SERVER_STREAMING_WIRE) + gremlin.sizes.sizeBool(self.server_streaming);
        }
        return res;
    }

    pub fn encode(self: *const MethodDescriptorProto, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const MethodDescriptorProto, target: *gremlin.Writer) void {
        if (self.name) |v| {
            if (v.len > 0) {
                target.appendBytes(MethodDescriptorProtoWire.NAME_WIRE, v);
            }
        }
        if (self.input_type) |v| {
            if (v.len > 0) {
                target.appendBytes(MethodDescriptorProtoWire.INPUT_TYPE_WIRE, v);
            }
        }
        if (self.output_type) |v| {
            if (v.len > 0) {
                target.appendBytes(MethodDescriptorProtoWire.OUTPUT_TYPE_WIRE, v);
            }
        }
        if (self.options) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(MethodDescriptorProtoWire.OPTIONS_WIRE, size);
                v.encodeTo(target);
            }
        }
        if (self.client_streaming != false) {
            target.appendBool(MethodDescriptorProtoWire.CLIENT_STREAMING_WIRE, self.client_streaming);
        }
        if (self.server_streaming != false) {
            target.appendBool(MethodDescriptorProtoWire.SERVER_STREAMING_WIRE, self.server_streaming);
        }
    }
};

pub const MethodDescriptorProtoReader = struct {
    _name: ?[]const u8 = null,
    _input_type: ?[]const u8 = null,
    _output_type: ?[]const u8 = null,
    _options_buf: ?[]const u8 = null,
    _client_streaming: bool = false,
    _server_streaming: bool = false,

    pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!MethodDescriptorProtoReader {
        var buf = gremlin.Reader.init(src);
        var res = MethodDescriptorProtoReader{};
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                MethodDescriptorProtoWire.NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._name = result.value;
                },
                MethodDescriptorProtoWire.INPUT_TYPE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._input_type = result.value;
                },
                MethodDescriptorProtoWire.OUTPUT_TYPE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._output_type = result.value;
                },
                MethodDescriptorProtoWire.OPTIONS_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._options_buf = result.value;
                },
                MethodDescriptorProtoWire.CLIENT_STREAMING_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._client_streaming = result.value;
                },
                MethodDescriptorProtoWire.SERVER_STREAMING_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._server_streaming = result.value;
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(_: *const MethodDescriptorProtoReader) void {}

    pub inline fn getName(self: *const MethodDescriptorProtoReader) []const u8 {
        return self._name orelse &[_]u8{};
    }
    pub inline fn getInputType(self: *const MethodDescriptorProtoReader) []const u8 {
        return self._input_type orelse &[_]u8{};
    }
    pub inline fn getOutputType(self: *const MethodDescriptorProtoReader) []const u8 {
        return self._output_type orelse &[_]u8{};
    }
    pub fn getOptions(self: *const MethodDescriptorProtoReader, allocator: std.mem.Allocator) gremlin.Error!MethodOptionsReader {
        if (self._options_buf) |buf| {
            return try MethodOptionsReader.init(allocator, buf);
        }
        return try MethodOptionsReader.init(allocator, &[_]u8{});
    }
    pub inline fn getClientStreaming(self: *const MethodDescriptorProtoReader) bool {
        return self._client_streaming;
    }
    pub inline fn getServerStreaming(self: *const MethodDescriptorProtoReader) bool {
        return self._server_streaming;
    }
};

const FileOptionsWire = struct {
    const JAVA_PACKAGE_WIRE: gremlin.ProtoWireNumber = 1;
    const JAVA_OUTER_CLASSNAME_WIRE: gremlin.ProtoWireNumber = 8;
    const JAVA_MULTIPLE_FILES_WIRE: gremlin.ProtoWireNumber = 10;
    const JAVA_GENERATE_EQUALS_AND_HASH_WIRE: gremlin.ProtoWireNumber = 20;
    const JAVA_STRING_CHECK_UTF8_WIRE: gremlin.ProtoWireNumber = 27;
    const OPTIMIZE_FOR_WIRE: gremlin.ProtoWireNumber = 9;
    const GO_PACKAGE_WIRE: gremlin.ProtoWireNumber = 11;
    const CC_GENERIC_SERVICES_WIRE: gremlin.ProtoWireNumber = 16;
    const JAVA_GENERIC_SERVICES_WIRE: gremlin.ProtoWireNumber = 17;
    const PY_GENERIC_SERVICES_WIRE: gremlin.ProtoWireNumber = 18;
    const PHP_GENERIC_SERVICES_WIRE: gremlin.ProtoWireNumber = 42;
    const DEPRECATED_WIRE: gremlin.ProtoWireNumber = 23;
    const CC_ENABLE_ARENAS_WIRE: gremlin.ProtoWireNumber = 31;
    const OBJC_CLASS_PREFIX_WIRE: gremlin.ProtoWireNumber = 36;
    const CSHARP_NAMESPACE_WIRE: gremlin.ProtoWireNumber = 37;
    const SWIFT_PREFIX_WIRE: gremlin.ProtoWireNumber = 39;
    const PHP_CLASS_PREFIX_WIRE: gremlin.ProtoWireNumber = 40;
    const PHP_NAMESPACE_WIRE: gremlin.ProtoWireNumber = 41;
    const PHP_METADATA_NAMESPACE_WIRE: gremlin.ProtoWireNumber = 44;
    const RUBY_PACKAGE_WIRE: gremlin.ProtoWireNumber = 45;
    const UNINTERPRETED_OPTION_WIRE: gremlin.ProtoWireNumber = 999;
};

pub const FileOptions = struct {
    // nested enums
    pub const OptimizeMode = enum(i32) {
        SPEED = 1,
        CODE_SIZE = 2,
        LITE_RUNTIME = 3,
        _PROTOBUF_UNKNOWN = 0,
    };

    // fields
    java_package: ?[]const u8 = null,
    java_outer_classname: ?[]const u8 = null,
    java_multiple_files: bool = false,
    java_generate_equals_and_hash: bool = false,
    java_string_check_utf8: bool = false,
    optimize_for: FileOptions.OptimizeMode = @enumFromInt(0),
    go_package: ?[]const u8 = null,
    cc_generic_services: bool = false,
    java_generic_services: bool = false,
    py_generic_services: bool = false,
    php_generic_services: bool = false,
    deprecated: bool = false,
    cc_enable_arenas: bool = false,
    objc_class_prefix: ?[]const u8 = null,
    csharp_namespace: ?[]const u8 = null,
    swift_prefix: ?[]const u8 = null,
    php_class_prefix: ?[]const u8 = null,
    php_namespace: ?[]const u8 = null,
    php_metadata_namespace: ?[]const u8 = null,
    ruby_package: ?[]const u8 = null,
    uninterpreted_option: ?[]const ?UninterpretedOption = null,

    pub fn calcProtobufSize(self: *const FileOptions) usize {
        var res: usize = 0;
        if (self.java_package) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.JAVA_PACKAGE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.java_outer_classname) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.JAVA_OUTER_CLASSNAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.java_multiple_files != false) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.JAVA_MULTIPLE_FILES_WIRE) + gremlin.sizes.sizeBool(self.java_multiple_files);
        }
        if (self.java_generate_equals_and_hash != false) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.JAVA_GENERATE_EQUALS_AND_HASH_WIRE) + gremlin.sizes.sizeBool(self.java_generate_equals_and_hash);
        }
        if (self.java_string_check_utf8 != false) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.JAVA_STRING_CHECK_UTF8_WIRE) + gremlin.sizes.sizeBool(self.java_string_check_utf8);
        }
        if (self.optimize_for != FileOptions.OptimizeMode.SPEED) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.OPTIMIZE_FOR_WIRE) + gremlin.sizes.sizeI32(@intFromEnum(self.optimize_for));
        }
        if (self.go_package) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.GO_PACKAGE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.cc_generic_services != false) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.CC_GENERIC_SERVICES_WIRE) + gremlin.sizes.sizeBool(self.cc_generic_services);
        }
        if (self.java_generic_services != false) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.JAVA_GENERIC_SERVICES_WIRE) + gremlin.sizes.sizeBool(self.java_generic_services);
        }
        if (self.py_generic_services != false) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.PY_GENERIC_SERVICES_WIRE) + gremlin.sizes.sizeBool(self.py_generic_services);
        }
        if (self.php_generic_services != false) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.PHP_GENERIC_SERVICES_WIRE) + gremlin.sizes.sizeBool(self.php_generic_services);
        }
        if (self.deprecated != false) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.DEPRECATED_WIRE) + gremlin.sizes.sizeBool(self.deprecated);
        }
        if (self.cc_enable_arenas != true) {
            res += gremlin.sizes.sizeWireNumber(FileOptionsWire.CC_ENABLE_ARENAS_WIRE) + gremlin.sizes.sizeBool(self.cc_enable_arenas);
        }
        if (self.objc_class_prefix) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.OBJC_CLASS_PREFIX_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.csharp_namespace) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.CSHARP_NAMESPACE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.swift_prefix) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.SWIFT_PREFIX_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.php_class_prefix) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.PHP_CLASS_PREFIX_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.php_namespace) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.PHP_NAMESPACE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.php_metadata_namespace) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.PHP_METADATA_NAMESPACE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.ruby_package) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.RUBY_PACKAGE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(FileOptionsWire.UNINTERPRETED_OPTION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const FileOptions, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const FileOptions, target: *gremlin.Writer) void {
        if (self.java_package) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.JAVA_PACKAGE_WIRE, v);
            }
        }
        if (self.java_outer_classname) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.JAVA_OUTER_CLASSNAME_WIRE, v);
            }
        }
        if (self.java_multiple_files != false) {
            target.appendBool(FileOptionsWire.JAVA_MULTIPLE_FILES_WIRE, self.java_multiple_files);
        }
        if (self.java_generate_equals_and_hash != false) {
            target.appendBool(FileOptionsWire.JAVA_GENERATE_EQUALS_AND_HASH_WIRE, self.java_generate_equals_and_hash);
        }
        if (self.java_string_check_utf8 != false) {
            target.appendBool(FileOptionsWire.JAVA_STRING_CHECK_UTF8_WIRE, self.java_string_check_utf8);
        }
        if (self.optimize_for != FileOptions.OptimizeMode.SPEED) {
            target.appendInt32(FileOptionsWire.OPTIMIZE_FOR_WIRE, @intFromEnum(self.optimize_for));
        }
        if (self.go_package) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.GO_PACKAGE_WIRE, v);
            }
        }
        if (self.cc_generic_services != false) {
            target.appendBool(FileOptionsWire.CC_GENERIC_SERVICES_WIRE, self.cc_generic_services);
        }
        if (self.java_generic_services != false) {
            target.appendBool(FileOptionsWire.JAVA_GENERIC_SERVICES_WIRE, self.java_generic_services);
        }
        if (self.py_generic_services != false) {
            target.appendBool(FileOptionsWire.PY_GENERIC_SERVICES_WIRE, self.py_generic_services);
        }
        if (self.php_generic_services != false) {
            target.appendBool(FileOptionsWire.PHP_GENERIC_SERVICES_WIRE, self.php_generic_services);
        }
        if (self.deprecated != false) {
            target.appendBool(FileOptionsWire.DEPRECATED_WIRE, self.deprecated);
        }
        if (self.cc_enable_arenas != true) {
            target.appendBool(FileOptionsWire.CC_ENABLE_ARENAS_WIRE, self.cc_enable_arenas);
        }
        if (self.objc_class_prefix) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.OBJC_CLASS_PREFIX_WIRE, v);
            }
        }
        if (self.csharp_namespace) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.CSHARP_NAMESPACE_WIRE, v);
            }
        }
        if (self.swift_prefix) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.SWIFT_PREFIX_WIRE, v);
            }
        }
        if (self.php_class_prefix) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.PHP_CLASS_PREFIX_WIRE, v);
            }
        }
        if (self.php_namespace) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.PHP_NAMESPACE_WIRE, v);
            }
        }
        if (self.php_metadata_namespace) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.PHP_METADATA_NAMESPACE_WIRE, v);
            }
        }
        if (self.ruby_package) |v| {
            if (v.len > 0) {
                target.appendBytes(FileOptionsWire.RUBY_PACKAGE_WIRE, v);
            }
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(FileOptionsWire.UNINTERPRETED_OPTION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(FileOptionsWire.UNINTERPRETED_OPTION_WIRE, 0);
                }
            }
        }
    }
};

pub const FileOptionsReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _java_package: ?[]const u8 = null,
    _java_outer_classname: ?[]const u8 = null,
    _java_multiple_files: bool = false,
    _java_generate_equals_and_hash: bool = false,
    _java_string_check_utf8: bool = false,
    _optimize_for: FileOptions.OptimizeMode = FileOptions.OptimizeMode.SPEED,
    _go_package: ?[]const u8 = null,
    _cc_generic_services: bool = false,
    _java_generic_services: bool = false,
    _py_generic_services: bool = false,
    _php_generic_services: bool = false,
    _deprecated: bool = false,
    _cc_enable_arenas: bool = true,
    _objc_class_prefix: ?[]const u8 = null,
    _csharp_namespace: ?[]const u8 = null,
    _swift_prefix: ?[]const u8 = null,
    _php_class_prefix: ?[]const u8 = null,
    _php_namespace: ?[]const u8 = null,
    _php_metadata_namespace: ?[]const u8 = null,
    _ruby_package: ?[]const u8 = null,
    _uninterpreted_option_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!FileOptionsReader {
        var buf = gremlin.Reader.init(src);
        var res = FileOptionsReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                FileOptionsWire.JAVA_PACKAGE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._java_package = result.value;
                },
                FileOptionsWire.JAVA_OUTER_CLASSNAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._java_outer_classname = result.value;
                },
                FileOptionsWire.JAVA_MULTIPLE_FILES_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._java_multiple_files = result.value;
                },
                FileOptionsWire.JAVA_GENERATE_EQUALS_AND_HASH_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._java_generate_equals_and_hash = result.value;
                },
                FileOptionsWire.JAVA_STRING_CHECK_UTF8_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._java_string_check_utf8 = result.value;
                },
                FileOptionsWire.OPTIMIZE_FOR_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._optimize_for = @enumFromInt(result.value);
                },
                FileOptionsWire.GO_PACKAGE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._go_package = result.value;
                },
                FileOptionsWire.CC_GENERIC_SERVICES_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._cc_generic_services = result.value;
                },
                FileOptionsWire.JAVA_GENERIC_SERVICES_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._java_generic_services = result.value;
                },
                FileOptionsWire.PY_GENERIC_SERVICES_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._py_generic_services = result.value;
                },
                FileOptionsWire.PHP_GENERIC_SERVICES_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._php_generic_services = result.value;
                },
                FileOptionsWire.DEPRECATED_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._deprecated = result.value;
                },
                FileOptionsWire.CC_ENABLE_ARENAS_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._cc_enable_arenas = result.value;
                },
                FileOptionsWire.OBJC_CLASS_PREFIX_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._objc_class_prefix = result.value;
                },
                FileOptionsWire.CSHARP_NAMESPACE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._csharp_namespace = result.value;
                },
                FileOptionsWire.SWIFT_PREFIX_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._swift_prefix = result.value;
                },
                FileOptionsWire.PHP_CLASS_PREFIX_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._php_class_prefix = result.value;
                },
                FileOptionsWire.PHP_NAMESPACE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._php_namespace = result.value;
                },
                FileOptionsWire.PHP_METADATA_NAMESPACE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._php_metadata_namespace = result.value;
                },
                FileOptionsWire.RUBY_PACKAGE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._ruby_package = result.value;
                },
                FileOptionsWire.UNINTERPRETED_OPTION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._uninterpreted_option_bufs == null) {
                        res._uninterpreted_option_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._uninterpreted_option_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const FileOptionsReader) void {
        if (self._uninterpreted_option_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getJavaPackage(self: *const FileOptionsReader) []const u8 {
        return self._java_package orelse &[_]u8{};
    }
    pub inline fn getJavaOuterClassname(self: *const FileOptionsReader) []const u8 {
        return self._java_outer_classname orelse &[_]u8{};
    }
    pub inline fn getJavaMultipleFiles(self: *const FileOptionsReader) bool {
        return self._java_multiple_files;
    }
    pub inline fn getJavaGenerateEqualsAndHash(self: *const FileOptionsReader) bool {
        return self._java_generate_equals_and_hash;
    }
    pub inline fn getJavaStringCheckUtf8(self: *const FileOptionsReader) bool {
        return self._java_string_check_utf8;
    }
    pub inline fn getOptimizeFor(self: *const FileOptionsReader) FileOptions.OptimizeMode {
        return self._optimize_for;
    }
    pub inline fn getGoPackage(self: *const FileOptionsReader) []const u8 {
        return self._go_package orelse &[_]u8{};
    }
    pub inline fn getCcGenericServices(self: *const FileOptionsReader) bool {
        return self._cc_generic_services;
    }
    pub inline fn getJavaGenericServices(self: *const FileOptionsReader) bool {
        return self._java_generic_services;
    }
    pub inline fn getPyGenericServices(self: *const FileOptionsReader) bool {
        return self._py_generic_services;
    }
    pub inline fn getPhpGenericServices(self: *const FileOptionsReader) bool {
        return self._php_generic_services;
    }
    pub inline fn getDeprecated(self: *const FileOptionsReader) bool {
        return self._deprecated;
    }
    pub inline fn getCcEnableArenas(self: *const FileOptionsReader) bool {
        return self._cc_enable_arenas;
    }
    pub inline fn getObjcClassPrefix(self: *const FileOptionsReader) []const u8 {
        return self._objc_class_prefix orelse &[_]u8{};
    }
    pub inline fn getCsharpNamespace(self: *const FileOptionsReader) []const u8 {
        return self._csharp_namespace orelse &[_]u8{};
    }
    pub inline fn getSwiftPrefix(self: *const FileOptionsReader) []const u8 {
        return self._swift_prefix orelse &[_]u8{};
    }
    pub inline fn getPhpClassPrefix(self: *const FileOptionsReader) []const u8 {
        return self._php_class_prefix orelse &[_]u8{};
    }
    pub inline fn getPhpNamespace(self: *const FileOptionsReader) []const u8 {
        return self._php_namespace orelse &[_]u8{};
    }
    pub inline fn getPhpMetadataNamespace(self: *const FileOptionsReader) []const u8 {
        return self._php_metadata_namespace orelse &[_]u8{};
    }
    pub inline fn getRubyPackage(self: *const FileOptionsReader) []const u8 {
        return self._ruby_package orelse &[_]u8{};
    }
    pub fn getUninterpretedOption(self: *const FileOptionsReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOptionReader {
        if (self._uninterpreted_option_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOptionReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOptionReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOptionReader{};
    }
};

const MessageOptionsWire = struct {
    const MESSAGE_SET_WIRE_FORMAT_WIRE: gremlin.ProtoWireNumber = 1;
    const NO_STANDARD_DESCRIPTOR_ACCESSOR_WIRE: gremlin.ProtoWireNumber = 2;
    const DEPRECATED_WIRE: gremlin.ProtoWireNumber = 3;
    const MAP_ENTRY_WIRE: gremlin.ProtoWireNumber = 7;
    const UNINTERPRETED_OPTION_WIRE: gremlin.ProtoWireNumber = 999;
};

pub const MessageOptions = struct {
    // fields
    message_set_wire_format: bool = false,
    no_standard_descriptor_accessor: bool = false,
    deprecated: bool = false,
    map_entry: bool = false,
    uninterpreted_option: ?[]const ?UninterpretedOption = null,

    pub fn calcProtobufSize(self: *const MessageOptions) usize {
        var res: usize = 0;
        if (self.message_set_wire_format != false) {
            res += gremlin.sizes.sizeWireNumber(MessageOptionsWire.MESSAGE_SET_WIRE_FORMAT_WIRE) + gremlin.sizes.sizeBool(self.message_set_wire_format);
        }
        if (self.no_standard_descriptor_accessor != false) {
            res += gremlin.sizes.sizeWireNumber(MessageOptionsWire.NO_STANDARD_DESCRIPTOR_ACCESSOR_WIRE) + gremlin.sizes.sizeBool(self.no_standard_descriptor_accessor);
        }
        if (self.deprecated != false) {
            res += gremlin.sizes.sizeWireNumber(MessageOptionsWire.DEPRECATED_WIRE) + gremlin.sizes.sizeBool(self.deprecated);
        }
        if (self.map_entry != false) {
            res += gremlin.sizes.sizeWireNumber(MessageOptionsWire.MAP_ENTRY_WIRE) + gremlin.sizes.sizeBool(self.map_entry);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(MessageOptionsWire.UNINTERPRETED_OPTION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const MessageOptions, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const MessageOptions, target: *gremlin.Writer) void {
        if (self.message_set_wire_format != false) {
            target.appendBool(MessageOptionsWire.MESSAGE_SET_WIRE_FORMAT_WIRE, self.message_set_wire_format);
        }
        if (self.no_standard_descriptor_accessor != false) {
            target.appendBool(MessageOptionsWire.NO_STANDARD_DESCRIPTOR_ACCESSOR_WIRE, self.no_standard_descriptor_accessor);
        }
        if (self.deprecated != false) {
            target.appendBool(MessageOptionsWire.DEPRECATED_WIRE, self.deprecated);
        }
        if (self.map_entry != false) {
            target.appendBool(MessageOptionsWire.MAP_ENTRY_WIRE, self.map_entry);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(MessageOptionsWire.UNINTERPRETED_OPTION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(MessageOptionsWire.UNINTERPRETED_OPTION_WIRE, 0);
                }
            }
        }
    }
};

pub const MessageOptionsReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _message_set_wire_format: bool = false,
    _no_standard_descriptor_accessor: bool = false,
    _deprecated: bool = false,
    _map_entry: bool = false,
    _uninterpreted_option_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!MessageOptionsReader {
        var buf = gremlin.Reader.init(src);
        var res = MessageOptionsReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                MessageOptionsWire.MESSAGE_SET_WIRE_FORMAT_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._message_set_wire_format = result.value;
                },
                MessageOptionsWire.NO_STANDARD_DESCRIPTOR_ACCESSOR_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._no_standard_descriptor_accessor = result.value;
                },
                MessageOptionsWire.DEPRECATED_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._deprecated = result.value;
                },
                MessageOptionsWire.MAP_ENTRY_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._map_entry = result.value;
                },
                MessageOptionsWire.UNINTERPRETED_OPTION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._uninterpreted_option_bufs == null) {
                        res._uninterpreted_option_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._uninterpreted_option_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const MessageOptionsReader) void {
        if (self._uninterpreted_option_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getMessageSetWireFormat(self: *const MessageOptionsReader) bool {
        return self._message_set_wire_format;
    }
    pub inline fn getNoStandardDescriptorAccessor(self: *const MessageOptionsReader) bool {
        return self._no_standard_descriptor_accessor;
    }
    pub inline fn getDeprecated(self: *const MessageOptionsReader) bool {
        return self._deprecated;
    }
    pub inline fn getMapEntry(self: *const MessageOptionsReader) bool {
        return self._map_entry;
    }
    pub fn getUninterpretedOption(self: *const MessageOptionsReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOptionReader {
        if (self._uninterpreted_option_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOptionReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOptionReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOptionReader{};
    }
};

const FieldOptionsWire = struct {
    const CTYPE_WIRE: gremlin.ProtoWireNumber = 1;
    const PACKED_WIRE: gremlin.ProtoWireNumber = 2;
    const JSTYPE_WIRE: gremlin.ProtoWireNumber = 6;
    const LAZY_WIRE: gremlin.ProtoWireNumber = 5;
    const UNVERIFIED_LAZY_WIRE: gremlin.ProtoWireNumber = 15;
    const DEPRECATED_WIRE: gremlin.ProtoWireNumber = 3;
    const WEAK_WIRE: gremlin.ProtoWireNumber = 10;
    const UNINTERPRETED_OPTION_WIRE: gremlin.ProtoWireNumber = 999;
};

pub const FieldOptions = struct {
    // nested enums
    pub const CType = enum(i32) {
        STRING = 0,
        CORD = 1,
        STRING_PIECE = 2,
    };

    pub const JSType = enum(i32) {
        JS_NORMAL = 0,
        JS_STRING = 1,
        JS_NUMBER = 2,
    };

    // fields
    ctype: FieldOptions.CType = @enumFromInt(0),
    packed_: bool = false,
    jstype: FieldOptions.JSType = @enumFromInt(0),
    lazy: bool = false,
    unverified_lazy: bool = false,
    deprecated: bool = false,
    weak: bool = false,
    uninterpreted_option: ?[]const ?UninterpretedOption = null,

    pub fn calcProtobufSize(self: *const FieldOptions) usize {
        var res: usize = 0;
        if (self.ctype != FieldOptions.CType.STRING) {
            res += gremlin.sizes.sizeWireNumber(FieldOptionsWire.CTYPE_WIRE) + gremlin.sizes.sizeI32(@intFromEnum(self.ctype));
        }
        if (self.packed_ != false) {
            res += gremlin.sizes.sizeWireNumber(FieldOptionsWire.PACKED_WIRE) + gremlin.sizes.sizeBool(self.packed_);
        }
        if (self.jstype != FieldOptions.JSType.JS_NORMAL) {
            res += gremlin.sizes.sizeWireNumber(FieldOptionsWire.JSTYPE_WIRE) + gremlin.sizes.sizeI32(@intFromEnum(self.jstype));
        }
        if (self.lazy != false) {
            res += gremlin.sizes.sizeWireNumber(FieldOptionsWire.LAZY_WIRE) + gremlin.sizes.sizeBool(self.lazy);
        }
        if (self.unverified_lazy != false) {
            res += gremlin.sizes.sizeWireNumber(FieldOptionsWire.UNVERIFIED_LAZY_WIRE) + gremlin.sizes.sizeBool(self.unverified_lazy);
        }
        if (self.deprecated != false) {
            res += gremlin.sizes.sizeWireNumber(FieldOptionsWire.DEPRECATED_WIRE) + gremlin.sizes.sizeBool(self.deprecated);
        }
        if (self.weak != false) {
            res += gremlin.sizes.sizeWireNumber(FieldOptionsWire.WEAK_WIRE) + gremlin.sizes.sizeBool(self.weak);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(FieldOptionsWire.UNINTERPRETED_OPTION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const FieldOptions, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const FieldOptions, target: *gremlin.Writer) void {
        if (self.ctype != FieldOptions.CType.STRING) {
            target.appendInt32(FieldOptionsWire.CTYPE_WIRE, @intFromEnum(self.ctype));
        }
        if (self.packed_ != false) {
            target.appendBool(FieldOptionsWire.PACKED_WIRE, self.packed_);
        }
        if (self.jstype != FieldOptions.JSType.JS_NORMAL) {
            target.appendInt32(FieldOptionsWire.JSTYPE_WIRE, @intFromEnum(self.jstype));
        }
        if (self.lazy != false) {
            target.appendBool(FieldOptionsWire.LAZY_WIRE, self.lazy);
        }
        if (self.unverified_lazy != false) {
            target.appendBool(FieldOptionsWire.UNVERIFIED_LAZY_WIRE, self.unverified_lazy);
        }
        if (self.deprecated != false) {
            target.appendBool(FieldOptionsWire.DEPRECATED_WIRE, self.deprecated);
        }
        if (self.weak != false) {
            target.appendBool(FieldOptionsWire.WEAK_WIRE, self.weak);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(FieldOptionsWire.UNINTERPRETED_OPTION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(FieldOptionsWire.UNINTERPRETED_OPTION_WIRE, 0);
                }
            }
        }
    }
};

pub const FieldOptionsReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _ctype: FieldOptions.CType = FieldOptions.CType.STRING,
    _packed_: bool = false,
    _jstype: FieldOptions.JSType = FieldOptions.JSType.JS_NORMAL,
    _lazy: bool = false,
    _unverified_lazy: bool = false,
    _deprecated: bool = false,
    _weak: bool = false,
    _uninterpreted_option_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!FieldOptionsReader {
        var buf = gremlin.Reader.init(src);
        var res = FieldOptionsReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                FieldOptionsWire.CTYPE_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._ctype = @enumFromInt(result.value);
                },
                FieldOptionsWire.PACKED_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._packed_ = result.value;
                },
                FieldOptionsWire.JSTYPE_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._jstype = @enumFromInt(result.value);
                },
                FieldOptionsWire.LAZY_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._lazy = result.value;
                },
                FieldOptionsWire.UNVERIFIED_LAZY_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._unverified_lazy = result.value;
                },
                FieldOptionsWire.DEPRECATED_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._deprecated = result.value;
                },
                FieldOptionsWire.WEAK_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._weak = result.value;
                },
                FieldOptionsWire.UNINTERPRETED_OPTION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._uninterpreted_option_bufs == null) {
                        res._uninterpreted_option_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._uninterpreted_option_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const FieldOptionsReader) void {
        if (self._uninterpreted_option_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getCtype(self: *const FieldOptionsReader) FieldOptions.CType {
        return self._ctype;
    }
    pub inline fn getPacked(self: *const FieldOptionsReader) bool {
        return self._packed_;
    }
    pub inline fn getJstype(self: *const FieldOptionsReader) FieldOptions.JSType {
        return self._jstype;
    }
    pub inline fn getLazy(self: *const FieldOptionsReader) bool {
        return self._lazy;
    }
    pub inline fn getUnverifiedLazy(self: *const FieldOptionsReader) bool {
        return self._unverified_lazy;
    }
    pub inline fn getDeprecated(self: *const FieldOptionsReader) bool {
        return self._deprecated;
    }
    pub inline fn getWeak(self: *const FieldOptionsReader) bool {
        return self._weak;
    }
    pub fn getUninterpretedOption(self: *const FieldOptionsReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOptionReader {
        if (self._uninterpreted_option_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOptionReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOptionReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOptionReader{};
    }
};

const OneofOptionsWire = struct {
    const UNINTERPRETED_OPTION_WIRE: gremlin.ProtoWireNumber = 999;
};

pub const OneofOptions = struct {
    // fields
    uninterpreted_option: ?[]const ?UninterpretedOption = null,

    pub fn calcProtobufSize(self: *const OneofOptions) usize {
        var res: usize = 0;
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(OneofOptionsWire.UNINTERPRETED_OPTION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const OneofOptions, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const OneofOptions, target: *gremlin.Writer) void {
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(OneofOptionsWire.UNINTERPRETED_OPTION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(OneofOptionsWire.UNINTERPRETED_OPTION_WIRE, 0);
                }
            }
        }
    }
};

pub const OneofOptionsReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _uninterpreted_option_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!OneofOptionsReader {
        var buf = gremlin.Reader.init(src);
        var res = OneofOptionsReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                OneofOptionsWire.UNINTERPRETED_OPTION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._uninterpreted_option_bufs == null) {
                        res._uninterpreted_option_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._uninterpreted_option_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const OneofOptionsReader) void {
        if (self._uninterpreted_option_bufs) |arr| {
            arr.deinit();
        }
    }
    pub fn getUninterpretedOption(self: *const OneofOptionsReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOptionReader {
        if (self._uninterpreted_option_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOptionReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOptionReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOptionReader{};
    }
};

const EnumOptionsWire = struct {
    const ALLOW_ALIAS_WIRE: gremlin.ProtoWireNumber = 2;
    const DEPRECATED_WIRE: gremlin.ProtoWireNumber = 3;
    const UNINTERPRETED_OPTION_WIRE: gremlin.ProtoWireNumber = 999;
};

pub const EnumOptions = struct {
    // fields
    allow_alias: bool = false,
    deprecated: bool = false,
    uninterpreted_option: ?[]const ?UninterpretedOption = null,

    pub fn calcProtobufSize(self: *const EnumOptions) usize {
        var res: usize = 0;
        if (self.allow_alias != false) {
            res += gremlin.sizes.sizeWireNumber(EnumOptionsWire.ALLOW_ALIAS_WIRE) + gremlin.sizes.sizeBool(self.allow_alias);
        }
        if (self.deprecated != false) {
            res += gremlin.sizes.sizeWireNumber(EnumOptionsWire.DEPRECATED_WIRE) + gremlin.sizes.sizeBool(self.deprecated);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(EnumOptionsWire.UNINTERPRETED_OPTION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const EnumOptions, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const EnumOptions, target: *gremlin.Writer) void {
        if (self.allow_alias != false) {
            target.appendBool(EnumOptionsWire.ALLOW_ALIAS_WIRE, self.allow_alias);
        }
        if (self.deprecated != false) {
            target.appendBool(EnumOptionsWire.DEPRECATED_WIRE, self.deprecated);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(EnumOptionsWire.UNINTERPRETED_OPTION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(EnumOptionsWire.UNINTERPRETED_OPTION_WIRE, 0);
                }
            }
        }
    }
};

pub const EnumOptionsReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _allow_alias: bool = false,
    _deprecated: bool = false,
    _uninterpreted_option_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!EnumOptionsReader {
        var buf = gremlin.Reader.init(src);
        var res = EnumOptionsReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                EnumOptionsWire.ALLOW_ALIAS_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._allow_alias = result.value;
                },
                EnumOptionsWire.DEPRECATED_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._deprecated = result.value;
                },
                EnumOptionsWire.UNINTERPRETED_OPTION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._uninterpreted_option_bufs == null) {
                        res._uninterpreted_option_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._uninterpreted_option_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const EnumOptionsReader) void {
        if (self._uninterpreted_option_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getAllowAlias(self: *const EnumOptionsReader) bool {
        return self._allow_alias;
    }
    pub inline fn getDeprecated(self: *const EnumOptionsReader) bool {
        return self._deprecated;
    }
    pub fn getUninterpretedOption(self: *const EnumOptionsReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOptionReader {
        if (self._uninterpreted_option_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOptionReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOptionReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOptionReader{};
    }
};

const EnumValueOptionsWire = struct {
    const DEPRECATED_WIRE: gremlin.ProtoWireNumber = 1;
    const UNINTERPRETED_OPTION_WIRE: gremlin.ProtoWireNumber = 999;
};

pub const EnumValueOptions = struct {
    // fields
    deprecated: bool = false,
    uninterpreted_option: ?[]const ?UninterpretedOption = null,

    pub fn calcProtobufSize(self: *const EnumValueOptions) usize {
        var res: usize = 0;
        if (self.deprecated != false) {
            res += gremlin.sizes.sizeWireNumber(EnumValueOptionsWire.DEPRECATED_WIRE) + gremlin.sizes.sizeBool(self.deprecated);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(EnumValueOptionsWire.UNINTERPRETED_OPTION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const EnumValueOptions, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const EnumValueOptions, target: *gremlin.Writer) void {
        if (self.deprecated != false) {
            target.appendBool(EnumValueOptionsWire.DEPRECATED_WIRE, self.deprecated);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(EnumValueOptionsWire.UNINTERPRETED_OPTION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(EnumValueOptionsWire.UNINTERPRETED_OPTION_WIRE, 0);
                }
            }
        }
    }
};

pub const EnumValueOptionsReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _deprecated: bool = false,
    _uninterpreted_option_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!EnumValueOptionsReader {
        var buf = gremlin.Reader.init(src);
        var res = EnumValueOptionsReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                EnumValueOptionsWire.DEPRECATED_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._deprecated = result.value;
                },
                EnumValueOptionsWire.UNINTERPRETED_OPTION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._uninterpreted_option_bufs == null) {
                        res._uninterpreted_option_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._uninterpreted_option_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const EnumValueOptionsReader) void {
        if (self._uninterpreted_option_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getDeprecated(self: *const EnumValueOptionsReader) bool {
        return self._deprecated;
    }
    pub fn getUninterpretedOption(self: *const EnumValueOptionsReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOptionReader {
        if (self._uninterpreted_option_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOptionReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOptionReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOptionReader{};
    }
};

const ServiceOptionsWire = struct {
    const DEPRECATED_WIRE: gremlin.ProtoWireNumber = 33;
    const UNINTERPRETED_OPTION_WIRE: gremlin.ProtoWireNumber = 999;
};

pub const ServiceOptions = struct {
    // fields
    deprecated: bool = false,
    uninterpreted_option: ?[]const ?UninterpretedOption = null,

    pub fn calcProtobufSize(self: *const ServiceOptions) usize {
        var res: usize = 0;
        if (self.deprecated != false) {
            res += gremlin.sizes.sizeWireNumber(ServiceOptionsWire.DEPRECATED_WIRE) + gremlin.sizes.sizeBool(self.deprecated);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(ServiceOptionsWire.UNINTERPRETED_OPTION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const ServiceOptions, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const ServiceOptions, target: *gremlin.Writer) void {
        if (self.deprecated != false) {
            target.appendBool(ServiceOptionsWire.DEPRECATED_WIRE, self.deprecated);
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(ServiceOptionsWire.UNINTERPRETED_OPTION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(ServiceOptionsWire.UNINTERPRETED_OPTION_WIRE, 0);
                }
            }
        }
    }
};

pub const ServiceOptionsReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _deprecated: bool = false,
    _uninterpreted_option_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!ServiceOptionsReader {
        var buf = gremlin.Reader.init(src);
        var res = ServiceOptionsReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                ServiceOptionsWire.DEPRECATED_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._deprecated = result.value;
                },
                ServiceOptionsWire.UNINTERPRETED_OPTION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._uninterpreted_option_bufs == null) {
                        res._uninterpreted_option_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._uninterpreted_option_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const ServiceOptionsReader) void {
        if (self._uninterpreted_option_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getDeprecated(self: *const ServiceOptionsReader) bool {
        return self._deprecated;
    }
    pub fn getUninterpretedOption(self: *const ServiceOptionsReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOptionReader {
        if (self._uninterpreted_option_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOptionReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOptionReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOptionReader{};
    }
};

const MethodOptionsWire = struct {
    const DEPRECATED_WIRE: gremlin.ProtoWireNumber = 33;
    const IDEMPOTENCY_LEVEL_WIRE: gremlin.ProtoWireNumber = 34;
    const UNINTERPRETED_OPTION_WIRE: gremlin.ProtoWireNumber = 999;
};

pub const MethodOptions = struct {
    // nested enums
    pub const IdempotencyLevel = enum(i32) {
        IDEMPOTENCY_UNKNOWN = 0,
        NO_SIDE_EFFECTS = 1,
        IDEMPOTENT = 2,
    };

    // fields
    deprecated: bool = false,
    idempotency_level: MethodOptions.IdempotencyLevel = @enumFromInt(0),
    uninterpreted_option: ?[]const ?UninterpretedOption = null,

    pub fn calcProtobufSize(self: *const MethodOptions) usize {
        var res: usize = 0;
        if (self.deprecated != false) {
            res += gremlin.sizes.sizeWireNumber(MethodOptionsWire.DEPRECATED_WIRE) + gremlin.sizes.sizeBool(self.deprecated);
        }
        if (self.idempotency_level != MethodOptions.IdempotencyLevel.IDEMPOTENCY_UNKNOWN) {
            res += gremlin.sizes.sizeWireNumber(MethodOptionsWire.IDEMPOTENCY_LEVEL_WIRE) + gremlin.sizes.sizeI32(@intFromEnum(self.idempotency_level));
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(MethodOptionsWire.UNINTERPRETED_OPTION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const MethodOptions, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const MethodOptions, target: *gremlin.Writer) void {
        if (self.deprecated != false) {
            target.appendBool(MethodOptionsWire.DEPRECATED_WIRE, self.deprecated);
        }
        if (self.idempotency_level != MethodOptions.IdempotencyLevel.IDEMPOTENCY_UNKNOWN) {
            target.appendInt32(MethodOptionsWire.IDEMPOTENCY_LEVEL_WIRE, @intFromEnum(self.idempotency_level));
        }
        if (self.uninterpreted_option) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(MethodOptionsWire.UNINTERPRETED_OPTION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(MethodOptionsWire.UNINTERPRETED_OPTION_WIRE, 0);
                }
            }
        }
    }
};

pub const MethodOptionsReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _deprecated: bool = false,
    _idempotency_level: MethodOptions.IdempotencyLevel = MethodOptions.IdempotencyLevel.IDEMPOTENCY_UNKNOWN,
    _uninterpreted_option_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!MethodOptionsReader {
        var buf = gremlin.Reader.init(src);
        var res = MethodOptionsReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                MethodOptionsWire.DEPRECATED_WIRE => {
                    const result = try buf.readBool(offset);
                    offset += result.size;
                    res._deprecated = result.value;
                },
                MethodOptionsWire.IDEMPOTENCY_LEVEL_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._idempotency_level = @enumFromInt(result.value);
                },
                MethodOptionsWire.UNINTERPRETED_OPTION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._uninterpreted_option_bufs == null) {
                        res._uninterpreted_option_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._uninterpreted_option_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const MethodOptionsReader) void {
        if (self._uninterpreted_option_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getDeprecated(self: *const MethodOptionsReader) bool {
        return self._deprecated;
    }
    pub inline fn getIdempotencyLevel(self: *const MethodOptionsReader) MethodOptions.IdempotencyLevel {
        return self._idempotency_level;
    }
    pub fn getUninterpretedOption(self: *const MethodOptionsReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOptionReader {
        if (self._uninterpreted_option_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOptionReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOptionReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOptionReader{};
    }
};

const UninterpretedOptionWire = struct {
    const NAME_WIRE: gremlin.ProtoWireNumber = 2;
    const IDENTIFIER_VALUE_WIRE: gremlin.ProtoWireNumber = 3;
    const POSITIVE_INT_VALUE_WIRE: gremlin.ProtoWireNumber = 4;
    const NEGATIVE_INT_VALUE_WIRE: gremlin.ProtoWireNumber = 5;
    const DOUBLE_VALUE_WIRE: gremlin.ProtoWireNumber = 6;
    const STRING_VALUE_WIRE: gremlin.ProtoWireNumber = 7;
    const AGGREGATE_VALUE_WIRE: gremlin.ProtoWireNumber = 8;
};

pub const UninterpretedOption = struct {
    // nested structs
    const NamePartWire = struct {
        const NAME_PART_WIRE: gremlin.ProtoWireNumber = 1;
        const IS_EXTENSION_WIRE: gremlin.ProtoWireNumber = 2;
    };

    pub const NamePart = struct {
        // fields
        name_part: ?[]const u8 = null,
        is_extension: bool = false,

        pub fn calcProtobufSize(self: *const NamePart) usize {
            var res: usize = 0;
            if (self.name_part) |v| {
                if (v.len > 0) {
                    res += gremlin.sizes.sizeWireNumber(UninterpretedOption.NamePartWire.NAME_PART_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
                }
            }
            if (self.is_extension != false) {
                res += gremlin.sizes.sizeWireNumber(UninterpretedOption.NamePartWire.IS_EXTENSION_WIRE) + gremlin.sizes.sizeBool(self.is_extension);
            }
            return res;
        }

        pub fn encode(self: *const NamePart, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
            const size = self.calcProtobufSize();
            if (size == 0) {
                return &[_]u8{};
            }
            const buf = try allocator.alloc(u8, self.calcProtobufSize());
            var writer = gremlin.Writer.init(buf);
            self.encodeTo(&writer);
            return buf;
        }

        pub fn encodeTo(self: *const NamePart, target: *gremlin.Writer) void {
            if (self.name_part) |v| {
                if (v.len > 0) {
                    target.appendBytes(UninterpretedOption.NamePartWire.NAME_PART_WIRE, v);
                }
            }
            if (self.is_extension != false) {
                target.appendBool(UninterpretedOption.NamePartWire.IS_EXTENSION_WIRE, self.is_extension);
            }
        }
    };

    pub const NamePartReader = struct {
        _name_part: ?[]const u8 = null,
        _is_extension: bool = false,

        pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!NamePartReader {
            var buf = gremlin.Reader.init(src);
            var res = NamePartReader{};
            if (buf.buf.len == 0) {
                return res;
            }
            var offset: usize = 0;
            while (buf.hasNext(offset, 0)) {
                const tag = try buf.readTagAt(offset);
                offset += tag.size;
                switch (tag.number) {
                    UninterpretedOption.NamePartWire.NAME_PART_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        res._name_part = result.value;
                    },
                    UninterpretedOption.NamePartWire.IS_EXTENSION_WIRE => {
                        const result = try buf.readBool(offset);
                        offset += result.size;
                        res._is_extension = result.value;
                    },
                    else => {
                        offset = try buf.skipData(offset, tag.wire);
                    },
                }
            }
            return res;
        }
        pub fn deinit(_: *const NamePartReader) void {}

        pub inline fn getNamePart(self: *const NamePartReader) []const u8 {
            return self._name_part orelse &[_]u8{};
        }
        pub inline fn getIsExtension(self: *const NamePartReader) bool {
            return self._is_extension;
        }
    };

    // fields
    name: ?[]const ?UninterpretedOption.NamePart = null,
    identifier_value: ?[]const u8 = null,
    positive_int_value: u64 = 0,
    negative_int_value: i64 = 0,
    double_value: f64 = 0.0,
    string_value: ?[]const u8 = null,
    aggregate_value: ?[]const u8 = null,

    pub fn calcProtobufSize(self: *const UninterpretedOption) usize {
        var res: usize = 0;
        if (self.name) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(UninterpretedOptionWire.NAME_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.identifier_value) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(UninterpretedOptionWire.IDENTIFIER_VALUE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.positive_int_value != 0) {
            res += gremlin.sizes.sizeWireNumber(UninterpretedOptionWire.POSITIVE_INT_VALUE_WIRE) + gremlin.sizes.sizeU64(self.positive_int_value);
        }
        if (self.negative_int_value != 0) {
            res += gremlin.sizes.sizeWireNumber(UninterpretedOptionWire.NEGATIVE_INT_VALUE_WIRE) + gremlin.sizes.sizeI64(self.negative_int_value);
        }
        if (self.double_value != 0.0) {
            res += gremlin.sizes.sizeWireNumber(UninterpretedOptionWire.DOUBLE_VALUE_WIRE) + gremlin.sizes.sizeDouble(self.double_value);
        }
        if (self.string_value) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(UninterpretedOptionWire.STRING_VALUE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.aggregate_value) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(UninterpretedOptionWire.AGGREGATE_VALUE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        return res;
    }

    pub fn encode(self: *const UninterpretedOption, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const UninterpretedOption, target: *gremlin.Writer) void {
        if (self.name) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(UninterpretedOptionWire.NAME_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(UninterpretedOptionWire.NAME_WIRE, 0);
                }
            }
        }
        if (self.identifier_value) |v| {
            if (v.len > 0) {
                target.appendBytes(UninterpretedOptionWire.IDENTIFIER_VALUE_WIRE, v);
            }
        }
        if (self.positive_int_value != 0) {
            target.appendUint64(UninterpretedOptionWire.POSITIVE_INT_VALUE_WIRE, self.positive_int_value);
        }
        if (self.negative_int_value != 0) {
            target.appendInt64(UninterpretedOptionWire.NEGATIVE_INT_VALUE_WIRE, self.negative_int_value);
        }
        if (self.double_value != 0.0) {
            target.appendFloat64(UninterpretedOptionWire.DOUBLE_VALUE_WIRE, self.double_value);
        }
        if (self.string_value) |v| {
            if (v.len > 0) {
                target.appendBytes(UninterpretedOptionWire.STRING_VALUE_WIRE, v);
            }
        }
        if (self.aggregate_value) |v| {
            if (v.len > 0) {
                target.appendBytes(UninterpretedOptionWire.AGGREGATE_VALUE_WIRE, v);
            }
        }
    }
};

pub const UninterpretedOptionReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _name_bufs: ?std.ArrayList([]const u8) = null,
    _identifier_value: ?[]const u8 = null,
    _positive_int_value: u64 = 0,
    _negative_int_value: i64 = 0,
    _double_value: f64 = 0.0,
    _string_value: ?[]const u8 = null,
    _aggregate_value: ?[]const u8 = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!UninterpretedOptionReader {
        var buf = gremlin.Reader.init(src);
        var res = UninterpretedOptionReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                UninterpretedOptionWire.NAME_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._name_bufs == null) {
                        res._name_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._name_bufs.?.append(result.value);
                },
                UninterpretedOptionWire.IDENTIFIER_VALUE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._identifier_value = result.value;
                },
                UninterpretedOptionWire.POSITIVE_INT_VALUE_WIRE => {
                    const result = try buf.readUInt64(offset);
                    offset += result.size;
                    res._positive_int_value = result.value;
                },
                UninterpretedOptionWire.NEGATIVE_INT_VALUE_WIRE => {
                    const result = try buf.readInt64(offset);
                    offset += result.size;
                    res._negative_int_value = result.value;
                },
                UninterpretedOptionWire.DOUBLE_VALUE_WIRE => {
                    const result = try buf.readFloat64(offset);
                    offset += result.size;
                    res._double_value = result.value;
                },
                UninterpretedOptionWire.STRING_VALUE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._string_value = result.value;
                },
                UninterpretedOptionWire.AGGREGATE_VALUE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._aggregate_value = result.value;
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const UninterpretedOptionReader) void {
        if (self._name_bufs) |arr| {
            arr.deinit();
        }
    }
    pub fn getName(self: *const UninterpretedOptionReader, allocator: std.mem.Allocator) gremlin.Error![]UninterpretedOption.NamePartReader {
        if (self._name_bufs) |bufs| {
            var result = try std.ArrayList(UninterpretedOption.NamePartReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try UninterpretedOption.NamePartReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]UninterpretedOption.NamePartReader{};
    }
    pub inline fn getIdentifierValue(self: *const UninterpretedOptionReader) []const u8 {
        return self._identifier_value orelse &[_]u8{};
    }
    pub inline fn getPositiveIntValue(self: *const UninterpretedOptionReader) u64 {
        return self._positive_int_value;
    }
    pub inline fn getNegativeIntValue(self: *const UninterpretedOptionReader) i64 {
        return self._negative_int_value;
    }
    pub inline fn getDoubleValue(self: *const UninterpretedOptionReader) f64 {
        return self._double_value;
    }
    pub inline fn getStringValue(self: *const UninterpretedOptionReader) []const u8 {
        return self._string_value orelse &[_]u8{};
    }
    pub inline fn getAggregateValue(self: *const UninterpretedOptionReader) []const u8 {
        return self._aggregate_value orelse &[_]u8{};
    }
};

const SourceCodeInfoWire = struct {
    const LOCATION_WIRE: gremlin.ProtoWireNumber = 1;
};

pub const SourceCodeInfo = struct {
    // nested structs
    const LocationWire = struct {
        const PATH_WIRE: gremlin.ProtoWireNumber = 1;
        const SPAN_WIRE: gremlin.ProtoWireNumber = 2;
        const LEADING_COMMENTS_WIRE: gremlin.ProtoWireNumber = 3;
        const TRAILING_COMMENTS_WIRE: gremlin.ProtoWireNumber = 4;
        const LEADING_DETACHED_COMMENTS_WIRE: gremlin.ProtoWireNumber = 6;
    };

    pub const Location = struct {
        // fields
        path: ?[]const i32 = null,
        span: ?[]const i32 = null,
        leading_comments: ?[]const u8 = null,
        trailing_comments: ?[]const u8 = null,
        leading_detached_comments: ?[]const ?[]const u8 = null,

        pub fn calcProtobufSize(self: *const Location) usize {
            var res: usize = 0;
            if (self.path) |arr| {
                if (arr.len == 0) {} else if (arr.len == 1) {
                    res += gremlin.sizes.sizeWireNumber(SourceCodeInfo.LocationWire.PATH_WIRE) + gremlin.sizes.sizeI32(arr[0]);
                } else {
                    var packed_size: usize = 0;
                    for (arr) |v| {
                        packed_size += gremlin.sizes.sizeI32(v);
                    }
                    res += gremlin.sizes.sizeWireNumber(SourceCodeInfo.LocationWire.PATH_WIRE) + gremlin.sizes.sizeUsize(packed_size) + packed_size;
                }
            }
            if (self.span) |arr| {
                if (arr.len == 0) {} else if (arr.len == 1) {
                    res += gremlin.sizes.sizeWireNumber(SourceCodeInfo.LocationWire.SPAN_WIRE) + gremlin.sizes.sizeI32(arr[0]);
                } else {
                    var packed_size: usize = 0;
                    for (arr) |v| {
                        packed_size += gremlin.sizes.sizeI32(v);
                    }
                    res += gremlin.sizes.sizeWireNumber(SourceCodeInfo.LocationWire.SPAN_WIRE) + gremlin.sizes.sizeUsize(packed_size) + packed_size;
                }
            }
            if (self.leading_comments) |v| {
                if (v.len > 0) {
                    res += gremlin.sizes.sizeWireNumber(SourceCodeInfo.LocationWire.LEADING_COMMENTS_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
                }
            }
            if (self.trailing_comments) |v| {
                if (v.len > 0) {
                    res += gremlin.sizes.sizeWireNumber(SourceCodeInfo.LocationWire.TRAILING_COMMENTS_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
                }
            }
            if (self.leading_detached_comments) |arr| {
                for (arr) |maybe_v| {
                    res += gremlin.sizes.sizeWireNumber(SourceCodeInfo.LocationWire.LEADING_DETACHED_COMMENTS_WIRE);
                    if (maybe_v) |v| {
                        res += gremlin.sizes.sizeUsize(v.len) + v.len;
                    } else {
                        res += gremlin.sizes.sizeUsize(0);
                    }
                }
            }
            return res;
        }

        pub fn encode(self: *const Location, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
            const size = self.calcProtobufSize();
            if (size == 0) {
                return &[_]u8{};
            }
            const buf = try allocator.alloc(u8, self.calcProtobufSize());
            var writer = gremlin.Writer.init(buf);
            self.encodeTo(&writer);
            return buf;
        }

        pub fn encodeTo(self: *const Location, target: *gremlin.Writer) void {
            if (self.path) |arr| {
                if (arr.len == 0) {} else if (arr.len == 1) {
                    target.appendInt32(SourceCodeInfo.LocationWire.PATH_WIRE, arr[0]);
                } else {
                    var packed_size: usize = 0;
                    for (arr) |v| {
                        packed_size += gremlin.sizes.sizeI32(v);
                    }
                    target.appendBytesTag(SourceCodeInfo.LocationWire.PATH_WIRE, packed_size);
                    for (arr) |v| {
                        target.appendInt32WithoutTag(v);
                    }
                }
            }
            if (self.span) |arr| {
                if (arr.len == 0) {} else if (arr.len == 1) {
                    target.appendInt32(SourceCodeInfo.LocationWire.SPAN_WIRE, arr[0]);
                } else {
                    var packed_size: usize = 0;
                    for (arr) |v| {
                        packed_size += gremlin.sizes.sizeI32(v);
                    }
                    target.appendBytesTag(SourceCodeInfo.LocationWire.SPAN_WIRE, packed_size);
                    for (arr) |v| {
                        target.appendInt32WithoutTag(v);
                    }
                }
            }
            if (self.leading_comments) |v| {
                if (v.len > 0) {
                    target.appendBytes(SourceCodeInfo.LocationWire.LEADING_COMMENTS_WIRE, v);
                }
            }
            if (self.trailing_comments) |v| {
                if (v.len > 0) {
                    target.appendBytes(SourceCodeInfo.LocationWire.TRAILING_COMMENTS_WIRE, v);
                }
            }
            if (self.leading_detached_comments) |arr| {
                for (arr) |maybe_v| {
                    if (maybe_v) |v| {
                        target.appendBytes(SourceCodeInfo.LocationWire.LEADING_DETACHED_COMMENTS_WIRE, v);
                    } else {
                        target.appendBytesTag(SourceCodeInfo.LocationWire.LEADING_DETACHED_COMMENTS_WIRE, 0);
                    }
                }
            }
        }
    };

    pub const LocationReader = struct {
        allocator: std.mem.Allocator,
        buf: gremlin.Reader,
        _path_offsets: ?std.ArrayList(usize) = null,
        _path_wires: ?std.ArrayList(gremlin.ProtoWireType) = null,
        _span_offsets: ?std.ArrayList(usize) = null,
        _span_wires: ?std.ArrayList(gremlin.ProtoWireType) = null,
        _leading_comments: ?[]const u8 = null,
        _trailing_comments: ?[]const u8 = null,
        _leading_detached_comments: ?std.ArrayList([]const u8) = null,

        pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!LocationReader {
            var buf = gremlin.Reader.init(src);
            var res = LocationReader{ .allocator = allocator, .buf = buf };
            if (buf.buf.len == 0) {
                return res;
            }
            var offset: usize = 0;
            while (buf.hasNext(offset, 0)) {
                const tag = try buf.readTagAt(offset);
                offset += tag.size;
                switch (tag.number) {
                    SourceCodeInfo.LocationWire.PATH_WIRE => {
                        if (res._path_offsets == null) {
                            res._path_offsets = std.ArrayList(usize).init(allocator);
                            res._path_wires = std.ArrayList(gremlin.ProtoWireType).init(allocator);
                        }
                        try res._path_offsets.?.append(offset);
                        try res._path_wires.?.append(tag.wire);
                        if (tag.wire == gremlin.ProtoWireType.bytes) {
                            const length_result = try buf.readVarInt(offset);
                            offset += length_result.size + @as(usize, @intCast(length_result.value));
                        } else {
                            const result = try buf.readInt32(offset);
                            offset += result.size;
                        }
                    },
                    SourceCodeInfo.LocationWire.SPAN_WIRE => {
                        if (res._span_offsets == null) {
                            res._span_offsets = std.ArrayList(usize).init(allocator);
                            res._span_wires = std.ArrayList(gremlin.ProtoWireType).init(allocator);
                        }
                        try res._span_offsets.?.append(offset);
                        try res._span_wires.?.append(tag.wire);
                        if (tag.wire == gremlin.ProtoWireType.bytes) {
                            const length_result = try buf.readVarInt(offset);
                            offset += length_result.size + @as(usize, @intCast(length_result.value));
                        } else {
                            const result = try buf.readInt32(offset);
                            offset += result.size;
                        }
                    },
                    SourceCodeInfo.LocationWire.LEADING_COMMENTS_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        res._leading_comments = result.value;
                    },
                    SourceCodeInfo.LocationWire.TRAILING_COMMENTS_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        res._trailing_comments = result.value;
                    },
                    SourceCodeInfo.LocationWire.LEADING_DETACHED_COMMENTS_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        if (res._leading_detached_comments == null) {
                            res._leading_detached_comments = std.ArrayList([]const u8).init(allocator);
                        }
                        try res._leading_detached_comments.?.append(result.value);
                    },
                    else => {
                        offset = try buf.skipData(offset, tag.wire);
                    },
                }
            }
            return res;
        }
        pub fn deinit(self: *const LocationReader) void {
            if (self._path_offsets) |arr| {
                arr.deinit();
            }
            if (self._path_wires) |arr| {
                arr.deinit();
            }
            if (self._span_offsets) |arr| {
                arr.deinit();
            }
            if (self._span_wires) |arr| {
                arr.deinit();
            }
            if (self._leading_detached_comments) |arr| {
                arr.deinit();
            }
        }
        pub fn getPath(self: *const LocationReader, allocator: std.mem.Allocator) gremlin.Error![]i32 {
            if (self._path_offsets) |offsets| {
                if (offsets.items.len == 0) return &[_]i32{};

                var result = std.ArrayList(i32).init(allocator);
                errdefer result.deinit();

                for (offsets.items, self._path_wires.?.items) |start_offset, wire_type| {
                    if (wire_type == .bytes) {
                        const length_result = try self.buf.readVarInt(start_offset);
                        var offset = start_offset + length_result.size;
                        const end_offset = offset + @as(usize, @intCast(length_result.value));

                        while (offset < end_offset) {
                            const value_result = try self.buf.readInt32(offset);
                            try result.append(value_result.value);
                            offset += value_result.size;
                        }
                    } else {
                        const value_result = try self.buf.readInt32(start_offset);
                        try result.append(value_result.value);
                    }
                }
                return result.toOwnedSlice();
            }
            return &[_]i32{};
        }
        pub fn getSpan(self: *const LocationReader, allocator: std.mem.Allocator) gremlin.Error![]i32 {
            if (self._span_offsets) |offsets| {
                if (offsets.items.len == 0) return &[_]i32{};

                var result = std.ArrayList(i32).init(allocator);
                errdefer result.deinit();

                for (offsets.items, self._span_wires.?.items) |start_offset, wire_type| {
                    if (wire_type == .bytes) {
                        const length_result = try self.buf.readVarInt(start_offset);
                        var offset = start_offset + length_result.size;
                        const end_offset = offset + @as(usize, @intCast(length_result.value));

                        while (offset < end_offset) {
                            const value_result = try self.buf.readInt32(offset);
                            try result.append(value_result.value);
                            offset += value_result.size;
                        }
                    } else {
                        const value_result = try self.buf.readInt32(start_offset);
                        try result.append(value_result.value);
                    }
                }
                return result.toOwnedSlice();
            }
            return &[_]i32{};
        }
        pub inline fn getLeadingComments(self: *const LocationReader) []const u8 {
            return self._leading_comments orelse &[_]u8{};
        }
        pub inline fn getTrailingComments(self: *const LocationReader) []const u8 {
            return self._trailing_comments orelse &[_]u8{};
        }
        pub fn getLeadingDetachedComments(self: *const LocationReader) []const []const u8 {
            if (self._leading_detached_comments) |arr| {
                return arr.items;
            }
            return &[_][]u8{};
        }
    };

    // fields
    location: ?[]const ?SourceCodeInfo.Location = null,

    pub fn calcProtobufSize(self: *const SourceCodeInfo) usize {
        var res: usize = 0;
        if (self.location) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(SourceCodeInfoWire.LOCATION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const SourceCodeInfo, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const SourceCodeInfo, target: *gremlin.Writer) void {
        if (self.location) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(SourceCodeInfoWire.LOCATION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(SourceCodeInfoWire.LOCATION_WIRE, 0);
                }
            }
        }
    }
};

pub const SourceCodeInfoReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _location_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!SourceCodeInfoReader {
        var buf = gremlin.Reader.init(src);
        var res = SourceCodeInfoReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                SourceCodeInfoWire.LOCATION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._location_bufs == null) {
                        res._location_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._location_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const SourceCodeInfoReader) void {
        if (self._location_bufs) |arr| {
            arr.deinit();
        }
    }
    pub fn getLocation(self: *const SourceCodeInfoReader, allocator: std.mem.Allocator) gremlin.Error![]SourceCodeInfo.LocationReader {
        if (self._location_bufs) |bufs| {
            var result = try std.ArrayList(SourceCodeInfo.LocationReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try SourceCodeInfo.LocationReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]SourceCodeInfo.LocationReader{};
    }
};

const GeneratedCodeInfoWire = struct {
    const ANNOTATION_WIRE: gremlin.ProtoWireNumber = 1;
};

pub const GeneratedCodeInfo = struct {
    // nested structs
    const AnnotationWire = struct {
        const PATH_WIRE: gremlin.ProtoWireNumber = 1;
        const SOURCE_FILE_WIRE: gremlin.ProtoWireNumber = 2;
        const BEGIN_WIRE: gremlin.ProtoWireNumber = 3;
        const END_WIRE: gremlin.ProtoWireNumber = 4;
    };

    pub const Annotation = struct {
        // fields
        path: ?[]const i32 = null,
        source_file: ?[]const u8 = null,
        begin: i32 = 0,
        end: i32 = 0,

        pub fn calcProtobufSize(self: *const Annotation) usize {
            var res: usize = 0;
            if (self.path) |arr| {
                if (arr.len == 0) {} else if (arr.len == 1) {
                    res += gremlin.sizes.sizeWireNumber(GeneratedCodeInfo.AnnotationWire.PATH_WIRE) + gremlin.sizes.sizeI32(arr[0]);
                } else {
                    var packed_size: usize = 0;
                    for (arr) |v| {
                        packed_size += gremlin.sizes.sizeI32(v);
                    }
                    res += gremlin.sizes.sizeWireNumber(GeneratedCodeInfo.AnnotationWire.PATH_WIRE) + gremlin.sizes.sizeUsize(packed_size) + packed_size;
                }
            }
            if (self.source_file) |v| {
                if (v.len > 0) {
                    res += gremlin.sizes.sizeWireNumber(GeneratedCodeInfo.AnnotationWire.SOURCE_FILE_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
                }
            }
            if (self.begin != 0) {
                res += gremlin.sizes.sizeWireNumber(GeneratedCodeInfo.AnnotationWire.BEGIN_WIRE) + gremlin.sizes.sizeI32(self.begin);
            }
            if (self.end != 0) {
                res += gremlin.sizes.sizeWireNumber(GeneratedCodeInfo.AnnotationWire.END_WIRE) + gremlin.sizes.sizeI32(self.end);
            }
            return res;
        }

        pub fn encode(self: *const Annotation, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
            const size = self.calcProtobufSize();
            if (size == 0) {
                return &[_]u8{};
            }
            const buf = try allocator.alloc(u8, self.calcProtobufSize());
            var writer = gremlin.Writer.init(buf);
            self.encodeTo(&writer);
            return buf;
        }

        pub fn encodeTo(self: *const Annotation, target: *gremlin.Writer) void {
            if (self.path) |arr| {
                if (arr.len == 0) {} else if (arr.len == 1) {
                    target.appendInt32(GeneratedCodeInfo.AnnotationWire.PATH_WIRE, arr[0]);
                } else {
                    var packed_size: usize = 0;
                    for (arr) |v| {
                        packed_size += gremlin.sizes.sizeI32(v);
                    }
                    target.appendBytesTag(GeneratedCodeInfo.AnnotationWire.PATH_WIRE, packed_size);
                    for (arr) |v| {
                        target.appendInt32WithoutTag(v);
                    }
                }
            }
            if (self.source_file) |v| {
                if (v.len > 0) {
                    target.appendBytes(GeneratedCodeInfo.AnnotationWire.SOURCE_FILE_WIRE, v);
                }
            }
            if (self.begin != 0) {
                target.appendInt32(GeneratedCodeInfo.AnnotationWire.BEGIN_WIRE, self.begin);
            }
            if (self.end != 0) {
                target.appendInt32(GeneratedCodeInfo.AnnotationWire.END_WIRE, self.end);
            }
        }
    };

    pub const AnnotationReader = struct {
        allocator: std.mem.Allocator,
        buf: gremlin.Reader,
        _path_offsets: ?std.ArrayList(usize) = null,
        _path_wires: ?std.ArrayList(gremlin.ProtoWireType) = null,
        _source_file: ?[]const u8 = null,
        _begin: i32 = 0,
        _end: i32 = 0,

        pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!AnnotationReader {
            var buf = gremlin.Reader.init(src);
            var res = AnnotationReader{ .allocator = allocator, .buf = buf };
            if (buf.buf.len == 0) {
                return res;
            }
            var offset: usize = 0;
            while (buf.hasNext(offset, 0)) {
                const tag = try buf.readTagAt(offset);
                offset += tag.size;
                switch (tag.number) {
                    GeneratedCodeInfo.AnnotationWire.PATH_WIRE => {
                        if (res._path_offsets == null) {
                            res._path_offsets = std.ArrayList(usize).init(allocator);
                            res._path_wires = std.ArrayList(gremlin.ProtoWireType).init(allocator);
                        }
                        try res._path_offsets.?.append(offset);
                        try res._path_wires.?.append(tag.wire);
                        if (tag.wire == gremlin.ProtoWireType.bytes) {
                            const length_result = try buf.readVarInt(offset);
                            offset += length_result.size + @as(usize, @intCast(length_result.value));
                        } else {
                            const result = try buf.readInt32(offset);
                            offset += result.size;
                        }
                    },
                    GeneratedCodeInfo.AnnotationWire.SOURCE_FILE_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        res._source_file = result.value;
                    },
                    GeneratedCodeInfo.AnnotationWire.BEGIN_WIRE => {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                        res._begin = result.value;
                    },
                    GeneratedCodeInfo.AnnotationWire.END_WIRE => {
                        const result = try buf.readInt32(offset);
                        offset += result.size;
                        res._end = result.value;
                    },
                    else => {
                        offset = try buf.skipData(offset, tag.wire);
                    },
                }
            }
            return res;
        }
        pub fn deinit(self: *const AnnotationReader) void {
            if (self._path_offsets) |arr| {
                arr.deinit();
            }
            if (self._path_wires) |arr| {
                arr.deinit();
            }
        }
        pub fn getPath(self: *const AnnotationReader, allocator: std.mem.Allocator) gremlin.Error![]i32 {
            if (self._path_offsets) |offsets| {
                if (offsets.items.len == 0) return &[_]i32{};

                var result = std.ArrayList(i32).init(allocator);
                errdefer result.deinit();

                for (offsets.items, self._path_wires.?.items) |start_offset, wire_type| {
                    if (wire_type == .bytes) {
                        const length_result = try self.buf.readVarInt(start_offset);
                        var offset = start_offset + length_result.size;
                        const end_offset = offset + @as(usize, @intCast(length_result.value));

                        while (offset < end_offset) {
                            const value_result = try self.buf.readInt32(offset);
                            try result.append(value_result.value);
                            offset += value_result.size;
                        }
                    } else {
                        const value_result = try self.buf.readInt32(start_offset);
                        try result.append(value_result.value);
                    }
                }
                return result.toOwnedSlice();
            }
            return &[_]i32{};
        }
        pub inline fn getSourceFile(self: *const AnnotationReader) []const u8 {
            return self._source_file orelse &[_]u8{};
        }
        pub inline fn getBegin(self: *const AnnotationReader) i32 {
            return self._begin;
        }
        pub inline fn getEnd(self: *const AnnotationReader) i32 {
            return self._end;
        }
    };

    // fields
    annotation: ?[]const ?GeneratedCodeInfo.Annotation = null,

    pub fn calcProtobufSize(self: *const GeneratedCodeInfo) usize {
        var res: usize = 0;
        if (self.annotation) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(GeneratedCodeInfoWire.ANNOTATION_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        return res;
    }

    pub fn encode(self: *const GeneratedCodeInfo, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const GeneratedCodeInfo, target: *gremlin.Writer) void {
        if (self.annotation) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(GeneratedCodeInfoWire.ANNOTATION_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(GeneratedCodeInfoWire.ANNOTATION_WIRE, 0);
                }
            }
        }
    }
};

pub const GeneratedCodeInfoReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _annotation_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!GeneratedCodeInfoReader {
        var buf = gremlin.Reader.init(src);
        var res = GeneratedCodeInfoReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                GeneratedCodeInfoWire.ANNOTATION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._annotation_bufs == null) {
                        res._annotation_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._annotation_bufs.?.append(result.value);
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const GeneratedCodeInfoReader) void {
        if (self._annotation_bufs) |arr| {
            arr.deinit();
        }
    }
    pub fn getAnnotation(self: *const GeneratedCodeInfoReader, allocator: std.mem.Allocator) gremlin.Error![]GeneratedCodeInfo.AnnotationReader {
        if (self._annotation_bufs) |bufs| {
            var result = try std.ArrayList(GeneratedCodeInfo.AnnotationReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try GeneratedCodeInfo.AnnotationReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]GeneratedCodeInfo.AnnotationReader{};
    }
};
