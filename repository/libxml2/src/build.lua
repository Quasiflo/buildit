local M = {}

local cmd = require("cmd")
local log = require("log")
local file = require("file")
local lock = require("src.utils.lock")
local util = require("src.utils.util")

--- @param build_path string Path to pre-extracted build folder
--- @param install_path string Desired install path
function M.build(build_path, install_path)
    local build_cores = util.get_parallel_cores()
    local cd_dir = "cd " .. build_path .. " && "
    local lockfile = lock.lockfile_path(install_path)

    lock.acquire(lockfile, { timeout = 300000 })

    if file.exists(file.join_path(install_path, "bin")) then
        log.debug("libxml2 already built, skipping...")
        lock.release(lockfile)
        return
    end

    log.debug("Configuring libxml2...")
    cmd.exec(
        cd_dir
        .. "./configure"
        .. " --prefix=" .. install_path ..
        " --without-python" ..
        " --without-debug" ..
        " --without-docbook"
    )

    log.debug("Compiling libxml2 (using " .. build_cores .. " parallel cores)...")
    cmd.exec(cd_dir .. "make -j" .. build_cores)

    log.debug("Installing libxml2...")
    cmd.exec(cd_dir .. "make install")

    log.debug("libxml2 build complete")
    lock.release(lockfile)
end

return M
