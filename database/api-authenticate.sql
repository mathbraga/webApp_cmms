create or replace function api.authenticate (
  in input_email    text,
  in input_password text,
  out user_data text
)
  language sql
  stable
  strict
  security definer
  as $$
    select p.person_id::text || ' - ' || p.name::text || ' - ' || p.email::text || ' - ' || a.person_role::text || ' - ' || t.name::text as user_data
      from persons as p
      inner join private.accounts as a using (person_id)
      inner join team_persons as e using (person_id)
      inner join teams as t using (team_id)
    where p.email = input_email
          and
          a.password_hash = crypt(input_password, a.password_hash)
          and
          a.is_active;
  $$
;