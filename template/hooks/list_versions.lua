--- Lists available versions for a tool in this backend
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendlistversions

local M = {}

--- @param ctx {tool: string} Context (tool = the tool name requested)
--- @param prefs table<string, string> User configured plugin preferences
--- @return {versions: string[]} Table containing list of available versions
function M.ModuleListVersions(ctx, prefs)
    return { versions = {} }
end

return M
