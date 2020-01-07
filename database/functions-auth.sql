create or replace function authenticate (
  in input_email    text,
  in input_password text,
  out user_data text
)
  language sql
  stable
  strict
  security definer
  as $$
    select p.person_id::text || '-' || a.person_role::text as user_data
      from persons as p
      inner join private.accounts as a using (person_id)
    where p.email = input_email
          and
          a.password_hash = crypt(input_password, a.password_hash)
          and
          a.is_active;
  $$
;
