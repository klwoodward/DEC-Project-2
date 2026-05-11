{{
    config(
        materialized='incremental',
        incremental_stategy = 'append'
    )
}}

SELECT
    id,
    state,
    state_abb,
    state_id,
    county,
    county_id,
    ref,
    COALESCE(operator, 'Unknown') AS operator,
    HASH(
        COALESCE(operator, 'Unknown')
    ) AS operator_key, -- generate an operator identifier since we don't have one (i'll go ahead and call it our key, since it's a hash)
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
FROM {{ source('scd_datacenters', 'scd_data_center_atlas') }}
-- "datacenters" is the "friendly" name that we set inside the sources.yml
-- "scd_data_center_atlas" is the table name

-- note: when a record is deleted, the _ab_cdc_updated_at timestamp also gets updated
{% if is_incremental() %}
    WHERE _ab_cdc_updated_at >= (SELECT MAX(_ab_cdc_updated_at) FROM {{this}} )
{% endif %}



