--- Installs a specific version of a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall

local M = {}

--- @type string[] List of mise installable dependencies required to build this module
M.dependencies = {
    -- "cmake@latest" -- for example
}

--- @param ctx {tool: string, version: string, install_path: string, download_path: string} Context
--- @param prefs table<string, string> User configured plugin preferences
--- @return table -- Empty table on success
function M.ModuleInstall(ctx, prefs)
    return {}
end

return M
