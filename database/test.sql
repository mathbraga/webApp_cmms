begin;

set auth.data.person_id to 1;

create view balances as
  with
    oi as (
      select
        os.contract_id,
        os.supply_id,
        sum(os.qty) as blocked
          from orders as o
          inner join order_supplies as os using (order_id)
        where o.status <> 'CON'
        group by os.contract_id, os.supply_id
    ),
    oc as (
      select
        os.contract_id,
        os.supply_id,
        sum(os.qty) as consumed
          from orders as o
          inner join order_supplies as os using (order_id)
        where o.status = 'CON'
        group by os.contract_id, os.supply_id
    )
    select s.contract_id,
           s.supply_id,
           s.qty_available as qty_initial,
           oi.blocked,
           oc.consumed,
           s.qty_available - (oi.blocked + oc.consumed) as available
      from supplies as s
      inner join oi using (contract_id, supply_id)
      inner join oc using (contract_id, supply_id);

select * from balances;
rollback;