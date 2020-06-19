create or replace view balances as
  with
    finished as (
      select ts.task_id, ts.supply_id, ts.qty, t.task_status_id
        from task_supplies as ts
        inner join tasks as t using (task_id)
      where t.task_status_id >= get_constant_value('task_status_threshold')::integer
    ),
    unfinished as (
      select ts.task_id, ts.supply_id, ts.qty, t.task_status_id
        from task_supplies as ts
        inner join tasks as t using (task_id)
      where t.task_status_id < get_constant_value('task_status_threshold')::integer
    ),
    quantities as (
      select s.supply_id,
             s.qty_initial,
             sum(coalesce(f.qty, 0)) as qty_consumed,
             sum(coalesce(u.qty, 0)) as qty_blocked
        from supplies as s
        full outer join finished as f using (supply_id)
        full outer join unfinished as u using (supply_id)
      group by s.supply_id, s.qty_initial
    )
    select supply_id,
           qty_initial,
           qty_blocked,
           qty_consumed,
           qty_initial - qty_blocked - qty_consumed as qty_available
      from quantities
;
