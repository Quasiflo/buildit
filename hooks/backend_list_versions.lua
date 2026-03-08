--- Lists available versions for a tool in this backend
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendlistversions
--- @param ctx {tool: string} Context (tool = the tool name requested)
--- @return {versions: string[]} Table containing list of available versions
function PLUGIN:BackendListVersions(ctx)
    local mod = require("src.private.module")
    local prefs = require("src.private.prefs")
    prefs.init(ctx)

    local module = mod.validate(ctx.tool, "list_versions")
    mod.installDeps(module.dependencies)
    return module.ModuleListVersions(ctx, prefs.options)
end
