local M = {}

local download = require("src.utils.download")
local util = require("src.utils.util")
local build = require("repository.llvm.src.build")

--- @param ctx ModuleInstallCtx Context
--- @return string[] List of mise installable dependencies required to build this module
function M.dependencies(ctx)
    return {
        "gh@latest", -- Used for verifying integrity
        "cmake@latest",
        "ninja@latest",
        "python@latest", -- Required for generating certain files during build
    }
end

--- @param ctx ModuleInstallCtx Context
--- @return table -- Empty table on success
function M.ModuleInstall(ctx)
    if not util.find_executable({ "c++", "g++", "clang++", "icpc", "clang-c++" }) then
        error("You need a compatible c++ compiler to build llvm")
    end

    local tarball_url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-"
        .. ctx.version
        .. "/llvm-project-"
        .. ctx.version
        .. ".src.tar.xz"
    local integrity_url = tarball_url .. ".jsonl"

    local checksumFile = download.download_checksum_file(integrity_url, tarball_url, ctx.download_path)
    local tarball = download.download_tarball(
        tarball_url,
        ctx.download_path,
        ctx.build_path,
        download.validators.jsonl(checksumFile, "llvm/llvm-project")
    )
    download.extract_tarball(tarball, ctx.build_path, 1)

    build.build_core(ctx.build_path, ctx.install_path)

    return {}
end

return M
