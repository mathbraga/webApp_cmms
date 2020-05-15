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
\i public/extensions.sql

-- create additional schemas
\i public/schemas.sql

-- create roles
\i public/roles.sql

-- set password for postgres role
alter role postgres with encrypted password '123456';

-- set ON_ERROR_STOP to on
\set ON_ERROR_STOP on

-- set client encoding to utf8
\encoding utf8

-- begin transaction
begin transaction;

-- alter default privileges
\i public/privileges.sql

-- create get_current_person_id function
\i public/get_current_person_id.sql

-- create composite types
\i public/types.sql

-- create domains
-- \i public/domains.sql

-- create tables
\i public/lookup_tables.sql
\i public/tables.sql

-- other things
\i public/get_asset_trees.sql
\i public/get_exception_message.sql
\i public/get_mutation_response.sql

-- create api schema objects
\i api/insert_task.sql
\i api/modify_task.sql
\i api/task_data.sql
\i api/form_data.sql
\i api/appliance_data.sql
\i api/asset_form_data.sql
\i api/facility_data.sql
\i api/contract_data.sql
\i api/spec_data.sql
\i api/team_data.sql

-- create ws schema objects
\i ws/authenticate.sql
\i ws/get_all_files_uuids.sql
\i ws/refresh_all_materialized_views.sql

-- create and login with fake user for initial inserts
set local cookie.session.person_id to 0;
insert into persons overriding system value values
(0, '00000000000', 'email@email.com', 'Visitor', '0000', null, null);

-- create triggers before populate tables
-- \i triggers/name_of_the_trigger.sql

-- populate tables with sample data
-- \i sample/assets.sql
-- \i sample/asset_relations.sql
-- \i sample/contracts.sql
-- \i sample/persons.sql
-- \i sample/accounts.sql
-- \i sample/teams.sql
-- \i sample/team_persons.sql
-- \i sample/contract_teams.sql
-- \i sample/projects.sql
-- \i sample/requests.sql
-- \i sample/tasks.sql
-- \i sample/task_messages.sql
-- \i sample/task_assets.sql
-- \i sample/task_dispatches.sql
-- \i sample/specs.sql
-- \i sample/supplies.sql
-- \i sample/task_supplies.sql
-- \i sample/task_files.sql

-- restart sequences
-- \i sample/restart_sequences.sql

-- create triggers after populate tables
-- \i trigger/name_of_the_trigger.sql

-- create rls policies
-- \i public/rls_policies.sql

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- commit transaction
commit transaction;

-- create extra indexes
-- \i public/indexes.sql

-- set the default transaction isolation level
-- alter database :new_db_name set default_transaction_isolation to 'serializable';

-- cleanup variable(s)
\unset new_db_name
