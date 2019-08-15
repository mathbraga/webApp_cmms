CREATE EXTENSION pgcrypto;

create schema private_schema;

create type public.jwt_token as (
  role text,
  expire integer,
  person_id integer,
  email text
);

create table private_schema.accounts (
  person_id        integer primary key,
  email            text not null unique check (email ~* '^.+@.+\..+$'),
  password_hash    text not null
);

insert into private_schema.accounts (person_id, email, password_hash) values
  (1, 'spowell0@noaa.gov', '$2a$06$.Ryt.S6xCN./QmTx3r9Meu/nsk.4Ypfuj.o9qIqv4p3iipCWY45Bi');

-- password 'iFbWWlc'

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

select * from authenticate('spowell0@noaa.gov', 'iFbWWlc');

CREATE OR REPLACE FUNCTION get_current_user() RETURNS text AS $$
  SELECT current_user::text;
$$ LANGUAGE SQL STABLE;


CREATE ROLE unauth
GRANT SELECT ON ALL TABLES IN SCHEMA public TO unauth;
CREATE USER user1 WITH LOGIN PASSWORD '1234' IN ROLE unauth;

CREATE ROLE auth;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO auth;
CREATE USER user1auth WITH LOGIN PASSWORD '123456' IN ROLE auth;