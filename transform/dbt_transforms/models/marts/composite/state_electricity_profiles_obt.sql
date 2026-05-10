-- state electricity profiles per year, from eia
SELECT
    year,
    state_abb,
    state,
    direct_use,
    direct_use_units,
    direct_use_rank,
    average_retail_price,
    average_retail_price_rank,
    average_retail_price_units
FROM {{ ref('state_electricity_profiles') }} -- the table created by staging/electricity/state_electricity_profiles.sql
WHERE state_abb != 'US' -- since api returns a row for United States, among the states