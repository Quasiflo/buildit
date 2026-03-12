local M = {}

local file = require("file")

--- @param ctx ModuleInstallCtx Context
--- @return string[] List of mise installable dependencies required to build this module
function M.dependencies(ctx)
    return {}
end

--- @param ctx {install_path: string, tool: string, version: string} Context
--- @return {env_vars: table[]} Table containing list of environment variable definitions
function M.ModuleExecEnv(ctx)
    local bin_path = file.join_path(ctx.install_path, "bin")
    local env_vars = {}

    if file.exists(bin_path) then
        env_vars = { --   Add tool's bin directory to PATH
            {
                key = "PATH",
                value = bin_path,
            },
        }
    end

    return {
        env_vars = env_vars,
    }
end

return M
