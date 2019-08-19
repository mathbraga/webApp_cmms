drop function authenticate;
drop function register_user;
drop table private_schema.accounts;
drop table public.users;
drop type jwt_token;
---------------------------------------------------------------
CREATE EXTENSION pgcrypto;
create schema private_schema;
CREATE ROLE unauth;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO unauth;
CREATE ROLE auth;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO auth;
---------------------------------------------------------------
BEGIN;

create type public.jwt_token as (
  role  text,
  exp   integer,
  id    integer,
  email text
);

create table public.users (
  id               serial primary key,
  first_name       text not null check (char_length(first_name) < 80),
  last_name        text check (char_length(last_name) < 80),
  about            text,
  created_at       timestamp default now()
);

create table private_schema.accounts (
  id               integer primary key references public.users(id) on delete cascade,
  email            text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash    text not null
);

insert into public.users (id, first_name, last_name, about) values (1, 'Henrique', 'Lopes', 'Learning authentication');
insert into private_schema.accounts (id, email, password_hash) values (1, 'hzlopes@senado.leg.br', '$1$KYP76V/w$Pir5G.eTfAXInHM8PpIgY.');
alter sequence public.users_id_seq restart with 2;

create or replace function public.register_user(
  first_name text,
  last_name text,
  email text,
  password text
) returns public.users as $$
declare
  new_user public.users;
begin
  insert into public.users (first_name, last_name) values ($1, $2) returning * into new_user;
  insert into private_schema.accounts (id, email, password_hash) values (new_user.id, $3, crypt($4, gen_salt('md5')));
  return new_user;
end;
$$ language plpgsql strict security definer;

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
      account.id,
      account.email
    )::public.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;

COMMIT;




CREATE OR REPLACE FUNCTION get_current_user() RETURNS text AS $$
  SELECT current_setting('jwt.claims.email', true);
$$ LANGUAGE SQL STABLE;
