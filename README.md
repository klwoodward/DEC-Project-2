# DEC-Project-2


## Data Sources

### Book Sales Data
1. Set up RDS database
    - Create an AWS account and navigate to RDS
    - It is recommended to set your region to a nearby location when you use AWS services
    - Create Database > Full Configuration
    - Configuration: 
        - Choose a database configuration method: Full Configuration
        - Engine option: PostgreSQL
        - DB Instance Identifier: <rds_db_instance_name> (e.g. 'book-lends')
        - Credentials Management: manage in AWS Secrets manager
        - Storage > Additional Storage Configuration: deselect 'Enable storage autoscaling'
        - Connectivity > Public access: Yes
    - Create database...once successfully created, 'View Connection details' to get the database Endpoint url
2. Allow inbound traffic
    - Once the database has been created, go to 'Connectivity and security'
    - Select the default VPC security group
    - Select 'Edit inbound rules'
    - Select 'Add rule'
        - Select "All TCP"
        - Select 'Anywhere-IPv4'
        - Select 'Save rules'
3. Retrieve database connection info
    - Navigate to Secrets Manager and select the newly generated secret
    - Select 'Retrieve secret value' to get the username and password of the database
4. PgAdmin4
    - Install PgAdmin4 
    - Right click on 'Servers' > Register > Server:
        - General > Name: set a <pdadmin_server_name> (e.g. 'aws-rds')
        - Connection > Host name: <endpoint_from_rds>
        - Connection > Port: 5432
        - Connection > Password: <password_from_Secret_Manager>
        - Select "Save"
    - Under the newly created server, right click on 'Databases' > Create > Database, and provide a <pgadmin_database_name> (e.g. 'book-lends')
    - Right click on the newly created database to select Tools > Restore
        - Format: Directory
        - Filename: <select_filepath> (filepath to 'book-lends' folder)
        - Select 'Restore'
5. Enable CDC
    - Navigate to RDS, and click on Parameter Groups
    - Create a new parameter group, and set rds.logical_replication to 1
    - Go back to our database, then under Modify > DB Parameter Group select the newly made parameter group
    - Continue > Schedule Modifications: Apply immediately
    - Once done, return to the database instance - it should be rebooting (else choose Actions > Reboot)
        - Can check in PgAdmin that SHOW wal_level; returns 'logical'
    - For each table we want to replicate with CDC, we need to create a logical replication slot that will track changes
        - Run the enable_cdc.sql code in PgAdmin4


### Snowflake
1. 
    - Create Snowflake Account
    - Go to Compute > Warehouse and create a <snowflake_warehouse> (e.g. 'COMPUTE_WH') of desired compute size
    - Select your username at the bottom left, then Account > View Account Details > Account/Server URL to get the <snowflake_host_url>
    - Run the following lines in Snowflake by selecting the plus then Create > SQL File:
        use role accountadmin;
        use warehouse <snowflake_warehouse>;
        create database raw;
        create schema raw.booklends;

### Airbyte 

1. Create an Airbyte cloud account
    - Log into Airbyte ETL
    - We will create a new connection...

2. Create a new airbyte source of type Postgres
    - Name: set a <airbyte_source_name> (e.g. 'RDS-book-lends')
    - Host: <endpoint_from_rds>
    - Port: 5432
    - Database name: <pgadmin_database_name> (e.g. 'book-lends')
    - Schemas: public
    - Username: postgres
    - Password: <password_from_Secret_Manager>
    - Update Method: Read Changes using Write-Ahead Log (CDC)
    - Replication Slot: 'airbyte_slot'
    - Publication: 'airbyte_publication'

3. Create a new airbyte destination of type Snowflake
    - Name: snowflake
    - Host: <snowflake_host_url>
    - Role: accountadmin
    - Warehouse: <snowflake_warehouse> (e.g. 'COMPUTE_WH')
    - Database name: "book-lends"
    - Schemas: "raw"
    - Username: <snowflake_username>
    - Authorization Method: Username and Password
    - Password: <snowflake_password>

4. ....cols and update type
... Schedule Type: Manual
- Sync now

## ISBN API

## DBT

## Dagster








