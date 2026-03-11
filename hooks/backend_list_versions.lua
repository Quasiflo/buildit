--- Lists available versions for a tool in this backend
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendlistversions
--- @param ctx {tool: string} Context (tool = the tool name requested)
--- @return {versions: string[]} Table containing list of available versions
function PLUGIN:BackendListVersions(ctx)
    require("src.utils.prefs").init(ctx)
    local mod = require("src.private.module")

    local module = mod.validate(ctx.tool, "list_versions")
    mod.installDeps(module.dependencies(ctx))
    return module.ModuleListVersions(ctx)
end
