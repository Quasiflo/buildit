--- Sets up environment variables for a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendexecenv
--- @param ctx {install_path: string, tool: string, version: string} Context
--- @return {env_vars: table[]} Table containing list of environment variable definitions
function PLUGIN:BackendExecEnv(ctx)
    local mod = require("src.private.module")
    local prefs = require("src.private.prefs")
    prefs.init(ctx)

    local module = mod.validate(ctx.tool, "exec_env")
    mod.installDeps(module.dependencies)
    return module.ModuleExecEnv(ctx, prefs.options)
end
