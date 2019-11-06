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
    select c.contract_id,
           c.contract_sf,
           c.company,
           c.title,
           s.supply_id,
           s.supply_sf,
           s.qty,
           s.spec_id,
           s.bid_price,
           s.full_price,
           z.name,
           z.unit,
           bc.blocked,
           bc.consumed,
           s.qty - bc.blocked - bc.consumed as available
      from both_cases as bc
      inner join supplies as s using (supply_id)
      inner join specs as z using (spec_id)
      inner join contracts as c using (contract_id);

create view spec_orders as
  select sp.spec_id,
         o.order_id,
         o.status,
         o.title
    from specs as sp
    inner join supplies as su using (spec_id)
    inner join order_supplies as os using (supply_id)
    inner join orders as o using (order_id);

create view order_supplies_details as
  select o.order_id,
         s.supply_sf,
         z.name,
         z.spec_id,
         o.qty,
         z.unit,
         s.bid_price,
         o.qty * s.bid_price as total
    from order_supplies as o
    inner join supplies as s using (supply_id)
    inner join specs as z using (spec_id);

create view active_teams as
  select t.team_id, 
         t.name,
         t.description,
         count(*) as member_count
    from teams as t
    inner join team_persons as p using (team_id)
  where t.is_active
  group by t.team_id;


