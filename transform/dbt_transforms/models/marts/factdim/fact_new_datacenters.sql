WITH ranked AS (
    SELECT
        scd.id,
        ds.state_key,
        ds.state_id,
        scd.ref,
        scd.operator_key,
        scd.name,
        scd.sqft,
        scd.lon,
        scd.lat,
        scd.type,
        scd.service_start_date,
        scd._ab_cdc_updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY scd.id
            ORDER BY scd.service_start_date ASC, scd._ab_cdc_updated_at ASC, scd.county_id
        ) AS rn
    FROM 
        {{ref('scd_data_center_atlas')}} AS scd
        LEFT JOIN {{ ref('dim_state') }} AS ds
        ON scd.state_abb = ds.state_abb
    WHERE _ab_cdc_deleted_at IS NULL
)
SELECT -- keeps the first appearance of each id by scd.service_start_date
    id,
    state_key,
    state_id,
    ref,
    operator_key,
    name,
    sqft,
    lon,
    lat,
    type,
    service_start_date,
    _ab_cdc_updated_at
FROM ranked
WHERE rn = 1
ORDER BY service_start_date