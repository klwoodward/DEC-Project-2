{{
    config(
        materialized='incremental',
        unique_key = ['year', 'state_abb']    
    )
}} -- default incremental strategy is "merge"

SELECT
    period AS year,
    stateid AS state_abb,
    statedescription AS state,
    "DIRECT-USE" AS direct_use, -- note: must quote because of hyphens, and quoted identifiers are case sensitive (airbyte capitalized columns when ingesting)
    "DIRECT-USE-UNITS" AS direct_use_units,
    "DIRECT-USE-RANK" AS direct_use_rank,
    "AVERAGE-RETAIL-PRICE" AS average_retail_price,
    "AVERAGE-RETAIL-PRICE-RANK" AS average_retail_price_rank,
    "AVERAGE-RETAIL-PRICE-UNITS" AS average_retail_price_units
FROM {{ source('electricity', 'state_electricity_profiles') }}
-- "electricity" is the "friendly" name that we set inside sources.yml
-- "state_electricity_profiles" is the table name
WHERE stateid != 'US' -- api returns a row for United States


{% if is_incremental() %}
    AND period >= (SELECT MAX(year) FROM {{this}} )
{% endif %}

