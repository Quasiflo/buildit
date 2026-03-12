--- Core LLVM build logic
local M = {}

local log = require("log")
local file = require("file")
local cmake = require("repository.llvm.shared.cmake")
local lock = require("src.utils.lock")
local utils = require("src.utils.utils")

--- @param build_path string Path to pre-extracted build folder
--- @param install_path string Desired install path
function M.build_core(build_path, install_path)
    local build_cores = utils.get_parallel_cores()
    local opts = { cwd = build_path }
    local lockfile = lock.lockfile_path(install_path)
    lock.acquire(lockfile, { timeout = 300000 })

    if file.exists(file.join_path(install_path, "bin")) then
        log.debug("Core LLVM already built, skipping...")
        lock.release(lockfile)
        return
    end

    log.debug("Configuring core LLVM...")
    utils.exec(cmake.build_cmake_command(build_path, install_path, "", ""), opts)

    log.debug("Compiling core LLVM (using " .. build_cores .. " parallel cores)...")
    utils.exec(cmake.build_compile_command(build_path, build_cores), opts)

    log.debug("Installing core LLVM...")
    utils.exec(cmake.build_install_command(build_path), opts)

    log.debug("Core LLVM build complete")
    lock.release(lockfile)
end

return M
