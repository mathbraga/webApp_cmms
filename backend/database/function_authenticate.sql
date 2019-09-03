drop function if exists authenticate;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION authenticate (
  input_email    text,
  input_password text
) RETURNS integer LANGUAGE plpgsql STRICT SECURITY DEFINER
AS $$
DECLARE
  result  integer;
  account private.accounts;
begin
  select p.person_id into result
    from persons as p
    where p.email = input_email;

  select a.* into account
    from private.accounts as a
    where a.person_id = result;
  
  if
    account.password_hash = crypt(input_password, account.password_hash)
    and
    account.is_active
    then
    return result;
  else
    return null;
  end if;
end; $$;
-------------------------------------------------------------------------------
select authenticate('hzlopes@senado.leg.br', '123456');
