drop function if exists get_ceb_bills;
drop function if exists get_caesb_bills;
drop function if exists register_user;
drop function if exists authenticate;
---------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_ceb_bills (
  input_meter   integer,
  input_yyyymm1 integer,
  input_yyyymm2 integer
) RETURNS SETOF ceb_bills
LANGUAGE plpgsql STABLE AS $$
BEGIN
IF input_meter = 199 THEN
  RETURN QUERY SELECT * FROM ceb_bills
  WHERE TRUE AND yyyymm BETWEEN input_yyyymm1 AND input_yyyymm2
  ORDER BY ceb_bills.meter_id, ceb_bills.yyyymm;
ELSE
  RETURN QUERY SELECT * FROM ceb_bills
  WHERE meter_id = input_meter AND yyyymm BETWEEN input_yyyymm1 AND input_yyyymm2
  ORDER BY ceb_bills.meter_id, ceb_bills.yyyymm;
END IF;
END; $$;
---------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_caesb_bills (
  input_meter   integer,
  input_yyyymm1	integer,
  input_yyyymm2 integer
) RETURNS SETOF caesb_bills
LANGUAGE plpgsql STABLE AS $$
BEGIN
IF meter = 299 THEN
  RETURN QUERY SELECT * FROM caesb_bills
  WHERE TRUE AND yyyymm BETWEEN input_yyyymm1 AND input_yyyymm2
  ORDER BY caesb_bills.meter_id, caesb_bills.yyyymm;
ELSE
  RETURN QUERY SELECT * FROM caesb_bills
  WHERE meter_id = input_meter AND yyyymm BETWEEN yyyymm1 AND yyyymm2
  ORDER BY caesb_bills.meter_id, caesb_bills.yyyymm;
END IF;
END; $$;
---------------------------------------------------------------
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
    active
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
---------------------------------------------------------------
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
    account.active
    then
    return result;
  else
    return null;
  end if;
end; $$;
---------------------------------------------------------------
