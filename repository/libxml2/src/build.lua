local M = {}

local log = require("log")
local file = require("file")
local lock = require("src.utils.lock")
local utils = require("src.utils.utils")

--- @param build_path string Path to pre-extracted build folder
--- @param install_path string Desired install path
function M.build(build_path, install_path)
    local build_cores = utils.get_parallel_cores()
    local opts = { cwd = build_path }
    local lockfile = lock.lockfile_path(install_path)

    lock.acquire(lockfile, { timeout = 300000 })

    if file.exists(file.join_path(install_path, "bin")) then
        log.debug("libxml2 already built, skipping...")
        lock.release(lockfile)
        return
    end

    log.debug("Configuring libxml2...")
    utils.exec(
        "./configure"
        .. " --prefix=" .. utils.quote(install_path) ..
        " --without-python" ..
        " --without-debug" ..
        " --without-docbook",
        opts
    )

    log.debug("Compiling libxml2 (using " .. build_cores .. " parallel cores)...")
    utils.exec("make -j" .. build_cores, opts)

    log.debug("Installing libxml2...")
    utils.exec("make install", opts)

    log.debug("libxml2 build complete")
    lock.release(lockfile)
end

return M
