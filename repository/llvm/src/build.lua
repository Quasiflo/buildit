--- Core LLVM build logic
local M = {}

local cmd = require("cmd")
local log = require("log")
local file = require("file")
local cmake = require("repository.llvm.shared.cmake")
local lock = require("src.utils.lock")
local util = require("src.utils.util")

--- @param build_path string Path to pre-extracted build folder
--- @param install_path string Desired install path
function M.build_core(build_path, install_path)
    local build_cores = util.get_parallel_cores()
    local cd_dir = "cd " .. build_path .. " && "
    local lockfile = lock.lockfile_path(install_path)
    lock.acquire(lockfile, { timeout = 300000 })

    if file.exists(file.join_path(install_path, "bin")) then
        log.debug("Core LLVM already built, skipping...")
        lock.release(lockfile)
        return
    end

    log.debug("Configuring core LLVM...")
    cmd.exec(cd_dir .. cmake.build_cmake_command(build_path, install_path, "", ""))

    log.debug("Compiling core LLVM (using " .. build_cores .. " parallel cores)...")
    cmd.exec(cd_dir .. cmake.build_compile_command(build_path, build_cores))

    log.debug("Installing core LLVM...")
    cmd.exec(cd_dir .. cmake.build_install_command(build_path))

    log.debug("Core LLVM build complete")
    lock.release(lockfile)
end

return M
