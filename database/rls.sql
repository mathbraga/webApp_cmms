begin;

alter table orders enable row level security;

drop policy if exists employee_select on orders;

create policy employee_select on orders for select to employee
  using (
    team_id in (select tp.team_id from team_persons as tp where tp.person_id = current_setting('auth.data.person_id')::integer)
  );

set local auth.data.person_id to 1;
set role auth;
-- select current_user;
select * from orders;

rollback;


-- begin;
-- set local auth.data.person_id to 1;
-- select 'Henrique Zaidan Lopes' = p.full_name from persons as p where person_id = current_setting('auth.data.person_id')::integer;
-- rollback;