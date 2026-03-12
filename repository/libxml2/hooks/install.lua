local M = {}

local download = require("src.utils.download")
local util = require("src.utils.utils")
local semver = require("semver")
local log = require("log")
local build = require("repository.libxml2.src.build")

--- @param ctx ModuleInstallCtx Context
--- @return string[] List of mise installable dependencies required to build this module
function M.dependencies(ctx)
    return {
        "make@latest",
    }
end

--- @param ctx ModuleInstallCtx Context
--- @return table -- Empty table on success
function M.ModuleInstall(ctx)
    if not util.find_executable({ "cc", "cl" }) then
        error("You need a compatible c compiler to build libxml2")
    end

    local ver = semver.parse(ctx.version)
    local core_url = "https://download.gnome.org/sources/libxml2/" ..
    ver[1] .. "." .. ver[2] .. "/libxml2-" .. ctx.version
    local tarball_url = core_url .. ".tar.xz"

    local checksum_file = download.download_checksum_file(core_url .. ".sha256sum", tarball_url, ctx.download_path)

    local file = io.open(checksum_file, "r")
    if not file then
        error("Cannot open checksum file: " .. checksum_file)
    end
    local first_line = file:read("*l")
    file:close()
    local hash

    if first_line then
         hash = first_line:match("^(%x+)")
        if hash then
            log.debug("Checksum: " .. hash)
        else
            error("Failed to extract checksum from: " .. checksum_file)
        end
    else
        error("Checksum file is empty: " .. checksum_file)
    end

    local tarball =
        download.download_tarball(tarball_url, ctx.download_path, ctx.build_path, download.validators.ext_sha256(hash))
    download.extract_tarball(tarball, ctx.build_path, 1)

    build.build(ctx.build_path, ctx.install_path)

    return {}
end

return M
