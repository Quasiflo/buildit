local M = {}

--- @param ctx ModuleInstallCtx Context
--- @return string[] List of mise installable dependencies required to build this module
function M.dependencies(ctx)
    return {}
end

local versions = require("src.utils.versions")

--- @param ctx {tool: string} Context (tool = the tool name requested)
--- @return {versions: string[]} Table containing list of available versions
function M.ModuleListVersions(ctx)
    local tags = versions.fetch_git_tags("https://github.com/llvm/llvm-project", "llvmorg%-")
    local version_list = versions.order_tags_from_dict(tags)
    return { versions = version_list }
end

return M
