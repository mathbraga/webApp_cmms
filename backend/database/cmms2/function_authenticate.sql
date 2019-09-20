drop function if exists authenticate;
-------------------------------------------------------------------------------
create or replace function authenticate (
  input_email    text,
  input_password text
) returns integer
language plpgsql
strict
security definer
as $$
declare
  account private.accounts;
begin

  select a.* into account
    from persons as p
    join private.accounts as a using(person_id)
    where p.email = 'hzlopes@senado.leg.br';
 
  if (
    account.password_hash = crypt(input_password, account.password_hash)
    and account.is_active
  ) then
    return account.person_id;
  else
    return null;
  end if;
  
end; $$;
-------------------------------------------------------------------------------
select authenticate('hzlopes@senado.leg.br', '123456');
