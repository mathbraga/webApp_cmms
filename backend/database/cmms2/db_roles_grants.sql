-- bypass de rls ---> somente para admins!
alter role role_name with bypassrls;

create role unauth;
create role auth;

grant select on all tables in schema public to unauth;
grant select, insert, update, delete on all tables in schema public to auth;

---- tudo:
grant select, insert, update, delete on all tables in schema public to unauth;
grant usage on all sequences in schema public to unauth;
grant usage on all sequences in schema public to auth;

alter default privileges in schema public grant select on tables to unauth;
alter default privileges in schema public grant all on tables to auth;
alter default privileges in schema public grant usage on sequences to unauth;
alter default privileges in schema public grant usage on sequences to auth;
alter default privileges in schema public grant execute on routines to unauth;
alter default privileges in schema public grant execute on routines to auth;
