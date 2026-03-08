--- Configuration loader for tool options from mise.toml
local M = {}

local log = require("log")

M.options = nil

--- @param ctx any The module requested
function M.init(ctx)
    if not M.options == nil then
        return -- Ensure we only initialise once
    end

    if ctx.options == nil then
        log.debug("No config options found")
        M.options = {}
    else
        log.debug("Config options loaded successfully")
        M.options = ctx.options
    end
end

return M
