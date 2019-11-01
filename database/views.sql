create view facilities as
  select
    asset_id,
    asset_sf,
    name,
    description,
    category,
    latitude,
    longitude,
    area
  from assets
  where category = 'F';

create view appliances as
  select
    asset_id,
    asset_sf,
    name,
    description,
    category,
    manufacturer,
    serialnum,
    model,
    price
  from assets
  where category = 'A';

create view balances as
  with
    unfinished as (
      select
        os.supply_id,
        sum(os.qty) as blocked
          from orders as o
          inner join order_supplies as os using (order_id)
      where o.status <> 'CON'
      group by os.supply_id
    ),
    finished as (
      select
        os.supply_id,
        sum(os.qty) as consumed
          from orders as o
          inner join order_supplies as os using (order_id)
      where o.status = 'CON'
      group by os.supply_id
    ),
    both_cases as (
      select supply_id,
             sum(coalesce(blocked, 0)) as blocked,
             sum(coalesce(consumed, 0)) as consumed
        from unfinished
        full outer join finished using (supply_id)
      group by supply_id
    )
    select c.contract_sf,
           c.company,
           c.title,
           s.supply_sf,
           s.qty,
           bc.blocked,
           bc.consumed,
           s.qty - bc.blocked - bc.consumed as available
      from both_cases as bc
      inner join supplies as s using (supply_id)
      inner join contracts as c using (contract_id);