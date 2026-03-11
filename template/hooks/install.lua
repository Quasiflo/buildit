--- Installs a specific version of a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall

local M = {}

--- @param ctx ModuleInstallCtx Context
--- @return string[] List of mise installable dependencies required to build this module
function M.dependencies(ctx)
    return {}
end

--- @param ctx ModuleInstallCtx Context
--- @return table -- Empty table on success
function M.ModuleInstall(ctx)
    return {}
end

return M
