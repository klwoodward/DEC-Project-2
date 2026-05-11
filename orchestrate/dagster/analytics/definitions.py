from dagster import Definitions, EnvVar, load_assets_from_modules

from analytics.assets.airbyte import airbyte_assets, airbyte_workspace
from analytics.assets.dbt import dbt_warehouse, dbt_warehouse_resource
from analytics.resources.snowflake import snowflake_resource


defs = Definitions(
    assets=[*airbyte_assets, dbt_warehouse],
    # jobs=[run_weather_etl],
    # schedules=[weather_etl_schedule],
    resources={
        "airbyte": airbyte_workspace,
        "snowflake": snowflake_resource,
        "dbt_warehouse_resource": dbt_warehouse_resource,
    },
)

