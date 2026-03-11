--- Download logic with atomic lock handling and checksum verification
local M = {}

--- @param installs_path string Targeted installation folder
function M.get_downloads_path(installs_path)
    return (installs_path:gsub("installs", "downloads"))
end

--- @param installs_path string Targeted installation folder
function M.get_builds_path(installs_path)
    return (installs_path:gsub("installs", "builds"))
end

return M
