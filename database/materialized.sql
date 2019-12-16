create materialized view dashboard_data as
  with
    t_p as (
      select count(*) as total_pen from tasks where status = 'PEN'
    ),
    t_c as (
      select count(*) as total_con from tasks where status = 'CON'
    ),
    t_d as (
      select count(*) as total_delayed from tasks where date_limit < now()
    ),
    t_o as (
      select count(*) as total_tasks from tasks where true
    ),
    t_a as (
      select count(*) as total_appliances from assets where category = 'A'
    ),
    t_f as (
      select count(*) as total_facilities from assets where category = 'F'
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