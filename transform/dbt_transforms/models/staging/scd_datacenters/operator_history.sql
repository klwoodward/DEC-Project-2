-- get record of where active (i.e. non-deleted) data centers had the operator value change
-- one row per data center operator change
-- checks if a database switched from one operator to another
WITH active_records AS (
    SELECT
        id,
        operator_key,
        operator,
        LAG(operator_key) OVER (
            PARTITION BY id
            ORDER BY _ab_cdc_updated_at
        ) AS previous_operator_key,
        _ab_cdc_updated_at
    FROM {{ ref('scd_data_center_atlas') }}
    WHERE _ab_cdc_deleted_at IS NULL -- ignore records of deletion (because operator and operator_key will be null, but we do not want to consider that a change)
),
operator_changes AS (
    SELECT
        id,
        operator_key,
        operator,
        _ab_cdc_updated_at
    FROM active_records
    WHERE 
        previous_operator_key IS NULL -- first occurrence, no record preceding (although operator can be null in raw table, in staging we changed any null operators into an "Unknown" operator code)
        OR previous_operator_key != operator_key -- current row has the same operator_key as the previous, but a different operator (i.e., the operator changed)
)
SELECT
    id,
    operator_key,
    operator,
    _ab_cdc_updated_at AS operator_modified_at
FROM operator_changes