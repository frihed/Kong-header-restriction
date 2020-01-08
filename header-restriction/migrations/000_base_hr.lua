return {
  postgres = {
    up = [[
      CREATE TABLE IF NOT EXISTS "header_blockList" (
        "id"           UUID                         PRIMARY KEY,
        "created_at"   TIMESTAMP WITHOUT TIME ZONE  DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'),
        "value"   TEXT                         UNIQUE
      );
      DO $$
      BEGIN
        CREATE INDEX IF NOT EXISTS "header_blockList_idx" ON "header_blockList" ("value");
      EXCEPTION WHEN UNDEFINED_COLUMN THEN
        -- Do nothing, accept existing state
      END$$;
    ]],
  },

  cassandra = {
    up = [[
      CREATE TABLE IF NOT EXISTS header_blockList(
        id          uuid PRIMARY KEY,
        created_at  timestamp,
        value  text
      );
      CREATE INDEX IF NOT EXISTS ON header_blockList(value);
    ]],
  },
}