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

    local handle = io.popen(table.concat(parts, " ") .. " 2>&1")
    if handle then
        for line in handle:lines() do
            print(line)
        end
        local ok, reason, code = handle:close()
        if not ok then
            error(string.format("mise install failed (exit %d: %s)", code, reason))
        end
    end
end

return M
