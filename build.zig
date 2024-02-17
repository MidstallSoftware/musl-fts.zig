const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(std.Build.Step.Compile.Linkage, "linkage", "whether to statically or dynamically link the library") orelse .static;

    const source = b.dependency("musl-fts", .{});

    const configHeader = b.addConfigHeader(.{
        .style = .blank,
        .include_path = "config.h",
    }, .{
        .HAVE_DECL_MAX = 1,
        .HAVE_DECL_UINTMAX_MAX = 1,
        .HAVE_DIRFD = 1,
    });

    const lib = std.Build.Step.Compile.create(b, .{
        .name = "fts",
        .root_module = .{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        },
        .kind = .lib,
        .linkage = linkage,
        .version = .{
            .major = 3,
            .minor = 38,
            .patch = 0,
        },
    });

    lib.addConfigHeader(configHeader);
    lib.addIncludePath(source.path("."));

    lib.addCSourceFile(.{
        .file = source.path("fts.c"),
    });

    {
        const install_file = b.addInstallFileWithDir(source.path("fts.h"), .header, "fts.h");
        b.getInstallStep().dependOn(&install_file.step);
        lib.installed_headers.append(&install_file.step) catch @panic("OOM");
    }

    b.installArtifact(lib);
}
