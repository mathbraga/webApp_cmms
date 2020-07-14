-- rollback transaction
rollback;

-- define new database name
\set new_db_name 'db_dev'

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

-- create functions
\i public/get_asset_trees.sql
\i public/get_exception_message.sql

-- create views
\i public/balances.sql

-- create materialized views
\i public/asset_contexts.sql

-- create api schema objects
-- task basic
\i api/task/insert_task_files.sql
\i api/task/remove_task_file.sql
\i api/task/task_data.sql
\i api/task/task_form_data.sql
\i api/task/insert_task.sql
\i api/task/modify_task.sql
-- task events
\i api/task/move_task.sql
\i api/task/receive_task.sql
\i api/task/send_task.sql
\i api/task/cancel_send_task.sql
-- task messages
\i api/task/insert_task_note.sql
\i api/task/modify_task_note.sql
\i api/task/remove_task_note.sql
-- task supplies
\i api/task/insert_task_supply.sql
\i api/task/modify_task_supplies.sql
-- task assets
\i api/task/insert_task_asset.sql
\i api/task/remove_task_asset.sql

-- other entities
\i api/asset/appliance_data.sql
\i api/asset/asset_form_data.sql
\i api/asset/facility_data.sql
\i api/contract/contract_data.sql
\i api/spec/spec_data.sql
\i api/team/team_data.sql

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
\i triggers/check_insert_task_event.sql
\i triggers/check_update_task_event.sql
-- \i triggers/check_task_message.sql
\i triggers/check_task_supply.sql
-- \i triggers/insert_audit_trail.sql

-- create rls policies
-- \i policies/task_messages.sql

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

-- switch back to person_id = 0
set local cookie.session.person_id to 0;

-- restart sequences
\i sample/_restart_sequences.sql

-- create triggers after populate tables
-- \i trigger/name_of_the_trigger.sql

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- commit transaction
commit transaction;

-- refresh materialized views
select web.refresh_all_materialized_views();

-- create extra indexes
\i public/indexes.sql

-- set the default transaction isolation level
-- alter database :new_db_name set default_transaction_isolation to 'serializable';

-- cleanup variable(s)
\unset new_db_name
