create or replace function get_current_person_id(
  out current_person_id integer
)
  language sql
  as $$
    select current_setting('cookie.session.person_id')::integer as current_person_id;
  $$
;
