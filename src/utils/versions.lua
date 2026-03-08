--- Version parsing and sorting utilities
--- @see https://mise.jdx.dev/cache-behavior.html for how mise caches remote versions
local M = {}

local semver = require("semver")

--- @param url string URL of the git repository
--- @param stripPrefix string | nil gsub compatible prefix to strip from tags, ie llvmorg%- to fix llvmorg-20.1.2
--- @return string[] -- Ordered list of versions in semver
function M.fetch_git_tags(url, stripPrefix)
    local cmd = require("cmd")

    local result = cmd.exec("git ls-remote --tags " .. url)

    if not result then
        error("Failed to fetch versions")
    end

    local versions = {}
    local seen = {}

    for line in result:gmatch("[^\n]+") do
        local tag = line:match("\trefs/tags/(.+)")
        if tag then
            tag = tag:gsub("%^{}$", "") -- Strip peeled suffix

            if stripPrefix ~= nil then
                tag = tag:gsub(stripPrefix, "")
            end

            -- Add .<patch> for semver sorting with versions in the from <major>.<minor>
            if tag:match("^%d+%.%d+$") then
                tag = tag .. ".0"
            end

            if not seen[tag] and tag:match("^%d+%.%d+%.%d+$") then
                seen[tag] = true
                table.insert(versions, tag)
            end
        end
    end

    if #versions == 0 then
        error("No versions extracted from github tags")
    end

    return semver.sort(versions)
end

return M
