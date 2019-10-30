begin;

\set ON_ERROR_STOP on

\i insert-contracts.sql

\i insert-specs.sql

\i insert-supplies.sql

\set ON_ERROR_STOP off

rollback;