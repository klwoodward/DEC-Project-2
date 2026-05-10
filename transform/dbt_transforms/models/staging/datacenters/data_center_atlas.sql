SELECT
    id,
    state,
    state_abb,
    state_id,
    county,
    county_id,
    ref,
    operator,
    name,
    sqft,
    lon,
    lat,
    type
FROM {{ source('datacenters', 'data_center_atlas') }}
-- "datacenters" is the "friendly" name that we set inside sources.yml
-- "data_center_atlas" is the table name