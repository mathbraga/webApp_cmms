begin;

-- enable rls
alter table orders enable row level security;
alter table order_assets enable row level security;
alter table order_supplies enable row level security;
alter table order_messages enable row level security;
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
-- orders
create policy employee_policy on orders for all to employee
  using (
    team_id in (select tp.team_id from team_persons as tp where tp.person_id = current_setting('auth.data.person_id')::integer)
  )
  with check (
    team_id in (select tp.team_id from team_persons as tp where tp.person_id = current_setting('auth.data.person_id')::integer)
  );

create policy supervisor_policy on orders for all to supervisor
  using (true)
  with check (true);

-- order_assets
create policy employee_policy on order_assets for all to employee
  using ()
  with check ();

create policy employee_policy on order_assets for all to supervisor
  using ()
  with check ();

-- order_supplies
create policy employee_policy on order_supplies for all to employee
  using ()
  with check ();

create policy supervisor_policy on order_supplies for all to supervisor
  using ()
  with check ();

-- order_messages
create policy employee_policy on order_messages for all to employee
  using ()
  with check ();

create policy supervisor_policy on order_messages for all to supervisor
  using ()
  with check ();

-- assets
create policy employee_policy on assets for all to employee
  using ()
  with check ();

create policy supervisor_policy on assets for all to supervisor
  using ()
  with check ();

-- departments
create policy employee_policy on departments for all to employee
  using ()
  with check ();

create policy supervisor_policy on departments for all to supervisor
  using ()
  with check ();

-- asset_departments
create policy employee_policy on asset_departments for all to employee
  using ()
  with check ();

create policy supervisor_policy on asset_departments for all to supervisor
  using ()
  with check ();

-- contracts
create policy employee_policy on contracts for all to employee
  using ()
  with check ();

create policy supervisor_policy on contracts for all to supervisor
  using ()
  with check ();

-- teams
create policy employee_policy on teams for all to employee
  using ()
  with check ();

create policy supervisor_policy on teams for all to supervisor
  using ()
  with check ();

-- team_persons
create policy employee_policy on team_persons for all to employee
  using ()
  with check ();

create policy supervisor_policy on team_persons for all to supervisor
  using ()
  with check ();

-- persons
create policy employee_policy on persons for all to employee
  using ()
  with check ();

create policy supervisor_policy on persons for all to supervisor
  using ()
  with check ();

-- specs
create policy employee_policy on specs for all to employee
  using ()
  with check ();

create policy supervisor_policy on specs for all to supervisor
  using ()
  with check ();

-- private.accounts
create policy employee_policy on private.accounts for all to employee
  using ()
  with check ();

create policy supervisor_policy on private.accounts for all to supervisor
  using ()
  with check ();

-- private.logs
create policy employee_policy on private.logs for all to employee
  using ()
  with check ();

create policy supervisor_policy on private.logs for all to supervisor
  using ()
  with check ();

---------------------------------------------------------------------------------------
-- rls tests
set local auth.data.person_id to 1;
set role auth;
select current_user;
select * from orders;
rollback;