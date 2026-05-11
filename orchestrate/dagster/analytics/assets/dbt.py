
import os
from pathlib import Path

from dagster_dbt import DbtCliResource, dbt_assets, DagsterDbtTranslator
from dagster import AssetExecutionContext, AssetKey
import dagster as dg

# configure dbt project resource
dbt_project_dir = Path(__file__).joinpath("..", "..", "..", "..", "..", "transform", "dbt_transforms").resolve() # current_file_path -> navigate to dbt_project folder
dbt_warehouse_resource = DbtCliResource(project_dir=os.fspath(dbt_project_dir))

# generate manifest
dbt_manifest_path = (
    dbt_warehouse_resource.cli(
        ["--quiet", "parse"],
        target_path=Path("target"),
    )
    .wait()
    .target_path.joinpath("manifest.json")
)

class CustomDagsterDbtTranslator(DagsterDbtTranslator):
    def get_group_name(self, dbt_resource_props):
        return "dbt"

    def get_asset_key(self, dbt_resource_props):
        resource_type = dbt_resource_props.get("resource_type")

        # dbt sources should match Airbyte raw landing assets
        if resource_type == "source":
            return AssetKey([
                "raw",
                dbt_resource_props["schema"],
                dbt_resource_props["name"],
            ])

        # dbt models should keep their normal dbt/Dagster names
        return super().get_asset_key(dbt_resource_props)

    def get_automation_condition(self, dbt_resource_props):
        return dg.AutomationCondition.eager()
    

# load manifest to produce asset defintion
@dbt_assets(manifest=dbt_manifest_path, dagster_dbt_translator=CustomDagsterDbtTranslator())
def dbt_warehouse(context: AssetExecutionContext, dbt_warehouse_resource: DbtCliResource):
    yield from dbt_warehouse_resource.cli(["build"], context=context).stream() # when we trigger a dagster asset it triggers a dbt run






