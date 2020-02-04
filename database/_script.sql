-- rollback transaction
rollback;

-- define new database name
\set new_db_name 'cmms'

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- create temporary database
create database temp_db;

-- connect to temporary database
\c temp_db

-- terminate existing connections
\i prep-terminate-connections.sql

-- drop database
drop database if exists :new_db_name;

-- create new database
create database :new_db_name with owner postgres;

-- connect to the new database
\c :new_db_name

-- create extensions
\i prep-extensions.sql

-- create additional schemas
\i prep-schemas.sql

-- create roles
\i prep-roles.sql

-- set password for postgres role
alter role postgres with encrypted password '123456';

-- set ON_ERROR_STOP to on
\set ON_ERROR_STOP on

-- set client encoding to utf8
\encoding utf8

-- begin transaction
begin transaction;

-- alter default privileges
\i prep-privileges.sql

-- create composite types
\i prep-types.sql

-- create tables
\i prep-lookup-tables.sql
\i prep-tables.sql

-- create helpers
\i helper-json-builders.sql
\i helper-get-asset-trees.sql
\i helper-views.sql
\i helper-exception.sql
\i helper-trigger-functions.sql

-- create api
\i api-inserts.sql
\i api-modifies.sql
\i api-views.sql

-- others
\i end-authenticate.sql
\i end-uuid.sql

-- create and login with fake user for initial inserts
\i end-fake-user.sql

-- populate tables
\i end-populate-tables.sql

-- create triggers
\i end-triggers.sql

-- create rls policies
-- \i end-rls-policies.sql

-- restart sequences
\i end-restart-sequences.sql

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- commit transaction
commit transaction;

-- cleanup variable(s)
\unset new_db_name
