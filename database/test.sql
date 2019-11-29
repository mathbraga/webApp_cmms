begin;

drop view if exists order_data;
drop view if exists assets_of_order;
drop view if exists supplies_of_order;
drop view if exists files_of_order;

create view assets_of_order as
select o.order_id,
       jsonb_agg(jsonb_build_object(
           'id', a.asset_id,
           'sf', a.asset_sf,
           'name', a.name
         )) as assets
      from orders as o
      inner join order_assets as oa using (order_id)
      inner join assets as a using (asset_id)
    group by order_id;

create view supplies_of_order as
select o.order_id,
       jsonb_agg(jsonb_build_object(
           'id', s.supply_id,
           'sf', s.supply_sf,
           'qty', os.qty,
           'name', z.name
         )) as supplies
      from orders as o
      inner join order_supplies as os using (order_id)
      inner join supplies as s using (supply_id)
      inner join specs as z using (spec_id)
    group by order_id;

create view files_of_order as
select o.order_id,
       jsonb_agg(jsonb_build_object(
           'filename', of.filename,
           'size', of.size,
           'uuid', of.uuid,
           'createdAt', of.created_at,
           'person', p.name
         )) as files
      from orders as o
      inner join order_files as of using (order_id)
      inner join persons as p using (person_id)
    group by order_id;

create view order_data as
  select o.*,
         a.assets,
         s.supplies,
         f.files
    from orders as o
    inner join assets_of_order as a using (order_id)
    left join supplies_of_order as s using (order_id)
    left join files_of_order as f using (order_id)
;

commit;