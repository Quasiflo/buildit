--- Sets up environment variables for a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendexecenv

local M = {}

--- @param ctx {install_path: string, tool: string, version: string} Context
--- @param prefs table<string, string> User configured plugin preferences
--- @return {env_vars: table[]} Table containing list of environment variable definitions
function M.ModuleExecEnv(ctx, prefs)
    return { env_vars = {} }
end

return M
