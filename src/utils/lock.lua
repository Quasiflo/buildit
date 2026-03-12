--- Atomic lock module with command-line based waiting and inter-process health checking
local M = {}

local DEFAULT_TIMEOUT = 300
local DEFAULT_CHECK_INTERVAL = 2

local utils = require("src.utils.utils")
local file = require("file")
local json = require("json")
local log = require("log")

--- @param seconds number Number of seconds to sleep for
local function sleep(seconds)
    if RUNTIME.osType == "windows" then
        pcall(utils.exec, "timeout /t " .. seconds .. " /nobreak >nul")
    else
        pcall(utils.exec, "sleep " .. seconds)
    end
end

--- @param lock_dir string Path to lock
--- @return any -- Json lock data
local function read_lock_info(lock_dir)
    local info_path = file.join_path(lock_dir, "info")
    if not file.exists(info_path) then
        return nil
    end

    local handle = io.open(info_path, "r")
    if not handle then
        return nil
    end

    local content = handle:read("*a")
    handle:close()

    local success, data = pcall(json.decode, content)
    if success and data then
        return data
    end

    return nil
end

--- @param lock_dir string Lock directory
--- @param info table Lock info to save
local function write_lock_info(lock_dir, info)
    local info_path = file.join_path(lock_dir, "info")
    local handle = io.open(info_path, "w")
    if handle then
        handle:write(json.encode(info))
        handle:close()
        return true
    end
    return false
end

--- @param pid string Process ID to check
--- @return boolean -- Result
local function is_process_alive(pid)
    if not pid then
        return false
    end
    local success, result = pcall(utils.exec, "kill -0 " .. pid .. " 2>/dev/null")
    return success and result and not result.exit_code or false
end

--- @param lock_dir string Lock directory
local function cleanup_stale_lock(lock_dir)
    pcall(utils.exec, "rm -rf '" .. utils.quote(lock_dir) .. "'")
end

--- @param base_path string Directory for lock file
--- @return string -- Lockfile path
function M.lockfile_path(base_path)
    return file.join_path(base_path, ".lock")
end

--- @param lock_path string Path for requested lock
--- @param opts table Additional options
function M.acquire(lock_path, opts)
    opts = opts or {}
    local timeout = opts.timeout or DEFAULT_TIMEOUT
    local check_interval = opts.check_interval or DEFAULT_CHECK_INTERVAL

    local lock_dir = lock_path
    local start_time = os.time()
    local logged_wait = false

    while os.time() - start_time < timeout do
        local success_mkdir, mkdir_result = pcall(utils.exec, "mkdir -p " .. utils.quote(lock_dir) .. " 2>/dev/null")
        if success_mkdir and mkdir_result and not mkdir_result.exit_code then
            if logged_wait then
                log.debug("Lock acquired")
            end
            local success_pid, pid_result = pcall(utils.exec, "echo $PPID")
            local success_host, host_result = pcall(utils.exec, "hostname")
            local info = {
                pid = success_pid and pid_result and tonumber(pid_result:match("%d+")) or 0,
                timestamp = os.time(),
                hostname = success_host and host_result and host_result:gsub("%s+", "") or "",
            }
            if write_lock_info(lock_dir, info) then
                return
            else
                pcall(utils.exec, "rmdir " .. utils.quote(lock_dir))
            end
        end

        if not logged_wait then
            log.debug("Waiting for lock...")
            logged_wait = true
        end

        local info = read_lock_info(lock_dir)
        local is_stale = false

        if not info then
            -- If we can't get info, wait a bit and try again
            log.debug("Couldn't get lock info, retrying...")
            sleep(DEFAULT_CHECK_INTERVAL)
            info = read_lock_info(lock_dir)
            if not info then
                log.debug("Still couldn't get lock info, assuming stale")
                is_stale = true
            end
        end

        if not is_stale then
            is_stale = (is_process_alive((info and info.pid)) == false)
            if is_stale then
                log.debug("Lock owner is dead, PID: " .. (info and info.pid))
            else
                log.debug("Lock owner is still alive, PID: " .. (info and info.pid))
            end
        end

        if is_stale then
            log.debug("Cleaning stale lock: " .. lock_dir)
            cleanup_stale_lock(lock_dir)
            local success_mkdir2, mkdir_result2 = pcall(utils.exec, "mkdir -p " .. utils.quote(lock_dir) .. " 2>/dev/null")
            if success_mkdir2 and mkdir_result2 and not mkdir_result2.exit_code then
                log.debug("Stale lock cleaned up, acquired new lock")
                local success_pid2, pid_result2 = pcall(utils.exec, "echo $PPID")
                local success_host2, host_result2 = pcall(utils.exec, "hostname")
                local new_info = {
                    pid = success_pid2 and pid_result2 and tonumber(pid_result2:match("%d+")) or 0,
                    timestamp = os.time(),
                    hostname = success_host2 and host_result2 and host_result2:gsub("%s+", "") or "",
                }
                if write_lock_info(lock_dir, new_info) then
                    return
                else
                    pcall(utils.exec, "rmdir " .. utils.quote(lock_dir))
                end
            else
                log.debug("Failed to acquire new lock, retrying")
            end
        end

        sleep(check_interval)
    end

    error("Failed to acquire lock after " .. timeout .. " seconds: " .. lock_path)
end

--- @param lock_path string Path for requested lock
--- @return boolean -- True if success, false if lock isn't owned by you
function M.release(lock_path)
    local lock_dir = lock_path

    if not file.exists(lock_dir) then
        return true
    end

    local info = read_lock_info(lock_dir)
    local success_pid, pid_result = pcall(utils.exec, "echo $PPID")
    local current_pid = success_pid and pid_result and tonumber(pid_result:match("%d+")) or 0

    if info and info.pid ~= current_pid then
        return false
    end

    pcall(utils.exec, "rm -rf '" .. utils.quote(lock_dir) .. "'")
    return true
end

function M.is_locked(lock_path)
    return file.exists(lock_path)
end

function M.get_lock_info(lock_path)
    return read_lock_info(lock_path)
end

return M
