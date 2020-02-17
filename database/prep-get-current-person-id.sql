create or replace function get_current_person_id(
  out current_person_id integer
)
  language sql
  as $$
    select current_setting('auth.data.person_id')::integer as current_person_id;
  $$
;
