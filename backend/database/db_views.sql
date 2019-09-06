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
  WHERE category = 'F';

CREATE VIEW equipments AS
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
  WHERE category = 'E';


CREATE VIEW omfrontend AS
  SELECT
    order_id,
    message,
    (current_setting('auth.data.person_id')::integer = orders_messages.person_id) as bool
  FROM orders_messages;

  begin;
  set local auth.data.person_id to 3;
  select * from omfrontend where order_id = 16;
  commit;