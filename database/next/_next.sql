-- rollback transaction
rollback;

-- define new database name
\set new_db_name 'next'

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- create temporary database
create database temp_db;

-- connect to temporary database
\c temp_db

-- terminate existing connections
\i prep/terminate_connections.sql

-- drop database
drop database if exists :new_db_name;

-- create new database
create database :new_db_name with owner postgres;

-- connect to the new database
\c :new_db_name

-- create extensions
\i prep/extensions.sql

-- create additional schemas
\i prep/schemas.sql

-- create roles
\i prep/roles.sql

-- set password for postgres role
alter role postgres with encrypted password '123456';

-- set ON_ERROR_STOP to on
\set ON_ERROR_STOP on

-- set client encoding to utf8
\encoding utf8

-- begin transaction
begin transaction;

-- alter default privileges
\i prep/privileges.sql

-- create get_current_person_id function
\i prep/get_current_person_id.sql

-- create composite types
\i prep/types.sql

-- create domains
-- \i prep/domains.sql

-- create tables
\i prep/lookup_tables.sql
\i prep/tables.sql

-- other things
\i prep/get_asset_trees.sql
\i prep/get_exception_message.sql

-- create api
-- task
\i api/task/insert_task.sql
\i api/task/task_data.sql
\i api/task/form_data.sql
-- asset
\i api/asset/appliance_data.sql
\i api/asset/asset_form_data.sql
\i api/asset/facility_data.sql
-- contract
\i api/contract/contract_data.sql
-- spec
\i api/spec/spec_data.sql
-- team
\i api/team/team_data.sql

-- others
-- \i end/uuid.sql

-- create and login with fake user for initial inserts
-- \i end/fake_user.sql

-- create triggers before populate tables
-- \i trigger/name_of_the_trigger.sql

-- populate tables
-- \i end/populate_tables.sql

-- create triggers after populate tables
-- \i tigger/name_of_the_trigger.sql

-- create rls policies
-- \i end/rls_policies.sql

-- restart sequences
-- \i end/restart_sequences.sql

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- commit transaction
commit transaction;

-- create extra indexes
-- \i end/indexes.sql

-- set the default transaction isolation level
-- alter database :new_db_name set default_transaction_isolation to 'serializable';

-- cleanup variable(s)
\unset new_db_name
