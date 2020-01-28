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
