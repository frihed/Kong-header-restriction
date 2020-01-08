local BasePlugin = require "kong.plugins.base_plugin"
local kong = kong
local HeaderRestrictionHandler = BasePlugin:extend()

HeaderRestrictionHandler.VERSION  = "1.0.0"
HeaderRestrictionHandler.PRIORITY = 2900

local function load_blockList(key)
    local item, err = kong.db.header_blockList:select_by_value(key)
    if not item then
      return nil, err
    end
    return item
end

local function is_block(header)  -- string type only
    local cache_key = kong.db.header_blockList:cache_key(header)
    local item, err = kong.cache:get(cache_key, nil, load_blockList, header)
    if err then
      kong.log.err(err)
      return kong.response.exit(500, "An unexpected error occurred")
    end

    return item
end

function HeaderRestrictionHandler:new()
    HeaderRestrictionHandler.super.new(self, "header-restriction")
end

function HeaderRestrictionHandler:access(config)
    HeaderRestrictionHandler.super.access(self)
    local header = ngx.req.get_headers()[config.header]

    if header and is_block(header) then
        return kong.response.exit(403, "Access denied")
    end
end

return HeaderRestrictionHandler
