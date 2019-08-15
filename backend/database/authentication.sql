create type jwt_token as (
  role text,
  expire integer,
  person_id integer,
  is_admin boolean,
  username varchar
);

create function public.authenticate(
  email text,
  password text
) returns jwt_token as $$
declare
  account private_schema.person_account;
begin
  select a.* into account
    from private_schema.person_account as a
    where a.email = authenticate.email;

  if account.password_hash = crypt(password, account.password_hash) then
    return (
      'person_role',
      extract(epoch from now() + interval '7 days'),
      account.person_id,
      account.is_admin,
      account.username
    )::my_public_schema.jwt_token;
  else
    return null;
  end if;
end;
$$ language plpgsql strict security definer;


CREATE OR REPLACE FUNCTION get_current_user() RETURNS text AS $$
  SELECT current_user::text;
$$ LANGUAGE SQL STABLE;


CREATE ROLE unauth
GRANT SELECT ON ALL TABLES IN SCHEMA public TO unauth;
CREATE USER user1 WITH LOGIN PASSWORD '1234' IN ROLE unauth;

CREATE ROLE auth;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO auth;
CREATE USER user1auth WITH LOGIN PASSWORD '123456' IN ROLE auth;