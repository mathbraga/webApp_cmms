drop policy if exists employee_policy on tasks;

create policy employee_policy on tasks for all to employee
  using (
    team_id in (select tp.team_id from team_persons as tp where tp.person_id = get_current_person_id()
  )
  with check (
    team_id in (select tp.team_id from team_persons as tp where tp.person_id = get_current_person_id()
  )
;

drop policy if exists supervisor_policy on tasks;

create policy supervisor_policy on tasks for all to supervisor
  using (true)
  with check (true)
;
