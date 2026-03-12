local M = {}

local download = require("src.utils.download")
local util = require("src.utils.utils")
local versions = require("src.utils.versions")
local prefs = require("src.utils.prefs")
local build = require("repository.cppcheck.src.build")

--- @param ctx ModuleInstallCtx Context
--- @return string[] List of mise installable dependencies required to build this module
function M.dependencies(ctx)
    return {
        "cmake@latest",
        "python@latest",
    }
end

--- @param ctx ModuleInstallCtx Context
--- @return table -- Empty table on success
function M.ModuleInstall(ctx)
    if not util.find_executable({ "c++", "g++", "clang++", "icpc", "clang-c++" }) then
        error("You need a compatible c++ compiler to build cppcheck")
    end
    if (prefs.build_gui == "true") and not util.find_executable({ "qmake" }) then
        error("You QT to build cppcheck GUI")
    end

    local originalTag = versions.fetch_git_tags("https://github.com/danmar/cppcheck")[ctx.version]
    local tarball_url = "https://github.com/danmar/cppcheck/archive/refs/tags/" .. originalTag .. ".tar.gz"

    local tarball =
        download.download_tarball(tarball_url, ctx.download_path, ctx.build_path, download.validators.cached_sha256())
    download.extract_tarball(tarball, ctx.build_path, 1)

    build.build_core(ctx.build_path, ctx.install_path)

    return {}
end

return M
