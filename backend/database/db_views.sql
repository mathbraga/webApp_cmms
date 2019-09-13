DROP VIEW IF EXISTS facilities;
DROP VIEW IF EXISTS appliances;
DROP VIEW IF EXISTS omfrontend;
--------------------------------------------------
CREATE VIEW facilities AS
  SELECT
    asset_id,
    parent,
    name,
    description,
    category,
    latitude,
    longitude,
    area
  FROM assets
  WHERE category = 'F'
  ORDER BY asset_id;
--------------------------------------------------
CREATE VIEW appliances AS
  SELECT
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
  FROM assets
  WHERE category = 'A'
  ORDER BY asset_id;
--------------------------------------------------
CREATE VIEW omfrontend AS
  SELECT
    om.order_id,
    (select (p.name || ' '|| p.surname) from persons as p where person_id = om.person_id) as full_name,
    om.message,
    om.updated_at,
    (current_setting('auth.data.person_id')::integer = om.person_id) as bool
  FROM orders_messages as om;
--------------------------------------------------
  -- begin;
  -- set local auth.data.person_id to 3;
  -- select * from omfrontend where order_id = 16;
  -- commit;