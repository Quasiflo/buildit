--- Common utility functions used across the plugin
-- TODO refactor to allow repository modules to use utils, logger etc
local M = {}

local cmd = require("cmd")
local prefs = require("src.private.prefs")

function M.escape_magic(s)
    return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"))
end

function M.get_builds_path(download_path)
    return (download_path:gsub("downloads", "builds"))
end

function M.get_parallel_cores()
    if prefs.options.build_cores then
        return tostring(prefs.options.build_cores)
    end

    local cores_cmd = RUNTIME.osType == "linux" and "nproc" or "sysctl -n hw.ncpu"
    local cores_output = cmd.exec(cores_cmd)
    return cores_output:gsub("%s+", "")
end

return M
