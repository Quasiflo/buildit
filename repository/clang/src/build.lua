--- Clang build logic
local M = {}

local log = require("log")
local file = require("file")
local cmake = require("repository.llvm.shared.cmake")
local lock = require("src.utils.lock")
local utils = require("src.utils.utils")
local prefs = require("src.utils.prefs")

---- @param build_path string Path to pre-extracted build folder
--- @param build_path string Path to source dir of entire llvm project
--- @param install_path string Desired install path
---- @param llvm_install_path string Path to installed llvm core
function M.build_tool(build_path, install_path)
    local build_cores = utils.get_parallel_cores()
    local opts = { cwd = build_path }
    local lockfile = lock.lockfile_path(build_path)
    local sequential = (prefs.build_sequentially == "true") or false
    local projects = (prefs.clang_extras == "true") and "clang;clang-tools-extra" or "clang"

    if sequential then
        lock.acquire(lockfile, { timeout = 300000 })
    end

    if file.exists(file.join_path(install_path, "bin")) then
        log.debug("Clang already built, skipping...")
        if sequential then
            lock.release(lockfile)
        end
        return
    end

    log.debug("Configuring Clang...")
    utils.exec(cmake.build_cmake_command(build_path, install_path, projects, ""), opts)

    log.debug("Compiling Clang (using " .. build_cores .. " parallel cores)...")
    utils.exec(cmake.build_compile_command(build_path, build_cores), opts)

    log.debug("Installing Clang...")
    utils.exec(cmake.build_install_command(build_path), opts)

    log.debug("Clang build complete")
    if sequential then
        lock.release(lockfile)
    end
end

return M
