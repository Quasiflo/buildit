--- Installs a specific version of a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx {tool: string, version: string, install_path: string, download_path: string} Context
--- @return table Empty table on success
function PLUGIN:BackendInstall(ctx)
    local prefs = require("src.utils.prefs")

    prefs.init(ctx)

    return {}
end
