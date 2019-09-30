begin;
drop view if exists balances;
create view balances as
  with
    unfinished as (
      select
        os.contract_id,
        os.supply_id,
        sum(os.qty) as blocked
          from orders as o
          inner join order_supplies as os using (order_id)
      where o.status <> 'CON'
      group by os.contract_id, os.supply_id
    ),
    finished as (
      select
        os.contract_id,
        os.supply_id,
        sum(os.qty) as consumed
          from orders as o
          inner join order_supplies as os using (order_id)
      where o.status = 'CON'
      group by os.contract_id, os.supply_id
    ),
    both_cases as (
      select contract_id,
             supply_id,
             sum(coalesce(blocked, 0)) as blocked,
             sum(coalesce(consumed, 0)) as consumed
        from unfinished as u
        full outer join finished as f using (contract_id, supply_id)
      group by contract_id, supply_id
    )
    select s.contract_id,
           s.supply_id,
           s.qty_initial,
           bc.blocked,
           bc.consumed,
           s.qty_initial - bc.blocked - bc.consumed as available
      from both_cases as bc
      inner join supplies as s using (contract_id, supply_id);

select * from balances;
rollback;
