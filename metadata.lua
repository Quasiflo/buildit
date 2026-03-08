-- metadata.lua
-- Backend plugin metadata and configuration
-- Documentation: https://mise.jdx.dev/backend-plugin-development.html

PLUGIN = { -- luacheck: ignore
    -- Required: Plugin name (will be the backend name users reference)
    name = "buildit",

    -- Required: Plugin version (not the tool versions)
    version = "0.1.0",

    -- Required: Brief description of the backend and tools it manages
    description = "A mise backend plugin for tools that need to be compiled locally from source to install",

    -- Required: Plugin author/maintainer
    author = "Quasiflo",

    -- Optional: Plugin homepage/repository URL
    homepage = "https://github.com/Quasiflo/buildit",

    -- Optional: Plugin license
    license = "MIT",

    -- Optional: Important notes for users
    notes = {
        -- "This plugin bridges the gap for many tools which have simple cmake or similar build processes that would otherwise need an asdf or full vfox backend to work with mise"
    },
}
