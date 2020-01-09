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
      inner join t_c on true
      inner join t_d on true
      inner join t_o on true
      inner join t_a on true
      inner join t_f on true
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