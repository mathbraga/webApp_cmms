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
select pg_terminate_backend(pid) from pg_stat_activity
where pid <> pg_backend_pid() and datname = :'new_db_name';

-- drop database
drop database if exists :new_db_name;

-- create new database
create database :new_db_name with owner postgres;

-- connect to the new database
\c :new_db_name

-- create extensions
create extension if not exists pgcrypto;

-- create additional schemas
create schema private;
create schema api;
create schema web;

-- create roles
\i roles/roles.sql

-- set password for postgres role
alter role postgres with encrypted password '123456';

-- set ON_ERROR_STOP to on
\set ON_ERROR_STOP on

-- set client encoding to utf8
\encoding utf8

-- begin transaction
begin transaction;

-- alter default privileges
\i roles/privileges.sql

-- create get_person_id function
\i public/get_person_id.sql

-- create composite types
\i public/types.sql

-- create domains
-- \i public/domains.sql

-- define db constants
\i public/get_constant_value.sql

-- create tables
\i public/lookup_tables.sql
\i public/tables.sql

-- other things
\i public/get_asset_trees.sql
\i public/get_exception_message.sql
\i public/balances.sql

-- create api schema objects
-- task basic
\i api/insert_task_files.sql
\i api/remove_task_file.sql
\i api/task_data.sql
\i api/task_form_data.sql
\i api/insert_task.sql
\i api/modify_task.sql
-- task events
\i api/move_task.sql
\i api/receive_task.sql
\i api/send_task.sql
\i api/cancel_send_task.sql
-- task messages
\i api/insert_task_message.sql
\i api/modify_task_message.sql
\i api/remove_task_message.sql
-- task supplies
\i api/insert_task_supply.sql
\i api/modify_task_supplies.sql
-- task assets
\i api/insert_task_asset.sql
\i api/remove_task_asset.sql

-- other entities
\i api/appliance_data.sql
\i api/asset_form_data.sql
\i api/facility_data.sql
\i api/contract_data.sql
\i api/spec_data.sql
\i api/team_data.sql

-- create web schema objects
\i web/authenticate.sql
\i web/get_all_files_uuids.sql
\i web/refresh_all_materialized_views.sql

-- create and login with fake user for initial inserts
set local cookie.session.person_id to 0;
insert into persons overriding system value values
(0, '00000000000', 'email@email.com', 'Visitor', '0000', null, null);

-- create triggers before populate tables
-- \i triggers/check_asset_category.sql
-- \i triggers/check_asset_relation.sql
-- \i triggets/check_task_event.sql
-- \i triggers/check_task_supply.sql
-- \i triggers/insert_audit_trail.sql

-- create rls policies
-- \i policies/assets.sql
-- \i policies/asset_relations.sql
-- \i policies/contracts.sql
-- \i policies/persons.sql
-- \i policies/accounts.sql
-- \i policies/teams.sql
-- \i policies/team_persons.sql
-- \i policies/contract_teams.sql
-- \i policies/projects.sql
-- \i policies/requests.sql
-- \i policies/tasks.sql
\i policies/task_messages.sql
-- \i policies/task_assets.sql
-- \i policies/task_events.sql
-- \i policies/specs.sql
-- \i policies/supplies.sql
-- \i policies/task_supplies.sql
-- \i policies/task_files.sql

-- populate tables with sample data
\i sample/asset_categories.sql
\i sample/assets.sql
\i sample/asset_relations.sql
\i sample/contracts.sql
\i sample/persons.sql
\i sample/accounts.sql
\i sample/teams.sql
\i sample/team_persons.sql
\i sample/contract_teams.sql
\i sample/projects.sql
\i sample/requests.sql
\i sample/specs.sql
\i sample/supplies.sql
-- tasks
\i sample/task1.sql

-- restart sequences
\i sample/_restart_sequences.sql

-- create triggers after populate tables
-- \i trigger/name_of_the_trigger.sql

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- commit transaction
commit transaction;

-- create extra indexes
\i public/indexes.sql

-- set the default transaction isolation level
-- alter database :new_db_name set default_transaction_isolation to 'serializable';

-- cleanup variable(s)
\unset new_db_name
