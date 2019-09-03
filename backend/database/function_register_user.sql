drop function if exists register_user;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION register_user (
  input_email      text,
  input_name       text,
  input_surname    text,
  input_phone      text,
  input_department text,
  input_contract   text,
  input_category   text,
  input_password   text
) returns persons as $$
declare
  new_user persons;
  use_contract text;
  use_department text;
begin

  if input_department = '' then
    use_department = null;
  else
    use_department = input_department;
  end if;

  if input_contract = '' then
    use_contract = null;
  else
    use_contract = input_contract;
  end if;

  insert into persons (
    email,
    name,
    surname,
    phone,
    department,
    contract,
    category
  ) values (
    input_email,
    input_name,
    input_surname,
    input_phone,
    use_department,
    use_contract,
    input_category::person_category_type
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
end;
$$ language plpgsql strict security definer;
-------------------------------------------------------------------------------
select register_user(
  'input_email',
  'input_name',
  'input_surname',
  'input_phone',
  'input_department',
  'input_contract',
  'input_category',
  'input_password'
);