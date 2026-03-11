--- Configuration loader for tool options from mise.toml
local M = {}

local log = require("log")

local init = false

--- @param ctx any The module requested
function M.init(ctx)
    if init then
        return -- Ensure we only initialise once
    end

    if ctx.options == nil then
        log.debug("No config options found")
    else
        log.debug("Config options loaded successfully")
        for k, v in pairs(ctx.options) do
            M[k] = v -- Merge values in
        end
    end

    init = true
end

return M
