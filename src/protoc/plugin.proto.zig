const std = @import("std");
const gremlin = @import("gremlin");
const descriptor = @import("descriptor.proto.zig");

// structs
const VersionWire = struct {
    const MAJOR_WIRE: gremlin.ProtoWireNumber = 1;
    const MINOR_WIRE: gremlin.ProtoWireNumber = 2;
    const PATCH_WIRE: gremlin.ProtoWireNumber = 3;
    const SUFFIX_WIRE: gremlin.ProtoWireNumber = 4;
};

pub const Version = struct {
    // fields
    major: i32 = 0,
    minor: i32 = 0,
    patch: i32 = 0,
    suffix: ?[]const u8 = null,

    pub fn calcProtobufSize(self: *const Version) usize {
        var res: usize = 0;
        if (self.major != 0) {
            res += gremlin.sizes.sizeWireNumber(VersionWire.MAJOR_WIRE) + gremlin.sizes.sizeI32(self.major);
        }
        if (self.minor != 0) {
            res += gremlin.sizes.sizeWireNumber(VersionWire.MINOR_WIRE) + gremlin.sizes.sizeI32(self.minor);
        }
        if (self.patch != 0) {
            res += gremlin.sizes.sizeWireNumber(VersionWire.PATCH_WIRE) + gremlin.sizes.sizeI32(self.patch);
        }
        if (self.suffix) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(VersionWire.SUFFIX_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        return res;
    }

    pub fn encode(self: *const Version, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const Version, target: *gremlin.Writer) void {
        if (self.major != 0) {
            target.appendInt32(VersionWire.MAJOR_WIRE, self.major);
        }
        if (self.minor != 0) {
            target.appendInt32(VersionWire.MINOR_WIRE, self.minor);
        }
        if (self.patch != 0) {
            target.appendInt32(VersionWire.PATCH_WIRE, self.patch);
        }
        if (self.suffix) |v| {
            if (v.len > 0) {
                target.appendBytes(VersionWire.SUFFIX_WIRE, v);
            }
        }
    }
};

pub const VersionReader = struct {
    _major: i32 = 0,
    _minor: i32 = 0,
    _patch: i32 = 0,
    _suffix: ?[]const u8 = null,

    pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!VersionReader {
        var buf = gremlin.Reader.init(src);
        var res = VersionReader{};
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                VersionWire.MAJOR_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._major = result.value;
                },
                VersionWire.MINOR_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._minor = result.value;
                },
                VersionWire.PATCH_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._patch = result.value;
                },
                VersionWire.SUFFIX_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._suffix = result.value;
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(_: *const VersionReader) void {}

    pub inline fn getMajor(self: *const VersionReader) i32 {
        return self._major;
    }
    pub inline fn getMinor(self: *const VersionReader) i32 {
        return self._minor;
    }
    pub inline fn getPatch(self: *const VersionReader) i32 {
        return self._patch;
    }
    pub inline fn getSuffix(self: *const VersionReader) []const u8 {
        return self._suffix orelse &[_]u8{};
    }
};

const CodeGeneratorRequestWire = struct {
    const FILE_TO_GENERATE_WIRE: gremlin.ProtoWireNumber = 1;
    const PARAMETER_WIRE: gremlin.ProtoWireNumber = 2;
    const PROTO_FILE_WIRE: gremlin.ProtoWireNumber = 15;
    const SOURCE_FILE_DESCRIPTORS_WIRE: gremlin.ProtoWireNumber = 17;
    const COMPILER_VERSION_WIRE: gremlin.ProtoWireNumber = 3;
};

pub const CodeGeneratorRequest = struct {
    // fields
    file_to_generate: ?[]const ?[]const u8 = null,
    parameter: ?[]const u8 = null,
    proto_file: ?[]const ?descriptor.FileDescriptorProto = null,
    source_file_descriptors: ?[]const ?descriptor.FileDescriptorProto = null,
    compiler_version: ?Version = null,

    pub fn calcProtobufSize(self: *const CodeGeneratorRequest) usize {
        var res: usize = 0;
        if (self.file_to_generate) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(CodeGeneratorRequestWire.FILE_TO_GENERATE_WIRE);
                if (maybe_v) |v| {
                    res += gremlin.sizes.sizeUsize(v.len) + v.len;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.parameter) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(CodeGeneratorRequestWire.PARAMETER_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.proto_file) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(CodeGeneratorRequestWire.PROTO_FILE_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.source_file_descriptors) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(CodeGeneratorRequestWire.SOURCE_FILE_DESCRIPTORS_WIRE);
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    res += gremlin.sizes.sizeUsize(size) + size;
                } else {
                    res += gremlin.sizes.sizeUsize(0);
                }
            }
        }
        if (self.compiler_version) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                res += gremlin.sizes.sizeWireNumber(CodeGeneratorRequestWire.COMPILER_VERSION_WIRE) + gremlin.sizes.sizeUsize(size) + size;
            }
        }
        return res;
    }

    pub fn encode(self: *const CodeGeneratorRequest, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const CodeGeneratorRequest, target: *gremlin.Writer) void {
        if (self.file_to_generate) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    target.appendBytes(CodeGeneratorRequestWire.FILE_TO_GENERATE_WIRE, v);
                } else {
                    target.appendBytesTag(CodeGeneratorRequestWire.FILE_TO_GENERATE_WIRE, 0);
                }
            }
        }
        if (self.parameter) |v| {
            if (v.len > 0) {
                target.appendBytes(CodeGeneratorRequestWire.PARAMETER_WIRE, v);
            }
        }
        if (self.proto_file) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(CodeGeneratorRequestWire.PROTO_FILE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(CodeGeneratorRequestWire.PROTO_FILE_WIRE, 0);
                }
            }
        }
        if (self.source_file_descriptors) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(CodeGeneratorRequestWire.SOURCE_FILE_DESCRIPTORS_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(CodeGeneratorRequestWire.SOURCE_FILE_DESCRIPTORS_WIRE, 0);
                }
            }
        }
        if (self.compiler_version) |v| {
            const size = v.calcProtobufSize();
            if (size > 0) {
                target.appendBytesTag(CodeGeneratorRequestWire.COMPILER_VERSION_WIRE, size);
                v.encodeTo(target);
            }
        }
    }
};

pub const CodeGeneratorRequestReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _file_to_generate: ?std.ArrayList([]const u8) = null,
    _parameter: ?[]const u8 = null,
    _proto_file_bufs: ?std.ArrayList([]const u8) = null,
    _source_file_descriptors_bufs: ?std.ArrayList([]const u8) = null,
    _compiler_version_buf: ?[]const u8 = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!CodeGeneratorRequestReader {
        var buf = gremlin.Reader.init(src);
        var res = CodeGeneratorRequestReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                CodeGeneratorRequestWire.FILE_TO_GENERATE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._file_to_generate == null) {
                        res._file_to_generate = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._file_to_generate.?.append(result.value);
                },
                CodeGeneratorRequestWire.PARAMETER_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._parameter = result.value;
                },
                CodeGeneratorRequestWire.PROTO_FILE_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._proto_file_bufs == null) {
                        res._proto_file_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._proto_file_bufs.?.append(result.value);
                },
                CodeGeneratorRequestWire.SOURCE_FILE_DESCRIPTORS_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    if (res._source_file_descriptors_bufs == null) {
                        res._source_file_descriptors_bufs = std.ArrayList([]const u8).init(allocator);
                    }
                    try res._source_file_descriptors_bufs.?.append(result.value);
                },
                CodeGeneratorRequestWire.COMPILER_VERSION_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._compiler_version_buf = result.value;
                },
                else => {
                    offset = try buf.skipData(offset, tag.wire);
                },
            }
        }
        return res;
    }
    pub fn deinit(self: *const CodeGeneratorRequestReader) void {
        if (self._file_to_generate) |arr| {
            arr.deinit();
        }
        if (self._proto_file_bufs) |arr| {
            arr.deinit();
        }
        if (self._source_file_descriptors_bufs) |arr| {
            arr.deinit();
        }
    }
    pub fn getFileToGenerate(self: *const CodeGeneratorRequestReader) []const []const u8 {
        if (self._file_to_generate) |arr| {
            return arr.items;
        }
        return &[_][]u8{};
    }
    pub inline fn getParameter(self: *const CodeGeneratorRequestReader) []const u8 {
        return self._parameter orelse &[_]u8{};
    }
    pub fn getProtoFile(self: *const CodeGeneratorRequestReader, allocator: std.mem.Allocator) gremlin.Error![]descriptor.FileDescriptorProtoReader {
        if (self._proto_file_bufs) |bufs| {
            var result = try std.ArrayList(descriptor.FileDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try descriptor.FileDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]descriptor.FileDescriptorProtoReader{};
    }
    pub fn getSourceFileDescriptors(self: *const CodeGeneratorRequestReader, allocator: std.mem.Allocator) gremlin.Error![]descriptor.FileDescriptorProtoReader {
        if (self._source_file_descriptors_bufs) |bufs| {
            var result = try std.ArrayList(descriptor.FileDescriptorProtoReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try descriptor.FileDescriptorProtoReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]descriptor.FileDescriptorProtoReader{};
    }
    pub fn getCompilerVersion(self: *const CodeGeneratorRequestReader, allocator: std.mem.Allocator) gremlin.Error!VersionReader {
        if (self._compiler_version_buf) |buf| {
            return try VersionReader.init(allocator, buf);
        }
        return try VersionReader.init(allocator, &[_]u8{});
    }
};

const CodeGeneratorResponseWire = struct {
    const ERROR_WIRE: gremlin.ProtoWireNumber = 1;
    const SUPPORTED_FEATURES_WIRE: gremlin.ProtoWireNumber = 2;
    const MINIMUM_EDITION_WIRE: gremlin.ProtoWireNumber = 3;
    const MAXIMUM_EDITION_WIRE: gremlin.ProtoWireNumber = 4;
    const FILE_WIRE: gremlin.ProtoWireNumber = 15;
};

pub const CodeGeneratorResponse = struct {
    // nested enums
    pub const Feature = enum(i32) {
        FEATURE_NONE = 0,
        FEATURE_PROTO3_OPTIONAL = 1,
        FEATURE_SUPPORTS_EDITIONS = 2,
    };

    // nested structs
    const FileWire = struct {
        const NAME_WIRE: gremlin.ProtoWireNumber = 1;
        const INSERTION_POINT_WIRE: gremlin.ProtoWireNumber = 2;
        const CONTENT_WIRE: gremlin.ProtoWireNumber = 15;
        const GENERATED_CODE_INFO_WIRE: gremlin.ProtoWireNumber = 16;
    };

    pub const File = struct {
        // fields
        name: ?[]const u8 = null,
        insertion_point: ?[]const u8 = null,
        content: ?[]const u8 = null,
        generated_code_info: ?descriptor.GeneratedCodeInfo = null,

        pub fn calcProtobufSize(self: *const File) usize {
            var res: usize = 0;
            if (self.name) |v| {
                if (v.len > 0) {
                    res += gremlin.sizes.sizeWireNumber(CodeGeneratorResponse.FileWire.NAME_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
                }
            }
            if (self.insertion_point) |v| {
                if (v.len > 0) {
                    res += gremlin.sizes.sizeWireNumber(CodeGeneratorResponse.FileWire.INSERTION_POINT_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
                }
            }
            if (self.content) |v| {
                if (v.len > 0) {
                    res += gremlin.sizes.sizeWireNumber(CodeGeneratorResponse.FileWire.CONTENT_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
                }
            }
            if (self.generated_code_info) |v| {
                const size = v.calcProtobufSize();
                if (size > 0) {
                    res += gremlin.sizes.sizeWireNumber(CodeGeneratorResponse.FileWire.GENERATED_CODE_INFO_WIRE) + gremlin.sizes.sizeUsize(size) + size;
                }
            }
            return res;
        }

        pub fn encode(self: *const File, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
            const size = self.calcProtobufSize();
            if (size == 0) {
                return &[_]u8{};
            }
            const buf = try allocator.alloc(u8, self.calcProtobufSize());
            var writer = gremlin.Writer.init(buf);
            self.encodeTo(&writer);
            return buf;
        }

        pub fn encodeTo(self: *const File, target: *gremlin.Writer) void {
            if (self.name) |v| {
                if (v.len > 0) {
                    target.appendBytes(CodeGeneratorResponse.FileWire.NAME_WIRE, v);
                }
            }
            if (self.insertion_point) |v| {
                if (v.len > 0) {
                    target.appendBytes(CodeGeneratorResponse.FileWire.INSERTION_POINT_WIRE, v);
                }
            }
            if (self.content) |v| {
                if (v.len > 0) {
                    target.appendBytes(CodeGeneratorResponse.FileWire.CONTENT_WIRE, v);
                }
            }
            if (self.generated_code_info) |v| {
                const size = v.calcProtobufSize();
                if (size > 0) {
                    target.appendBytesTag(CodeGeneratorResponse.FileWire.GENERATED_CODE_INFO_WIRE, size);
                    v.encodeTo(target);
                }
            }
        }
    };

    pub const FileReader = struct {
        _name: ?[]const u8 = null,
        _insertion_point: ?[]const u8 = null,
        _content: ?[]const u8 = null,
        _generated_code_info_buf: ?[]const u8 = null,

        pub fn init(_: std.mem.Allocator, src: []const u8) gremlin.Error!FileReader {
            var buf = gremlin.Reader.init(src);
            var res = FileReader{};
            if (buf.buf.len == 0) {
                return res;
            }
            var offset: usize = 0;
            while (buf.hasNext(offset, 0)) {
                const tag = try buf.readTagAt(offset);
                offset += tag.size;
                switch (tag.number) {
                    CodeGeneratorResponse.FileWire.NAME_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        res._name = result.value;
                    },
                    CodeGeneratorResponse.FileWire.INSERTION_POINT_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        res._insertion_point = result.value;
                    },
                    CodeGeneratorResponse.FileWire.CONTENT_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        res._content = result.value;
                    },
                    CodeGeneratorResponse.FileWire.GENERATED_CODE_INFO_WIRE => {
                        const result = try buf.readBytes(offset);
                        offset += result.size;
                        res._generated_code_info_buf = result.value;
                    },
                    else => {
                        offset = try buf.skipData(offset, tag.wire);
                    },
                }
            }
            return res;
        }
        pub fn deinit(_: *const FileReader) void {}

        pub inline fn getName(self: *const FileReader) []const u8 {
            return self._name orelse &[_]u8{};
        }
        pub inline fn getInsertionPoint(self: *const FileReader) []const u8 {
            return self._insertion_point orelse &[_]u8{};
        }
        pub inline fn getContent(self: *const FileReader) []const u8 {
            return self._content orelse &[_]u8{};
        }
        pub fn getGeneratedCodeInfo(self: *const FileReader, allocator: std.mem.Allocator) gremlin.Error!descriptor.GeneratedCodeInfoReader {
            if (self._generated_code_info_buf) |buf| {
                return try descriptor.GeneratedCodeInfoReader.init(allocator, buf);
            }
            return try descriptor.GeneratedCodeInfoReader.init(allocator, &[_]u8{});
        }
    };

    // fields
    error_: ?[]const u8 = null,
    supported_features: u64 = 0,
    minimum_edition: i32 = 0,
    maximum_edition: i32 = 0,
    file: ?[]const ?CodeGeneratorResponse.File = null,

    pub fn calcProtobufSize(self: *const CodeGeneratorResponse) usize {
        var res: usize = 0;
        if (self.error_) |v| {
            if (v.len > 0) {
                res += gremlin.sizes.sizeWireNumber(CodeGeneratorResponseWire.ERROR_WIRE) + gremlin.sizes.sizeUsize(v.len) + v.len;
            }
        }
        if (self.supported_features != 0) {
            res += gremlin.sizes.sizeWireNumber(CodeGeneratorResponseWire.SUPPORTED_FEATURES_WIRE) + gremlin.sizes.sizeU64(self.supported_features);
        }
        if (self.minimum_edition != 0) {
            res += gremlin.sizes.sizeWireNumber(CodeGeneratorResponseWire.MINIMUM_EDITION_WIRE) + gremlin.sizes.sizeI32(self.minimum_edition);
        }
        if (self.maximum_edition != 0) {
            res += gremlin.sizes.sizeWireNumber(CodeGeneratorResponseWire.MAXIMUM_EDITION_WIRE) + gremlin.sizes.sizeI32(self.maximum_edition);
        }
        if (self.file) |arr| {
            for (arr) |maybe_v| {
                res += gremlin.sizes.sizeWireNumber(CodeGeneratorResponseWire.FILE_WIRE);
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

    pub fn encode(self: *const CodeGeneratorResponse, allocator: std.mem.Allocator) gremlin.Error![]const u8 {
        const size = self.calcProtobufSize();
        if (size == 0) {
            return &[_]u8{};
        }
        const buf = try allocator.alloc(u8, self.calcProtobufSize());
        var writer = gremlin.Writer.init(buf);
        self.encodeTo(&writer);
        return buf;
    }

    pub fn encodeTo(self: *const CodeGeneratorResponse, target: *gremlin.Writer) void {
        if (self.error_) |v| {
            if (v.len > 0) {
                target.appendBytes(CodeGeneratorResponseWire.ERROR_WIRE, v);
            }
        }
        if (self.supported_features != 0) {
            target.appendUint64(CodeGeneratorResponseWire.SUPPORTED_FEATURES_WIRE, self.supported_features);
        }
        if (self.minimum_edition != 0) {
            target.appendInt32(CodeGeneratorResponseWire.MINIMUM_EDITION_WIRE, self.minimum_edition);
        }
        if (self.maximum_edition != 0) {
            target.appendInt32(CodeGeneratorResponseWire.MAXIMUM_EDITION_WIRE, self.maximum_edition);
        }
        if (self.file) |arr| {
            for (arr) |maybe_v| {
                if (maybe_v) |v| {
                    const size = v.calcProtobufSize();
                    target.appendBytesTag(CodeGeneratorResponseWire.FILE_WIRE, size);
                    v.encodeTo(target);
                } else {
                    target.appendBytesTag(CodeGeneratorResponseWire.FILE_WIRE, 0);
                }
            }
        }
    }
};

pub const CodeGeneratorResponseReader = struct {
    allocator: std.mem.Allocator,
    buf: gremlin.Reader,
    _error_: ?[]const u8 = null,
    _supported_features: u64 = 0,
    _minimum_edition: i32 = 0,
    _maximum_edition: i32 = 0,
    _file_bufs: ?std.ArrayList([]const u8) = null,

    pub fn init(allocator: std.mem.Allocator, src: []const u8) gremlin.Error!CodeGeneratorResponseReader {
        var buf = gremlin.Reader.init(src);
        var res = CodeGeneratorResponseReader{ .allocator = allocator, .buf = buf };
        if (buf.buf.len == 0) {
            return res;
        }
        var offset: usize = 0;
        while (buf.hasNext(offset, 0)) {
            const tag = try buf.readTagAt(offset);
            offset += tag.size;
            switch (tag.number) {
                CodeGeneratorResponseWire.ERROR_WIRE => {
                    const result = try buf.readBytes(offset);
                    offset += result.size;
                    res._error_ = result.value;
                },
                CodeGeneratorResponseWire.SUPPORTED_FEATURES_WIRE => {
                    const result = try buf.readUInt64(offset);
                    offset += result.size;
                    res._supported_features = result.value;
                },
                CodeGeneratorResponseWire.MINIMUM_EDITION_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._minimum_edition = result.value;
                },
                CodeGeneratorResponseWire.MAXIMUM_EDITION_WIRE => {
                    const result = try buf.readInt32(offset);
                    offset += result.size;
                    res._maximum_edition = result.value;
                },
                CodeGeneratorResponseWire.FILE_WIRE => {
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
    pub fn deinit(self: *const CodeGeneratorResponseReader) void {
        if (self._file_bufs) |arr| {
            arr.deinit();
        }
    }
    pub inline fn getError(self: *const CodeGeneratorResponseReader) []const u8 {
        return self._error_ orelse &[_]u8{};
    }
    pub inline fn getSupportedFeatures(self: *const CodeGeneratorResponseReader) u64 {
        return self._supported_features;
    }
    pub inline fn getMinimumEdition(self: *const CodeGeneratorResponseReader) i32 {
        return self._minimum_edition;
    }
    pub inline fn getMaximumEdition(self: *const CodeGeneratorResponseReader) i32 {
        return self._maximum_edition;
    }
    pub fn getFile(self: *const CodeGeneratorResponseReader, allocator: std.mem.Allocator) gremlin.Error![]CodeGeneratorResponse.FileReader {
        if (self._file_bufs) |bufs| {
            var result = try std.ArrayList(CodeGeneratorResponse.FileReader).initCapacity(allocator, bufs.items.len);
            for (bufs.items) |buf| {
                try result.append(try CodeGeneratorResponse.FileReader.init(allocator, buf));
            }
            return result.toOwnedSlice();
        }
        return &[_]CodeGeneratorResponse.FileReader{};
    }
};
