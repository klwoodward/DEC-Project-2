-- Create a logical replication slot to track WAL changes for CDC
SELECT pg_drop_replication_slot('airbyte_slot_deduped'); -- we will use this for one connection to the table
SELECT pg_drop_replication_slot('airbyte_slot_append'); -- we will use this for another connection to the same table


-- Define how rows are identified during UPDATE/DELETE operations during replication
-- DEFAULT uses the table's primary key
ALTER TABLE data_center_atlas REPLICA IDENTITY DEFAULT;


-- Create a publication that exposes table changes
-- Only tables included here will show change events to CDC consumers like Airbyte
CREATE PUBLICATION airbyte_publication FOR TABLE data_center_atlas;


-- -- to fix WAL disk corruption issue
-- -- see: https://docs.airbyte.com/integrations/sources/postgres/postgres-troubleshooting#advanced-wal-disk-consumption-and-heartbeat-action-query
-- CREATE TABLE airbyte_heartbeat (
-- 	id SERIAL PRIMARY KEY,
-- 	timestamp TIMESTAMP NOT NULL DEFAULT current_timestamp,
-- 	text TEXT
-- );

-- ALTER PUBLICATION airbyte_publication ADD TABLE airbyte_heartbeat;