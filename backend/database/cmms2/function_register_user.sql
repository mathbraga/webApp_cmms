drop function if exists register_user;
-------------------------------------------------------------------------------
create or replace function register_user (
  person_attributes persons,
  input_password   text
) returns persons
language plpgsql
strict
security definer
as $$
declare
  new_user persons;
begin

  insert into persons (
    person_id,
    email,
    name,
    surname,
    phone,
    department,
    contract,
    category
  ) values (
    default,
    person_attributes.email,
    person_attributes.name,
    person_attributes.surname,
    person_attributes.phone,
    person_attributes.department,
    person_attributes.contract,
    person_attributes.category
  ) returning * into new_user;
  
  insert into private.accounts (
    person_id,
    password_hash,
    created_at,
    updated_at,
    is_active
  ) values (
    new_user.person_id,
    crypt(input_password, gen_salt('bf', 10)),
    now(),
    now(),
    true
  );

  return new_user;

end; $$;
-------------------------------------------------------------------------------
select register_user(
  (
  'ejaklfsd@exemplo.com',
  'input_name',
  'input_surname',
  'input_phone',
  'SINFRA',
  null,
  'E'
  ),
  '123456'
);