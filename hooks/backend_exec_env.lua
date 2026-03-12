--- Sets up environment variables for a tool
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendexecenv
--- @param ctx {install_path: string, tool: string, version: string} Context
--- @return {env_vars: table[]} Table containing list of environment variable definitions
function PLUGIN:BackendExecEnv(ctx)
    require("src.utils.prefs").init(ctx)
    local mod = require("src.private.module")

    local module = mod.validate(ctx.tool, "exec_env")
    local deps = module.dependencies(ctx)
    require("src.utils.utils").init_mise_deps(deps)
    mod.installDeps(deps)
    return module.ModuleExecEnv(ctx)
end
