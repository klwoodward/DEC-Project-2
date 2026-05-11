
from dagster import EnvVar, AutomationCondition, AssetSpec, AssetKey
from dagster_airbyte import AirbyteCloudWorkspace, build_airbyte_assets_definitions, DagsterAirbyteTranslator, AirbyteConnectionTableProps

# https://docs.dagster.io/api/libraries/dagster-airbyte

AIRBYTE_SCHEMA_MAP = {
    "data_center_atlas": "datacenters",
    "scd_data_center_atlas": "scd_datacenters",
    "state_electricity_profiles": "electricity",
}


class CustomDagsterAirbyteTranslator(DagsterAirbyteTranslator):
    def get_asset_spec(self, props: AirbyteConnectionTableProps) -> AssetSpec:
        default_spec = super().get_asset_spec(props)

        schema = AIRBYTE_SCHEMA_MAP.get(props.table_name)

        if schema is None:
            raise ValueError(
                f"No schema mapping found for Airbyte table: {props.table_name}"
            )

        return default_spec.replace_attributes(
            key=AssetKey([
                "raw",
                schema,
                props.table_name,
            ]),
            group_name="airbyte_assets",
            automation_condition=AutomationCondition.on_cron(cron_schedule="*/6 * * * *") # every 6 min
        )

airbyte_workspace = AirbyteCloudWorkspace(
    workspace_id=EnvVar("AIRBYTE_CLOUD_WORKSPACE_ID"),
    client_id=EnvVar("AIRBYTE_CLOUD_CLIENT_ID"),
    client_secret=EnvVar("AIRBYTE_CLOUD_CLIENT_SECRET"),
)

airbyte_assets = build_airbyte_assets_definitions(
    workspace=airbyte_workspace,
    connection_selector_fn=lambda connection: connection.name
    in ["eia API → Snowflake", "RDS-datacenters-1 → Snowflake-1", "RDS-datacenters-2 → Snowflake-2"],
    dagster_airbyte_translator=CustomDagsterAirbyteTranslator()
)
