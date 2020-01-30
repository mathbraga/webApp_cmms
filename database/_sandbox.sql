begin;

drop view if exists facility_children;

create view facility_children as
  select a.asset_id,
         a.asset_sf,
         a.name,
         a.description,
         aa.name as category_name,
         a.latitude,
         a.longitude,
         a.area,
         t.tasks,
         jsonb_object_agg(at.parent_id, at.assets) as relations
    from assets as a
    inner join assets as aa on (a.category = aa.asset_id)
    left join tasks_of_asset as t on (a.asset_id = t.asset_id)
    cross join get_asset_tree(a.asset_id) as at
    where a.category = 1
    group by (a.asset_id,
              a.asset_sf,
              a.name,
              a.description,
              aa.name,
              a.latitude,
              a.longitude,
              a.area,
              t.tasks)
;

rollback;