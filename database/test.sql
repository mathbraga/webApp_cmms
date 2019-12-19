begin;

drop view balances cascade;


create view balances as
  with
    finished as (
      select task_id from tasks where task_status_id = 7
    ),
    unfinished as (
      select task_id from tasks where task_status_id <> 7
    ),
    blocked as (
      select ts.supply_id,
             ts.qty as blocked
        from task_supplies as ts
        inner join unfinished as u using (task_id)
    ),
    consumed as (
      select ts.supply_id,
             ts.qty as consumed
        from task_supplies as ts
        inner join finished as f using (task_id)
    ),
    all_cases as (
      select supply_id,
             sum(coalesce(b.blocked, 0)) as blocked,
             sum(coalesce(c.consumed, 0)) as consumed
        from blocked as b
        full outer join consumed as c using (supply_id)
      group by supply_id
    )
    select s.supply_id,
           s.qty as qty_initial,
           coalesce(a.blocked, 0) as qty_blocked,
           coalesce(a.consumed, 0) as qty_consumed,
           s.qty - coalesce(a.blocked, 0) - coalesce(a.consumed, 0) as qty_available
        from supplies as s
        full outer join all_cases as a using (supply_id)
    order by s.supply_id;
      

select * from balances;


rollback;