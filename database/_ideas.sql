-- create or replace function get_asset_history (
--   in asset_id integer,
--   out full_name text,
--   out created_at timestamptz,
--   out operation text,
--   out tablename text,
--   out old_row jsonb,
--   out new_row jsonb
-- )
-- returns setof record
-- security definer
-- language sql
-- stable
-- as $$
--   select p.full_name,
--          l.created_at,
--          l.operation,
--          l.tablename,
--          l.old_row,
--          l.new_row
--     from private.logs as l
--     inner join persons as p using (person_id)
--   where (l.tablename = 'assets' or l.tablename = 'asset_departments' or l.tablename = 'task_assets')
--         and
--         (
--           l.new_row @> ('{"asset_id": "' || asset_id || '"}')::jsonb
--           or
--           l.old_row @> ('{"asset_id": "' || asset_id || '"}')::jsonb
--         );
-- $$;

-- create or replace function get_task_history (
--   in task_id integer,
--   out full_name text,
--   out created_at timestamptz,
--   out operation text,
--   out tablename text,
--   out old_row jsonb,
--   out new_row jsonb
-- )
-- returns setof record
-- security definer
-- language sql
-- stable
-- as $$
--   select p.full_name,
--          l.created_at,
--          l.operation,
--          l.tablename,
--          l.old_row,
--          l.new_row
--     from private.logs as l
--     inner join persons as p using (person_id)
--   where (l.tablename = 'tasks' or l.tablename = 'task_assets' or l.tablename = 'task_supplies')
--         and
--         (
--           l.new_row @> ('{"task_id": ' || task_id || '}')::jsonb
--           or
--           l.old_row @> ('{"task_id": ' || task_id || '}')::jsonb
--         );
-- $$;




-- lookup tables
comment on table contract_statuses is E'@omit';
comment on table task_statuses is E'@omit';
comment on table task_priorities is E'@omit';
comment on table task_categories is E'@omit';
comment on table person_roles is E'@omit';
comment on table spec_categories is E'@omit';
comment on table spec_subcategories is E'@omit';

-- tables
comment on table assets is E'@omit';
comment on table asset_relations is E'@omit';
comment on table contracts is E'@omit';
comment on table contract_teams is E'@omit';
comment on table persons is E'@omit';
comment on table projects is E'@omit';
comment on table specs is E'@omit';
comment on table supplies is E'@omit';
comment on table tasks is E'@omit';
comment on table task_assets is E'@omit';
comment on table task_messages is E'@omit';
comment on table task_supplies is E'@omit';
comment on table asset_files is E'@omit';
comment on table task_files is E'@omit';
comment on table team_persons is E'@omit';
comment on table teams is E'@omit';

-- views
comment on view facilities is E'@omit';
comment on view appliances is E'@omit';
comment on view assets_of_task is E'@omit';
comment on view supplies_of_task is E'@omit';
comment on view supplies_of_spec is E'@omit';
comment on view supplies_of_contract is E'@omit';
comment on view files_of_task is E'@omit';
comment on view tasks_of_spec is E'@omit';
comment on view tasks_of_asset is E'@omit';
comment on view balances is E'@omit';

-- functions
comment on function authenticate is E'@omit execute';
comment on function get_all_files_uuids is E'@omit execute';
comment on function refresh_all_materialized_views is E'@omit execute';
comment on function get_exception_message is E'@omit execute';
comment on function build_asset_json is E'@omit execute';
comment on function build_contract_json is E'@omit execute';
comment on function build_team_json is E'@omit execute';
comment on function build_project_json is E'@omit execute';
comment on function build_task_status_json is E'@omit execute';
comment on function build_task_category_json is E'@omit execute';
comment on function build_task_priority_json is E'@omit execute';

-- constraints
comment on constraint assets_pkey on assets is E'@omit';
comment on constraint assets_asset_sf_key on assets is E'@omit';
comment on constraint contracts_pkey on contracts is E'@omit';
comment on constraint contracts_contract_sf_key on contracts is E'@omit';
comment on constraint persons_cpf_key on persons is E'@omit';
comment on constraint persons_email_key on persons is E'@omit';
comment on constraint projects_pkey on projects is E'@omit';
comment on constraint projects_name_key on projects is E'@omit';
comment on constraint teams_name_key on teams is E'@omit';
comment on constraint team_persons_pkey on team_persons is E'@omit';
comment on constraint task_messages_pkey on task_messages is E'@omit';
comment on constraint task_assets_pkey on task_assets is E'@omit';
comment on constraint specs_spec_sf_version_key on specs is E'@omit';
comment on constraint supplies_contract_id_supply_sf_key on supplies is E'@omit';
comment on constraint task_supplies_pkey on task_supplies is E'@omit';



create materialized view dashboard_data as
  with
    t_p as (
      select count(*) as total_pen from tasks where task_status_id = 3
    ),
    t_c as (
      select count(*) as total_con from tasks where task_status_id = 7
    ),
    t_d as (
      select count(*) as total_delayed from tasks where date_limit < now()
    ),
    t_o as (
      select count(*) as total_tasks from tasks where true
    ),
    t_a as (
      select count(*) as total_appliances from assets where category <> 1
    ),
    t_f as (
      select count(*) as total_facilities from assets where category = 1
    )
    select total_con,
           total_pen,
           total_delayed,
           total_tasks,
           total_appliances,
           total_facilities,
           total_appliances + total_facilities as total_assets,
           now() as updated_at
      from t_p
      cross join t_c
      cross join t_d
      cross join t_o
      cross join t_a
      cross join t_f
;


create or replace function refresh_all_materialized_views (
  out refreshed_at timestamptz
)
  language plpgsql
  as $$
    declare
      mviews record;
    begin
      for mviews in
        select n.nspname as mv_schema,
              c.relname as mv_name
          from pg_catalog.pg_class as c
          left join pg_catalog.pg_namespace as n on (n.oid = c.relnamespace)
        where c.relkind = 'm'
      loop
        execute format('refresh materialized view %I.%I', mviews.mv_schema, mviews.mv_name);
      end loop;

      refreshed_at = now();

    end;
  $$
;
