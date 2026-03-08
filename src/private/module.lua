--- Utils for interacting with repository modules
local M = {}

local file = require("file")

--- @param module string The module requested
--- @param hook string The name of the hook file for the task
--- @return unknown
--- @return unknown loaderdata
function M.validate(module, hook)
    local filepath = "repository." .. module .. ".hooks." .. hook

    if not module or module == "" then
        error("Tool name cannot be empty")
    end

    return require(filepath)
end

return M
