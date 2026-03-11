--- Download logic with atomic lock handling and checksum verification
local M = {}
M.validators = {}

local cmd = require("cmd")
local log = require("log")
local file = require("file")
local util = require("src.utils.util")
local lock = require("src.utils.lock")
local checksum = require("src.utils.checksum")

local function dl_name(url)
    return url:match("([^/]+)$") -- Use last segment as tarball name
end

local function dl_path(url, download_path)
    return file.join_path(download_path, dl_name(url))
end

-- Each validator is a table implementing this "interface":
-- {
--   get_reference(tarball_path) -> ref | nil   (what to compare against)
--   verify(tarball_path, ref)   -> bool        (the actual check)
--   known_good(tarball_path)    -> nil         (post-download hook on known good file)
--   on_invalid(tarball_path)    -> nil         (cleanup hook)
-- }

-- No validation (passthrough)
M.validators.none = function()
    return {
        get_reference = function(_)
            return true
        end, -- always has a "ref"
        verify = function(_, _)
            return true
        end,
        known_good = function(_) end,
        on_invalid = function(_) end,
    }
end

-- SHA256 with external checksum (provided by caller)
M.validators.ext_sha256 = function(ext_checksum)
    return {
        get_reference = function(_)
            return true
        end,
        verify = function(tarball_path, _)
            return checksum.verify_sha256(tarball_path, ext_checksum)
        end,
        known_good = function(_) end,
        on_invalid = function(tarball_path)
            cmd.exec("rm -f " .. tarball_path)
        end,
    }
end

-- SHA256 with local caching
M.validators.cached_sha256 = function()
    return {
        get_reference = function(tarball_path)
            return checksum.get_cached_sha256(tarball_path)
        end,
        verify = function(tarball_path, ref)
            return checksum.verify_sha256(tarball_path, ref)
        end,
        known_good = function(tarball_path)
            checksum.save_sha256(tarball_path)
        end,
        on_invalid = function(tarball_path)
            cmd.exec("rm -f " .. tarball_path)
            cmd.exec("rm -f " .. checksum.get_integrity_path(tarball_path))
        end,
    }
end

-- JSONL-based verification
M.validators.jsonl = function(jsonl_path, repo)
    return {
        get_reference = function(_)
            return true
        end,
        verify = function(tarball_path, _)
            return checksum.verify_jsonl(tarball_path, jsonl_path, repo)
        end,
        known_good = function(_) end,
        on_invalid = function(tarball_path)
            cmd.exec("rm -f " .. tarball_path)
            cmd.exec("rm -f " .. jsonl_path)
        end,
    }
end

--- @param url string
--- @param download_path string Path to download into
--- @param validator table Validator interface (see M.validators)
--- @return string -- Downloaded tarball path
function M.download_tarball(url, download_path, build_path, validator)
    local tarball_name = dl_name(url)
    local tarball_path = dl_path(url, download_path)
    local lock_path = lock.lockfile_path(download_path)

    lock.acquire(lock_path, { timeout = 300000 })

    if not util.is_dir_empty(build_path) then
        log.debug("Source already available, skipping download...")
        return tarball_path
    end

    if file.exists(tarball_path) then
        local ref = validator.get_reference(tarball_path)

        if ref then
            local valid = validator.verify(tarball_path, ref)

            if not valid then
                log.warn("Checksum invalid, re-downloading...")
                validator.on_invalid(tarball_path)
            else
                log.debug("Source tarball already downloaded and verified")
                lock.release(lock_path)
                return tarball_path
            end
        else
            log.debug("No reference found for tarball, re-downloading...")
        end
    end

    log.debug("Downloading " .. url)
    cmd.exec("curl -L --fail -o " .. tarball_path .. " " .. url)
    validator.known_good(tarball_path)
    log.debug("Downloaded " .. tarball_name)
    lock.release(lock_path)
    return tarball_path
end

--- @param url string Url to checksum file
--- @param tarball_url string Tarball download url
--- @param tarball_download_path string Tarball download path
--- @return string -- Downloaded checksum path
function M.download_checksum_file(url, tarball_url, tarball_download_path)
    local integrity_file = checksum.get_integrity_path(dl_path(tarball_url, tarball_download_path))
    local lock_path = lock.lockfile_path(tarball_download_path)

    lock.acquire(lock_path, { timeout = 30000 })
    if not file.exists(integrity_file) then
        cmd.exec("curl -L --fail -o " .. integrity_file .. " " .. url)
    else
        log.warn("Integrity file already exists")
    end
    lock.release(lock_path)

    return integrity_file
end

--- @param tarball_path string Path to tarball
--- @param build_path string Folder to extract into
--- @param strip_levels number Number of leading components to strip
function M.extract_tarball(tarball_path, build_path, strip_levels)
    local lock_path = lock.lockfile_path(build_path)

    lock.acquire(lock_path, { timeout = 300000 })

    if util.is_dir_empty(build_path) then
        local strip_cmd = "tar -xJf " .. tarball_path .. " -C " .. build_path .. " --strip-components=" .. strip_levels
        log.debug("Extracting source with: " .. strip_cmd)
        cmd.exec(strip_cmd)
        log.debug("Extracted source")
    else
        log.debug("Source already extracted")
    end

    lock.release(lock_path)
end

return M
