--- Configuration loader for tool options from mise.toml
local M = {}

local logger = require("src.utils.logger")

M.options = nil

function M.init(ctx)
    if not M.options == nil then
        return -- Ensure we only initialise once
    end

    if ctx.options == nil then
        logger.debug("No config options found")
        M.options = {}
    else
        logger.debug("Config options loaded successfully")
        M.options = ctx.options
    end
end

return M.options
