const std = @import("std");
const pb = @import("gremlin");
const gremlin_gen = @import("gremlin_gen");
const gremlin_parser = @import("gremlin_parser");
const plugin = @import("plugin.proto.zig");
const descriptor = @import("descriptor.proto.zig");

const log = std.log.scoped(.@"gremlin.zig");
const USE_MODULES = false;

const string = []const u8;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Read the contents (up to 10MB)
    const buffer_size = 1024 * 1024 * 10;

    const args = try std.process.argsAlloc(allocator);
    const stdin = if (args.len < 2) std.io.getStdIn() else try std.fs.cwd().openFile(args[1], .{});
    const file_buffer = try stdin.readToEndAlloc(allocator, buffer_size);

    {
        const dupe = try std.fs.cwd().createFile("/tmp/gremlin/request.pb", .{ .truncate = true });
        try dupe.writeAll(file_buffer);
    }

    const request = try plugin.CodeGeneratorRequestReader.init(allocator, file_buffer);

    const num_proto_files = request._proto_file_bufs.?.items.len;
    var proto_files = try request.getProtoFile(allocator);

    // Create fake source proto file
    const fake_parsed = try allocator.alloc(gremlin_gen.ProtoFile, num_proto_files);
    defer allocator.free(fake_parsed);

    const files = try allocator.alloc(gremlin_gen.ZigFile, num_proto_files);

    // don't deinit individual files, because we don't always follow the expected allocation scheme.
    defer allocator.free(files);

    // Initialize files
    for (files, proto_files, fake_parsed) |*file, desc, *p| {
        file.* = try readDescriptor(allocator, desc, p);
    }

    // Resolve imports between files
    for (files) |*file| {
        try file.resolveImports(files);
    }

    // Resolve internal references
    for (files) |*file| {
        try file.resolveRefs();
    }

    const num_out_files = request._file_to_generate.?.items.len;
    const out_files = try allocator.alloc(?plugin.CodeGeneratorResponse.File, num_out_files);
    defer allocator.free(out_files);
    for (out_files, request.getFileToGenerate()) |*o, req| {
        const j = blk: {
            for (0..num_proto_files) |i| {
                const j = num_proto_files - 1 - i;
                if (std.mem.eql(u8, proto_files[j].getName(), req)) break :blk j;
            }
            log.err("Requested output file not found in input proto files: {s}", .{req});
            break;
        };

        var content = std.ArrayList(u8).init(allocator);
        {
            var file_output = gremlin_gen.FileOutput{
                .allocator = allocator,
                .depth = 0,
                .buf_writer = std.io.bufferedWriter(content.writer().any()),
                .file = undefined,
            };
            try files[j].write(&file_output);
            try file_output.buf_writer.flush();
        }
        o.* = .{
            .name = try std.mem.join(allocator, "", &.{ req, ".zig" }),
            .content = content.items,
        };
    }

    const res: plugin.CodeGeneratorResponse = .{ .file = out_files };
    const stdout = std.io.getStdOut();
    {
        const res_bytes = try res.encode(allocator);
        defer allocator.free(res_bytes);
        try stdout.writeAll(res_bytes);
    }
}

const std_import: gremlin_gen.ZigImport = .{
    .allocator = undefined,
    .alias = "std",
    .path = "std",
    .src = null,
    .target = null,
    .is_system = true,
};

const gremlin_import: gremlin_gen.ZigImport = .{
    .allocator = undefined,
    .alias = "gremlin",
    .path = "gremlin",
    .src = null,
    .target = null,
    .is_system = true,
};

fn readDescriptor(
    allocator: std.mem.Allocator,
    desc: descriptor.FileDescriptorProtoReader,
    src_ptr: *const gremlin_gen.ProtoFile,
) !gremlin_gen.ZigFile {
    const out_path = try std.mem.join(allocator, "", &.{ desc.getName(), ".zig" });
    defer allocator.free(out_path);

    var res: gremlin_gen.ZigFile = .{
        .out_path = out_path,
        .allocator = allocator,
        .imports = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
        .enums = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
        .structs = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
        .file = src_ptr,
    };

    try res.imports.resize(2);
    res.imports.items[0] = gremlin_import;
    res.imports.items[1] = std_import;
    for (res.imports.items) |*i| i.allocator = allocator;

    if (desc._enum_type_bufs) |enums| {
        try res.enums.resize(enums.items.len);
        log.warn("Converting {} enums", .{enums.items.len});
        for (res.enums.items, enums.items) |*e, enum_desc_bytes| {
            e.* = try parseEnum(allocator, enum_desc_bytes);
        }
        log.warn("Converted {} enums", .{enums.items.len});
    }

    if (desc._message_type_bufs) |structs| {
        try res.structs.resize(structs.items.len);
        log.warn("Converting {} structs", .{structs.items.len});
        for (res.structs.items, structs.items) |*s, struct_desc_bytes| {
            s.* = try parseStruct(allocator, struct_desc_bytes);
        }
        log.warn("Converted {} structs", .{structs.items.len});
    }

    return res;
}

fn parseEnum(
    allocator: std.mem.Allocator,
    enum_desc_bytes: []const u8,
) !gremlin_gen.ZigEnum {
    const enum_desc = try descriptor.EnumDescriptorProtoReader.init(allocator, enum_desc_bytes);
    defer enum_desc.deinit();

    log.warn("Converting enum {s}", .{enum_desc.getName()});

    const n_entries = if (enum_desc._value_bufs) |values| values.items.len else 0;
    const entries = try allocator.alloc(gremlin_gen.ZigEnumEntry, n_entries);
    for (entries, enum_desc._value_bufs.?.items) |*enum_entry, entry_bytes| {
        const enum_value = try descriptor.EnumValueDescriptorProtoReader.init(allocator, entry_bytes);
        enum_entry.* = .{ .allocator = allocator, .constName = enum_value.getName(), .value = enum_value.getNumber() };
    }
    return .{
        .allocator = allocator,
        .const_name = enum_desc.getName(),
        .full_name = enum_desc.getName(),
        .src = enum_desc_bytes.ptr,
        .entries = .{ .allocator = allocator, .items = entries, .capacity = n_entries },
    };
}

fn parseStruct(
    allocator: std.mem.Allocator,
    struct_desc_bytes: []const u8,
) !gremlin_gen.ZigStruct {
    const struct_desc = try descriptor.DescriptorProtoReader.init(allocator, struct_desc_bytes);
    defer struct_desc.deinit();

    log.warn("Converting struct {s}", .{struct_desc.getName()});
    const name = struct_desc.getName();

    var res: gremlin_gen.ZigStruct = .{
        .allocator = allocator,
        .writer_name = name,
        .full_writer_name = name,
        .wire_enum_name = try std.mem.join(allocator, "", &.{ name, "Wire" }),
        .full_wire_name = try std.mem.join(allocator, "", &.{ name, "Wire" }),
        .reader_name = try std.mem.join(allocator, "", &.{ name, "Reader" }),
        .full_reader_name = try std.mem.join(allocator, "", &.{ name, "Reader" }),

        .enums = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
        .structs = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
        .fields = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
        .source = struct_desc_bytes.ptr,
    };

    if (struct_desc._enum_type_bufs) |enums| {
        try res.enums.resize(enums.items.len);
        log.warn("Converting nested {} enums", .{enums.items.len});
        for (res.enums.items, enums.items) |*e, enum_desc_bytes| {
            e.* = try parseEnum(allocator, enum_desc_bytes);
        }
        log.warn("Converted nested {} enums", .{enums.items.len});
    }

    if (struct_desc._field_bufs) |fields| {
        try res.fields.resize(fields.items.len);
        log.warn("Converting nested {} fields", .{fields.items.len});
        for (res.fields.items, fields.items) |*f, field_desc_bytes| {
            f.* = try parseField(allocator, name, res.reader_name, field_desc_bytes);
        }
        log.warn("Converted nested {} fields", .{fields.items.len});
    }

    return res;
}

fn parseField(
    allocator: std.mem.Allocator,
    struct_name: []const u8,
    reader_struct_name: []const u8,
    field_desc_bytes: []const u8,
) !gremlin_gen.ZigField {
    const field_desc = try descriptor.FieldDescriptorProtoReader.init(allocator, field_desc_bytes);
    defer field_desc.deinit();

    var type_name = field_desc.getTypeName();
    if (type_name.len > 0 and type_name[0] == '.') {
        type_name = type_name[1..];
    }
    log.warn("Converting field '{s}' ({s}, {s})", .{ field_desc.getName(), @tagName(field_desc.getType()), type_name });
    const str_type = switch (field_desc.getType()) {
        .TYPE_DOUBLE => "double",
        .TYPE_FLOAT => "float",
        .TYPE_INT64 => "int64",
        .TYPE_UINT64 => "uint64",
        .TYPE_INT32 => "int32",
        .TYPE_FIXED64 => "fixed64",
        .TYPE_FIXED32 => "fixed32",
        .TYPE_BOOL => "bool",
        .TYPE_STRING => "string",
        .TYPE_MESSAGE => "message",
        .TYPE_BYTES => "bytes",
        .TYPE_UINT32 => "uint32",
        .TYPE_ENUM => "enum",
        .TYPE_SFIXED32 => "sfixed32",
        .TYPE_SFIXED64 => "sfixed64",
        .TYPE_SINT32 => "sint32",
        .TYPE_SINT64 => "sint64",
        inline else => |t| "unknown_" ++ @tagName(t),
    };
    // existing names to avoid conflicts
    var names = std.ArrayList([]const u8).init(allocator);
    defer names.deinit();

    // TODO: handle repeated fields
    return switch (field_desc.getType()) {
        .TYPE_GROUP, ._PROTOBUF_UNKNOWN => @panic("unknown protobuf type"),
        .TYPE_BOOL,
        .TYPE_FLOAT,
        .TYPE_INT64,
        .TYPE_UINT64,
        .TYPE_INT32,
        .TYPE_FIXED64,
        .TYPE_FIXED32,
        .TYPE_UINT32,
        .TYPE_SFIXED32,
        .TYPE_SFIXED64,
        .TYPE_SINT32,
        .TYPE_SINT64,
        .TYPE_DOUBLE,
        => .{
            .scalar = try gremlin_gen.field_types.ZigScalarField.init(
                allocator,
                field_desc.getName(),
                str_type,
                null,
                field_desc.getNumber(),
                "", // wire_prefix,
                &names,
                struct_name,
                reader_struct_name,
            ),
        },
        .TYPE_STRING, .TYPE_BYTES => .{
            .bytes = try gremlin_gen.field_types.ZigBytesField.init(
                allocator,
                field_desc.getName(),
                null,
                field_desc.getNumber(),
                "", // wire_prefix,
                &names,
                struct_name,
                reader_struct_name,
            ),
        },
        .TYPE_MESSAGE => {
            var message_field = try gremlin_gen.field_types.ZigMessageField.init(
                allocator,
                field_desc.getName(),
                .{
                    .allocator = allocator,
                    .src = type_name,
                    .name = null,
                    .is_scalar = false,
                    .is_bytes = false,
                    .scope = try gremlin_parser.ScopedName.init(allocator, type_name),
                },
                field_desc.getNumber(),
                "", // wire_prefix
                &names,
                struct_name,
                reader_struct_name,
            );
            try message_field.resolve(type_name, try std.mem.join(allocator, "", &.{ type_name, "Writer" }));
            return .{ .message = message_field };
        },
        .TYPE_ENUM => {
            var enum_field = try gremlin_gen.field_types.ZigEnumField.init(
                allocator,
                field_desc.getName(),
                .{
                    .allocator = allocator,
                    .src = type_name,
                    .name = null,
                    .is_scalar = false,
                    .is_bytes = false,
                    .scope = try gremlin_parser.ScopedName.init(allocator, type_name),
                },
                null,
                field_desc.getNumber(),
                "", // wire_prefix
                &names,
                struct_name,
                reader_struct_name,
            );
            try enum_field.resolve(type_name);
            return .{ .enumeration = enum_field };
        },
    };
}
