local cache_warmup = require "kong.cache_warmup"
local BasePlugin = require "kong.plugins.base_plugin"
local kong = kong
local HeaderRestrictionHandler = BasePlugin:extend()

HeaderRestrictionHandler.VERSION  = "1.0.0"
HeaderRestrictionHandler.PRIORITY = 2900

local function get_cache(key)
    local cache_key = kong.db.header_blockList:cache_key(key)
    return kong.cache:probe(cache_key)
end

local function is_block(header)
    local ttl, err, value = get_cache(header)  -- ttl is nil
    if err then
      kong.log.err(err)
      return kong.response.exit(500, "An unexpected error occurred")
    end
    return value  --is table
end

function HeaderRestrictionHandler:new()
    HeaderRestrictionHandler.super.new(self, "header-restriction")
end

function HeaderRestrictionHandler:init_worker()
    HeaderRestrictionHandler.super.init_worker(self)
    -- load all cache
    local ok, err = cache_warmup.execute({"header_blockList"})
    if not ok then
        kong.log.err("load cache error" .. err)
      return nil, err
    end
    -- listen to CRUD operation, Create , Read , Update , Delete
    kong.worker_events.register(function(data)
        if data.operation == "create" then
            local key = data.entity.value
            kong.log("add blockList cache, key: " .. key)
            local cache_key = kong.db.header_blockList:cache_key(key)
            local ok, err = kong.cache:safe_set(cache_key, data.entity);
            if err then
                kong.log.err(err)
            end
        end
    end, "crud", "header_blockList")
end

function HeaderRestrictionHandler:access(config)
    HeaderRestrictionHandler.super.access(self)
    local header = ngx.req.get_headers()[config.header]

    if header and is_block(header) then
        return kong.response.exit(403, "Access denied")
    end
end

return HeaderRestrictionHandler
