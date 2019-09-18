drop view if exists facilities;
drop view if exists appliances;
drop view if exists omfrontend;
--------------------------------------------------
create view facilities as
  select
    asset_id,
    parent,
    name,
    description,
    category,
    latitude,
    longitude,
    area
  from assets
  where category = 'F'
  order by asset_id;
--------------------------------------------------
create view appliances as
  select
    asset_id,
    parent,
    name,
    description,
    category,
    manufacturer,
    serialnum,
    model,
    price,
    warranty,
    place
  from assets
  where category = 'A'
  order by asset_id;
--------------------------------------------------
create view omfrontend as
  select
    om.order_id,
    (select (p.name || ' '|| p.surname) from persons as p where person_id = om.person_id) as full_name,
    om.message,
    om.updated_at,
    (current_setting('auth.data.person_id')::integer = om.person_id) as bool
  from orders_messages as om;
--------------------------------------------------
  -- begin;
  -- set local auth.data.person_id to 3;
  -- select * from omfrontend where order_id = 16;
  -- commit;