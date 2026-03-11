--- Version parsing and sorting utilities
--- @see https://mise.jdx.dev/cache-behavior.html for how mise caches remote versions
local M = {}

local semver = require("semver")

--- @param url string URL of the git repository
--- @param stripPrefix string | nil gsub compatible prefix to strip from tags, ie llvmorg%- to fix llvmorg-20.1.2
--- @return table<string, string> -- Unordered dictionary of [semver] = tag
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

            local original_tag = tag -- Preserve original before any modifications

            if stripPrefix ~= nil then
                tag = tag:gsub(stripPrefix, "")
            end

            -- Add .<patch> for semver sorting with versions in the form <major>.<minor>
            if tag:match("^%d+%.%d+$") then
                tag = tag .. ".0"
            end

            if not seen[tag] and tag:match("^%d+%.%d+%.%d+$") then
                seen[tag] = true
                versions[tag] = original_tag
            end
        end
    end

    if next(versions) == nil then
        error("No versions extracted from github tags")
    end

    return versions
end

--- @param dict table<string, string> Input dictionary to return sorted keys from
--- @return string[] -- Ordered list of semver keys
function M.order_tags_from_dict(dict)
    local keys = {}

    for k in pairs(dict) do
        table.insert(keys, k)
    end

    return semver.sort(keys)
end

return M
