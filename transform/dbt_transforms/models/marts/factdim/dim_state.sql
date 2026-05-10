WITH data_center_states AS 
(
    SELECT DISTINCT
        state_id,
        state_abb,
        state
    FROM {{ ref('scd_data_center_atlas') }}
    WHERE state IS NOT NULL
),
electricity_profile_states AS 
(
    SELECT DISTINCT
        state_abb,
        state
    FROM {{ ref('state_electricity_profiles') }}
    WHERE state IS NOT NULL
),
missing_states AS 
(     -- states present in state_electricity_profiles but not present in scd_data_center_atlas (some US territories)
    SELECT
        ( -- way to generate state_ids for the states that didn't have them
            (SELECT MAX(state_id) FROM data_center_states)
            + ROW_NUMBER() OVER (ORDER BY state_abb)
        ) AS state_id,
        state_abb,
        state
    FROM electricity_profile_states
    WHERE state_abb NOT IN (SELECT state_abb FROM data_center_states)
),
combined_states AS 
(
    SELECT
        CAST(state_id AS INT) AS state_id,
        state_abb,
        state
    FROM data_center_states

    UNION ALL

    SELECT 
        CAST(state_id AS INT) AS state_id,
        state_abb,
        state
    FROM missing_states
)
SELECT
    HASH([state_id]) AS state_key, -- surrogate key
    state_id, -- natural key
    state_abb,
    state
FROM combined_states