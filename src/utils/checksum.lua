--- Checksum verification module for downloaded tarballs
local M = {}

local cmd = require("cmd")
local file = require("file")

--- @param tarball_path string Path to tarball to compute checksum of
local function compute_sha256(tarball_path)
    local result = cmd.exec("sha256sum " .. tarball_path)
    if not result then
        error("Failed to compute SHA256 for " .. tarball_path)
    end
    local sha256 = result:match("^([a-fA-F0-9]+)")
    if not sha256 then
        error("Failed to parse SHA256 from output: " .. result)
    end
    return sha256
end

--- @param tarball_path string Path to tarball to get checksum of
function M.get_integrity_path(tarball_path)
    return tarball_path .. ".integrity"
end

--- @param tarball_path string Path to tarball to save checksum for
--- @return string -- Calculated checksum
function M.save_sha256(tarball_path)
    local checksum_path = M.get_integrity_path(tarball_path)
    local checksum = compute_sha256(tarball_path)
    local f = io.open(checksum_path, "w")
    if not f then
        error("Failed to write checksum file: " .. checksum_path)
    end
    f:write(checksum)
    f:close()
    return checksum
end

--- @param tarball_path string Path to tarball to get checksum of
function M.get_cached_sha256(tarball_path)
    local checksum_path = M.get_integrity_path(tarball_path)
    if file.exists(checksum_path) then
        local f = io.open(checksum_path, "r")
        if f then
            local sha256 = f:read("*a"):match("^([a-fA-F0-9]+)")
            f:close()
            return sha256
        end
    end
    return nil
end

--- @param tarball_path string Path to tarball to verify checksum for
--- @param checksum string Checksum to validate against
function M.verify_sha256(tarball_path, checksum)
    local computed = compute_sha256(tarball_path)
    if computed == checksum then
        return true
    else
        return false
    end
end

--- @param tarball_path string Path to tarball to verify checksum for
--- @param jsonl_path string jsonl signature file to verify against
--- @param repo string github repo to verify against, ie llvm/llvm-project
--- !WARNING this function requires the `gh` cmd line tool!
function M.verify_jsonl(tarball_path, jsonl_path, repo)
    local command = "gh attestation verify --repo " .. repo .. " " .. tarball_path .. " --bundle " .. jsonl_path

    local success, path_result = pcall(cmd.exec, command)
    if success and path_result and not path_result.exit_code then
        return true
    else
        return false
    end
end

return M
