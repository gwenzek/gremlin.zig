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

    // don't bother deinit individual files
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

    if (desc._enum_type_bufs) |enums| {
        try res.enums.resize(enums.items.len);
        log.warn("Converting {} enums", .{enums.items.len});
        for (res.enums.items, enums.items) |*e, enum_desc_bytes| {
            const enum_desc = try descriptor.EnumDescriptorProtoReader.init(allocator, enum_desc_bytes);
            defer enum_desc.deinit();

            if (enum_desc._value_bufs == null) continue;

            log.warn("Converting enum {s}", .{enum_desc.getName()});
            e.* = .{
                .allocator = allocator,
                .const_name = enum_desc.getName(),
                .full_name = enum_desc.getName(),
                .entries = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
                .src = enum_desc_bytes.ptr,
            };
            try e.entries.resize(enum_desc._value_bufs.?.items.len);
            for (e.entries.items, enum_desc._value_bufs.?.items) |*enum_entry, entry_bytes| {
                const enum_value = try descriptor.EnumValueDescriptorProtoReader.init(allocator, entry_bytes);
                enum_entry.* = .{ .allocator = allocator, .constName = enum_value.getName(), .value = enum_value.getNumber() };
            }
        }
        log.warn("Converted {} enums", .{enums.items.len});
    }

    return res;
}
