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
\i terminate.sql

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

-- create roles
\i roles.sql

-- set password for postgres role
alter role postgres with encrypted password '123456';

-- set ON_ERROR_STOP to on
\set ON_ERROR_STOP on

-- set client encoding to utf8
\encoding utf8

-- begin transaction
begin transaction;

-- alter default privileges
\i privileges.sql

-- create composite types
\i types.sql

-- create lookup tables
\i luts.sql

-- create tables
\i tables.sql

-- create build json helpers
\i functions-build-json.sql
\i functions-queries.sql

-- create views
\i views.sql

-- create materialized views
\i materialized-views.sql

-- create functions
\i functions-auth.sql
\i functions-exception.sql
\i functions-refresh.sql
\i functions-triggers.sql

-- fake logged user for initial inserts
set local auth.data.person_id to 0;
insert into persons overriding system value values (0, '00000000000', 'email@email.com', 'Visitor', '0000', null, null);

-- populate tables
\i inserts.sql

-- create triggers
-- select setting ~ '^1[^0]' as postgresql_version_ok from pg_settings where name = 'server_version_num' \gset
-- \if :postgresql_version_ok
\i triggers.sql
-- \endif
-- \unset postgresql_version_ok

-- create rls policies
-- \i policies.sql

-- create smart comments
-- \i smart-comments.sql

-- restart sequences
\i sequences.sql

-- create api
\i api/inserts.sql
\i api/modifies.sql
\i api/views.sql

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- commit transaction
commit transaction;

-- cleanup variable(s)
\unset new_db_name
