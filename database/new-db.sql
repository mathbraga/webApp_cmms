-- connect to other database
\c hzl

-- drop database
drop database if exists cmms7;

-- create new database
create database cmms7 with owner postgres template template0 encoding 'win1252';

-- connect to the new database
\c cmms7

-- create extensions
create extension if not exists pgcrypto;

-- create additional schemas
create schema private;

-- create roles
-- \i roles.sql

-- set ON_ERROR_STOP to on
\set ON_ERROR_STOP on

-- begin transaction
begin transaction;

-- alter default privileges
\i privileges.sql

-- create enums
\i enums.sql

-- create lookup tables
-- \i luts.sql

-- create tables
\i tables.sql

-- create views
\i views.sql

-- create functions
\i functions.sql

-- create triggers
-- \i triggers.sql

-- fake logged user for initial inserts
-- set local auth.data.person_id to 1;

-- populate tables
\i inserts1252.sql -- CAUTION: inserts.sql must have win1252 encoding

-- create rls policies
-- \i policies.sql

-- create comments
-- \i comments.sql -- CAUTION: comments.sql must have win1252 encoding

-- create smart comments
\i smart-comments.sql

-- restart sequences
\i sequences.sql

-- set ON_ERROR_STOP to off
\set ON_ERROR_STOP off

-- commit transaction
commit transaction;