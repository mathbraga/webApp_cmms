drop function if exists private.reset_password;
---------------------------------------------------------------------
begin;
create or replace function private.reset_password (
  input_email text
)
returns text
language plpgsql
as $$
declare
  person_number integer;
begin
  select person_id into person_number from persons where email = input_email;
  update private.accounts as a
    set password_hash = crypt('123456', gen_salt('bf', 10))
  where a.person_id = person_number;
  return 'Password reset done for user ' || input_email;
end;
$$
strict
security definer;
REVOKE ALL ON FUNCTION private.reset_password(input_email text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION private.reset_password(input_email text) TO hzlopes;
commit;
---------------------------------------------------------------------
select private.reset_password('hzlopes@senado.leg.br');


