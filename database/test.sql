begin;

drop view balances cascade;


create view balances as
  with
    finished as (
      select task_id, supply_id, qty, task_status_id
        from tasks
        inner join task_supplies using (task_id)
      where task_status_id = 7
    ),
    unfinished as (
      select task_id, supply_id, qty, task_status_id
        from tasks
        inner join task_supplies using (task_id)
      where task_status_id <> 7
    ),
    quantities as (
      select s.supply_id,
             s.qty as qty_initial,
             sum(coalesce(f.qty, 0)) as qty_consumed,
             sum(coalesce(u.qty, 0)) as qty_blocked
        from finished as f
        full outer join unfinished as u using (supply_id)
        full outer join supplies as s using (supply_id)
      group by s.supply_id, s.qty
    )
    select *,
           qty_initial - qty_blocked - qty_consumed as qty_available
      from quantities;
      

select * from balances order by supply_id;

rollback;