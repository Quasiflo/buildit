--- Installs a specific version of a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx {tool: string, version: string, install_path: string, download_path: string} Context
--- @return table -- Empty table on success
function PLUGIN:BackendInstall(ctx)
    local mod = require("src.private.module")
    local prefs = require("src.private.prefs")
    prefs.init(ctx)

    local module = mod.validate(ctx.tool, "install")
    mod.installDeps(module.dependencies)
    return module.ModuleInstall(ctx, prefs.options)
end
