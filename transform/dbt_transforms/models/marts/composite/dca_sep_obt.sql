-- data center info with electricity metrics for its state and "in service" year
SELECT 
    dca.id,
    dca.county,
    dca.county_id,
    dca.state,
    dca.state_abb,
    dca.state_id,
    dca.county AS second_county,
    dca.county_id AS second_county_id,
    dca.state AS second_state,
    dca.state_abb AS second_state_abb,
    dca.state_id AS second_state_id,
    dca.ref,
    dca.operator,
    dca.name,
    dca.sqft,
    dca.lon,
    dca.lat,
    dca.type,
    CONCAT(sep.state_abb, '-', sep.year) AS EIA_SEP_state_year,
    direct_use AS EIA_SEP_direct_use,
    direct_use_units AS EIA_SEP_direct_use_units,
    direct_use_rank AS EIA_SEP_direct_use_rank,
    average_retail_price AS EIA_SEP_retail_price,
    average_retail_price_rank AS EIA_SEP_average_retail_price_rank,
    average_retail_price_units AS EIA_SEP_average_retail_price_units
FROM 
    {{ref('data_center_atlas_obt')}} AS dca
    LEFT JOIN {{ref('state_electricity_profiles_obt')}} AS sep
        ON dca.state_abb = sep.state_abb
WHERE sep.year = (SELECT MAX(year) FROM {{ ref('state_electricity_profiles_obt') }})
