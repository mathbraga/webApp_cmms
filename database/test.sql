begin;

set auth.data.person_id to 1;

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
      select s.contract_id,
             s.supply_id,
             s.qty_available as qty_initial,
             coalesce(unfinished.blocked, 0) as blocked,
             coalesce(finished.consumed, 0) as consumed
        from supplies as s,
             inner join unfinished using (contract_id, supply_id)
             full outer join finished using (contract_id, supply_id)
        group by contract_id, supply_id;
    )
    select *,
           qty_initial - blocked - consumed
      from both_cases;

select * from balances;
rollback;