local M = {}

local download = require("src.utils.download")
local util = require("src.utils.util")
local build = require("repository.clang.src.build")

--- @param ctx ModuleInstallCtx Context
--- @return string[] List of mise installable dependencies required to build this module
function M.dependencies(ctx)
    return {
        "buildit:llvm@" .. ctx.version, -- Core of LLVM
        "cmake@latest",
        "ninja@latest",
        "python@latest", -- Required for generating certain files during build
    }
end

--- @param ctx ModuleInstallCtx Context
--- @return table -- Empty table on success
function M.ModuleInstall(ctx)
    if not util.find_executable({ "c++", "g++", "clang++", "icpc", "clang-c++" }) then
        error("You need a compatible c++ compiler to build llvm")
    end

    build.build_tool(ctx.build_path:gsub("clang", "llvm"), ctx.install_path)

    return {}
end

return M
