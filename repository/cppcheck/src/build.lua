--- Cppcheck build logic
local M = {}

local cmd = require("cmd")
local log = require("log")
local file = require("file")
local lock = require("src.utils.lock")
local util = require("src.utils.util")
local prefs = require("src.utils.prefs")

--- @param build_path string Path to pre-extracted build folder
--- @param install_path string Desired install path
function M.build_core(build_path, install_path)
    local build_cores = util.get_parallel_cores()
    local cd_dir = "cd " .. build_path .. " && "
    local build_dir = file.join_path(build_path, "build")
    local lockfile = lock.lockfile_path(install_path)
    local gui_flag = (prefs.build_gui == "true") and " -DBUILD_GUI=ON" or " -DBUILD_GUI=OFF"

    lock.acquire(lockfile, { timeout = 300000 })

    if file.exists(file.join_path(install_path, "bin")) then
        log.debug("cppcheck already built, skipping...")
        lock.release(lockfile)
        return
    end

    cmd.exec("mkdir -p " .. build_dir)

    log.debug("Configuring cppcheck...")
    cmd.exec(
        cd_dir
            .. "cmake -S . -B "
            .. build_dir
            .. " -DCMAKE_BUILD_TYPE=Release -DUSE_MATCHCOMPILER=ON -DCMAKE_INSTALL_PREFIX="
            .. install_path
            .. gui_flag
    )

    log.debug("Compiling cppcheck (using " .. build_cores .. " parallel cores)...")
    cmd.exec(cd_dir .. "cmake --build " .. build_dir .. " --parallel " .. build_cores)

    log.debug("Installing cppcheck...")
    cmd.exec(cd_dir .. "cmake --install " .. build_dir)

    log.debug("cppcheck build complete")
    lock.release(lockfile)
end

return M
