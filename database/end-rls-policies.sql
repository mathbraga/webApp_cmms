begin;

-- enable rls
alter table tasks enable row level security;
alter table task_assets enable row level security;
alter table task_supplies enable row level security;
alter table task_messages enable row level security;
alter table assets enable row level security;
alter table departments enable row level security;
alter table asset_departments enable row level security;
alter table contracts enable row level security;
alter table teams enable row level security;
alter table team_persons enable row level security;
alter table persons enable row level security;
alter table specs enable row level security;
alter table private.accounts enable row level security;
alter table private.logs enable row level security;

-- create policies on...
-- tasks
create policy employee_policy on tasks for all to employee
  using (
    team_id in (select tp.team_id from team_persons as tp where tp.person_id = current_setting('auth.data.person_id')::integer)
  )
  with check (
    team_id in (select tp.team_id from team_persons as tp where tp.person_id = current_setting('auth.data.person_id')::integer)
  );

create policy supervisor_policy on tasks for all to supervisor
  using (true)
  with check (true);

-- task_assets
create policy employee_policy on task_assets for all to employee
  using ()
  with check ();

create policy employee_policy on task_assets for all to supervisor
  using ()
  with check ();

-- task_supplies
create policy employee_policy on task_supplies for all to employee
  using ()
  with check ();

create policy supervisor_policy on task_supplies for all to supervisor
  using ()
  with check ();

-- task_messages
create policy employee_policy on task_messages for all to employee
  using ()
  with check ();

create policy supervisor_policy on task_messages for all to supervisor
  using ()
  with check ();

-- assets
create policy employee_policy on assets for all to employee
  using (true)
  with check (false);

create policy supervisor_policy on assets for all to supervisor
  using (true)
  with check (true);

-- departments
create policy employee_policy on departments for all to employee
  using (true)
  with check (false);

create policy supervisor_policy on departments for all to supervisor
  using (true)
  with check (true);

-- asset_departments
create policy employee_policy on asset_departments for all to employee
  using (true)
  with check (false);

create policy supervisor_policy on asset_departments for all to supervisor
  using (true)
  with check (true);

-- contracts
create policy employee_policy on contracts for all to employee
  using (true)
  with check (false);

create policy supervisor_policy on contracts for all to supervisor
  using (true)
  with check (true);

-- teams
create policy employee_policy on teams for all to employee
  using (true)
  with check (false);

create policy supervisor_policy on teams for all to supervisor
  using (true)
  with check (true);

-- team_persons
create policy employee_policy on team_persons for all to employee
  using (true)
  with check (false);

create policy supervisor_policy on team_persons for all to supervisor
  using (true)
  with check (true);

-- persons
create policy employee_policy on persons for all to employee
  using (
    person_id = current_setting('auth.data.person_id')::integer
  )
  with check (
    person_id = current_setting('auth.data.person_id')::integer
  );

create policy supervisor_policy on persons for all to supervisor
  using (true)
  with check (true);

-- specs
create policy employee_policy on specs for all to employee
  using (true)
  with check (false);

create policy supervisor_policy on specs for all to supervisor
  using (true)
  with check (true);

-- private.accounts
create policy employee_policy on private.accounts for all to employee
  using (
    person_id = current_setting('auth.data.person_id')::integer
  )
  with check (
    person_id = current_setting('auth.data.person_id')::integer
  );

create policy supervisor_policy on private.accounts for all to supervisor
  using (true)
  with check (true);

-- private.logs
create policy employee_policy on private.logs for all to employee
  using (true)
  with check (false);

create policy supervisor_policy on private.logs for all to supervisor
  using (true)
  with check (false);

---------------------------------------------------------------------------------------
-- rls tests
set local auth.data.person_id to 1;
set role auth;
select current_user;
select * from tasks;
rollback;