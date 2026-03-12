--- CMake command builders
local M = {}

local file = require("file")
local prefs = require("src.utils.prefs")
local utils = require("src.utils.utils")

local function get_build(source_dir) return utils.quote(file.join_path(source_dir, "build")) end

function M.build_cmake_command(source_dir, install_path, projects, extra_flags)
    return "cmake -S "
        .. utils.quote(file.join_path(source_dir, "llvm"))
        .. " -B "
        .. get_build(source_dir)
        .. " -DCMAKE_INSTALL_PREFIX="
        .. utils.quote(install_path)
        .. " -DLLVM_ENABLE_PROJECTS="
        .. utils.quote(projects)
        .. (((prefs.toolchain_only == nil) or (prefs.toolchain_only == "true")) and " -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON" or " -DLLVM_INSTALL_TOOLCHAIN_ONLY=OFF")
        .. " -DCMAKE_BUILD_TYPE=Release"
        .. " -DLLVM_INSTALL_UTILS=ON"
        .. " -DLLVM_INCLUDE_EXAMPLES=OFF"
        .. " -DLLVM_BUILD_EXAMPLES=OFF"
        .. " -DLLVM_INCLUDE_TESTS=OFF"
        .. " -DLLVM_BUILD_TESTS=OFF"
        .. " -DLLVM_INCLUDE_BENCHMARKS=OFF"
        .. " -DLLVM_BUILD_BENCHMARKS=OFF"
        .. ""
        .. extra_flags
end

function M.build_compile_command(source_dir, cores)
    return "cmake --build " .. get_build(source_dir) .. " --parallel " .. cores
end

function M.build_install_command(source_dir)
    return "cmake --install " .. get_build(source_dir)
end

return M
