SELECT 
    YEAR(service_start_date) AS year,
    state_key,
    COUNT(id) AS num_new_datacenters,
    SUM(sqft) AS total_new_sqft
FROM {{ref('fact_new_datacenters')}}
GROUP BY 
   year,
   state_key
