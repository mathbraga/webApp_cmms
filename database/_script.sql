-- rollback transaction
rollback;

-- define new database name
\set new_db_name 'new_cmms'

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- create temporary database
create database temp_db;

-- connect to temporary database
\c temp_db

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

-- create enums
-- \i enums.sql

-- create lookup tables
\i luts.sql

-- create tables
\i tables.sql

-- create views
\i views.sql

-- create materialized views
\i materialized-views.sql

-- create functions
\i functions-auth.sql
\i functions-exception.sql
\i functions-inserts.sql
\i functions-modifies.sql
\i functions-queries.sql
\i functions-refresh.sql
\i functions-triggers.sql

-- create triggers
\i triggers.sql

-- fake logged user for initial inserts
set local auth.data.person_id to 0;
insert into persons overriding system value values (0, '00000000000', 'email@email.com', 'Visitor', '0000', null, null);

-- populate tables
\i inserts.sql

-- create rls policies
-- \i policies.sql

-- create comments
-- \i comments.sql

-- create smart comments
\i smart-comments.sql

-- restart sequences
\i sequences.sql

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- commit transaction
commit transaction;
