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
    type,
    DATEADD(
        DAY,
        ABS(MOD(HASH(id), 6210)), -- generates a psuedo-random date between 2008-01-01 and 2024-12-31 (which is 6209 days later); a remainder will never be larger than the divisor, so abs() and mod() will create a range >= 0 and <= 6209
        TO_DATE('2008-01-01')
    ) AS service_start_date,
    _ab_cdc_deleted_at,
    _ab_cdc_updated_at
FROM {{ source('datacenters', 'data_center_atlas') }}
-- "datacenters" is the "friendly" name that we set inside the source schema.yml
-- "data_center_atlas" is the table name