const std = @import("std");
const pb = @import("gremlin");
const gremlin_gen = @import("gremlin_gen");
// const gremlin_parser = @import("gremlin_parser");
const plugin = @import("plugin.proto.zig");
const descriptor = @import("descriptor.proto.zig");

const log = std.log.scoped(.@"gremlin.zig");
const USE_MODULES = false;

const string = []const u8;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const stdin = std.io.getStdIn();

    // Read the contents (up to 10MB)
    const buffer_size = 1024 * 1024 * 10;
    const file_buffer = try stdin.readToEndAlloc(allocator, buffer_size);

    const request = try plugin.CodeGeneratorRequestReader.init(allocator, file_buffer);

    const num_proto_files = request._proto_file_bufs.?.items.len;
    var proto_files = try request.getProtoFile(allocator);

    // Create fake source proto file
    const fake_parsed = try allocator.alloc(gremlin_gen.ProtoFile, num_proto_files);
    defer allocator.free(fake_parsed);

    const files = try allocator.alloc(gremlin_gen.ZigFile, num_proto_files);

    defer {
        for (files) |*file| {
            file.deinit();
        }
        allocator.free(files);
    }

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

    const res: gremlin_gen.ZigFile = .{
        .out_path = out_path,
        .allocator = allocator,
        .imports = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
        .enums = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
        .structs = .{ .allocator = allocator, .items = &.{}, .capacity = 0 },
        .file = src_ptr,
    };

    return res;
}
