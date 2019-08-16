drop function authenticate;
drop table private_schema.accounts;
drop type jwt_token;
---------------------------------------------------------------
CREATE EXTENSION pgcrypto;
create schema private_schema;
---------------------------------------------------------------
BEGIN;
create type public.jwt_token as (
  role text,
  exp integer,
  person_id integer,
  email text
);

create table private_schema.accounts (
  person_id        integer primary key,
  email            text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash    text not null
);

insert into private_schema.accounts (person_id, email, password_hash) values
  (1, 'hzlopes@senado.leg.br', '$1$KYP76V/w$Pir5G.eTfAXInHM8PpIgY.');

-- password '123456' (md5)

create or replace function public.authenticate(
  email text,
  password text
) returns public.jwt_token as $$
declare
  account private_schema.accounts;
begin
  select a.* into account
    from private_schema.accounts as a
    where a.email = $1;

  if account.password_hash = crypt($2, account.password_hash) then
    return (
      'auth',
      extract(epoch from now() + interval '7 days'),
      account.person_id,
      account.email
    )::public.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;
---------------------------------------------------------------
select * from authenticate('hzlopes@senado.leg.br', '123456');






















CREATE OR REPLACE FUNCTION get_current_user() RETURNS text AS $$
  SELECT current_setting('jwt.claims.exp', true);
$$ LANGUAGE SQL STABLE;


CREATE ROLE unauth
GRANT SELECT ON ALL TABLES IN SCHEMA public TO unauth;
CREATE USER user1 WITH LOGIN PASSWORD '1234' IN ROLE unauth;

CREATE ROLE auth;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO auth;
CREATE USER user1auth WITH LOGIN PASSWORD '123456' IN ROLE auth;