--- Installs a specific version of a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx {tool: string, version: string, install_path: string, download_path: string} Context
--- @return table -- Empty table on success
function PLUGIN:BackendInstall(ctx)
    require("src.utils.prefs").init(ctx)
    local mod = require("src.private.module")
    local util = require("src.private.util")
    local utils = require("src.utils.utils")

    --- @cast ctx ModuleInstallCtx
    ctx.download_path = util.get_downloads_path(ctx.install_path)
    ctx.build_path = util.get_builds_path(ctx.install_path)

    utils.exec("mkdir -p " .. utils.quote(ctx.download_path))
    utils.exec("mkdir -p " .. utils.quote(ctx.build_path))

    local module = mod.validate(ctx.tool, "install")
    local deps = module.dependencies(ctx)
    require("src.utils.utils").init_mise_deps(deps)
    mod.installDeps(deps)
    return module.ModuleInstall(ctx)
end
