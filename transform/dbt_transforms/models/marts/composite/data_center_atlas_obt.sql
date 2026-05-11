-- data centers from im3 and whether or not they are still active
-- collapses data so that grain of table is a datacenter, not datacenter/county combo
WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER ( -- we will grab the first two regions of each data center, ordered alphabetically; if a data center has more than two regions, the rest will be ignored
            PARTITION BY id
            ORDER BY county_id
        ) AS county_rank
    FROM {{ ref('data_center_atlas') }}
),
primary_county AS (
    SELECT *
    FROM ranked
    WHERE county_rank = 1
),
secondary_county AS (

    SELECT *
    FROM ranked
    WHERE county_rank = 2
)
SELECT
    p.id,
    p.county,
    p.county_id,
    p.state,
    p.state_abb,
    p.state_id,
    s.county AS second_county,
    s.county_id AS second_county_id,
    s.state AS second_state,
    s.state_abb AS second_state_abb,
    s.state_id AS second_state_id,
    p.ref,
    p.operator,
    p.name,
    p.sqft,
    p.lon,
    p.lat,
    p.type
FROM 
    primary_county p
    LEFT JOIN secondary_county s
        ON p.id = s.id


