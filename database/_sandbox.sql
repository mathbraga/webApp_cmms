begin;

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
         at.parent_id,
         at.assets
    from assets as a
    inner join assets as aa on (a.category = aa.asset_id)
    left join tasks_of_asset as t on (a.asset_id = t.asset_id)
    left join get_asset_tree(a.asset_id) as at on (a.asset_id = at.parent_id)
  where a.category = 1
;

rollback;