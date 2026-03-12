--- Cppcheck build logic
local M = {}

local log = require("log")
local file = require("file")
local lock = require("src.utils.lock")
local utils = require("src.utils.utils")
local prefs = require("src.utils.prefs")

--- @param build_path string Path to pre-extracted build folder
--- @param install_path string Desired install path
function M.build_core(build_path, install_path)
    local build_cores = utils.get_parallel_cores()
    local build_dir = file.join_path(build_path, "build")
    local lockfile = lock.lockfile_path(install_path)
    local gui_flag = (prefs.build_gui == "true") and " -DBUILD_GUI=ON" or " -DBUILD_GUI=OFF"
    local opts = { cwd = build_path }

    lock.acquire(lockfile, { timeout = 300000 })

    if file.exists(file.join_path(install_path, "bin")) then
        log.debug("cppcheck already built, skipping...")
        lock.release(lockfile)
        return
    end

    utils.exec("mkdir -p " .. utils.quote(build_dir))

    log.debug("Configuring cppcheck...")
    utils.exec(
        "cmake -S . -B "
        .. utils.quote(build_dir)
        .. " -DCMAKE_BUILD_TYPE=Release -DUSE_MATCHCOMPILER=ON -DCMAKE_INSTALL_PREFIX="
        .. utils.quote(install_path)
        .. gui_flag,
        opts
    )

    log.debug("Compiling cppcheck (using " .. build_cores .. " parallel cores)...")
    utils.exec("cmake --build " .. utils.quote(build_dir) .. " --parallel " .. build_cores, opts)

    log.debug("Installing cppcheck...")
    utils.exec("cmake --install " .. utils.quote(build_dir), opts)

    log.debug("cppcheck build complete")
    lock.release(lockfile)
end

return M
