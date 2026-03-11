--- CMake command builders
local M = {}

local file = require("file")
local prefs = require("src.utils.prefs")

function M.build_cmake_command(source_dir, install_path, projects, extra_flags)
    return "cmake -S "
        .. file.join_path(source_dir, "llvm")
        .. " -B "
        .. file.join_path(source_dir, "build")
        .. " -DCMAKE_INSTALL_PREFIX="
        .. install_path
        .. ' -DLLVM_ENABLE_PROJECTS="'
        .. projects
        .. '"'
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
    return "cmake --build " .. file.join_path(source_dir, "build") .. " --parallel " .. cores
end

function M.build_install_command(source_dir)
    return "cmake --install " .. file.join_path(source_dir, "build")
end

return M
