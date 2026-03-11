--- Installs a specific version of a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx {tool: string, version: string, install_path: string, download_path: string} Context
--- @return table -- Empty table on success
function PLUGIN:BackendInstall(ctx)
    require("src.utils.prefs").init(ctx)
    local cmd = require("cmd")
    local mod = require("src.private.module")
    local util = require("src.private.util")

    --- @cast ctx ModuleInstallCtx
    ctx.download_path = util.get_downloads_path(ctx.install_path)
    ctx.build_path = util.get_builds_path(ctx.install_path)

    cmd.exec("mkdir -p " .. ctx.download_path)
    cmd.exec("mkdir -p " .. ctx.build_path)

    local module = mod.validate(ctx.tool, "install")
    mod.installDeps(module.dependencies(ctx))
    return module.ModuleInstall(ctx)
end
