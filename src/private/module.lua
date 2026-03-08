--- Utils for interacting with repository modules
local M = {}

local cmd = require("cmd")

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

--- @param dependencies string[] The required dependencies
function M.installDeps(dependencies)
    if dependencies == nil or next(dependencies) == nil then
        return
    end

    local parts = { "mise", "install" }
    for _, dep in ipairs(dependencies) do
        table.insert(parts, dep)
    end

    cmd.exec(table.concat(parts, " "))
end

return M
