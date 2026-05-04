-- Create a logical replication slot to track WAL changes for CDC
SELECT pg_create_logical_replication_slot('airbyte_slot', 'pgoutput');


-- Define how rows are identified during UPDATE/DELETE operations during replication
-- DEFAULT uses the table's primary key
ALTER TABLE rental REPLICA IDENTITY DEFAULT;


-- Create a publication that exposes table changes
-- Only tables included here will show change events to CDC consumers like Airbyte
CREATE PUBLICATION airbyte_publication FOR TABLE rental;