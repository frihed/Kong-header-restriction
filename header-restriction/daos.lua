local typedefs = require "kong.db.schema.typedefs"

return {
    header_blockList = {
    primary_key = { "id" },
    name = "header_blockList",
    endpoint_key = "value",
    cache_key = { "value" },
    generate_admin_api = true,
    fields = {
      { id = typedefs.uuid },
      { created_at = typedefs.auto_timestamp_s },
      { value = { type = "string", required = true, unique = true }, },
    },
  },
}
