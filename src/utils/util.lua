--- Common utility functions used across the plugin
local M = {}

local cmd = require("cmd")
local prefs = require("src.utils.prefs")
local log = require("log")

--- @param input string Input string to escape magics on
--- @return string -- Escaped gsub string
function M.escape_magic(input)
    return (input:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"))
end

--- @return string -- Number of cores to build with
function M.get_parallel_cores()
    if prefs.build_cores then
        return tostring(prefs.build_cores)
    end

    local cores_cmd = RUNTIME.osType == "linux" and "nproc" or "sysctl -n hw.ncpu"
    local cores_output = cmd.exec(cores_cmd)
    return cores_output:gsub("%s+", "")
end

--- @param dataTable table Table to be extracted from
--- @param func function Function to apply to each pair to extract desired element
--- @return table -- Table mapped by function
function M.mapTable(dataTable, func)
    local result = {}
    for key, value in pairs(dataTable) do
        table.insert(result, func(key, value))
    end
    return result
end

--- @param path string Path to check
--- @return boolean -- Whether or not it's empty
function M.is_dir_empty(path)
    local ok, _ = pcall(cmd.exec, "find '" .. path .. "' -maxdepth 1 -mindepth 1 ! -name '.lock' | grep -q .")

    if ok then
        return false
    else
        return true
    end
end

--- @param candidates string[] List of executables to search for, if any are available, returns true
--- @return string | nil -- First candidate found available or nil
function M.find_executable(candidates)
    for _, candidate in ipairs(candidates) do
        local success, path_result = pcall(cmd.exec, "which " .. candidate .. " 2>/dev/null")
        if success and path_result and not path_result.exit_code then
            return candidate
        end
    end

    return nil
end

return M
