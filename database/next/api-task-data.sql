create view api.task_data as
with
  assets_of_task as (
    select  t.task_id,
            jsonb_agg(jsonb_build_object(
              'assetId', a.asset_id,
              'assetSf', a.asset_sf,
              'name', a.name,
              'categoryId', a.category,
              'categoryName', aa.name
            )) as assets
      from tasks as t
      inner join task_assets as ta using (task_id)
      inner join assets as a using (asset_id)
      inner join assets as aa on (a.category = aa.asset_id)
    group by task_id
  ),
  supplies_of_task as (
    select  t.task_id,
            jsonb_agg(jsonb_build_object(
              'supplyId', s.supply_id,
              'supplySf', s.supply_sf,
              'qty', ts.qty,
              'bidPrice', s.bid_price,
              'totalPrice', ts.qty * s.bid_price,
              'name', z.name,
              'unit', z.unit
            )) as supplies
      from tasks as t
      inner join task_supplies as ts using (task_id)
      inner join supplies as s using (supply_id)
      inner join specs as z using (spec_id)
    group by task_id
  ),
  files_of_task as (
    select  t.task_id,
            jsonb_agg(jsonb_build_object(
              'filename', tf.filename,
              'size', tf.size,
              'uuid', tf.uuid,
              'createdAt', tf.created_at,
              'person', p.name
            )) as files
      from tasks as t
      inner join task_files as tf using (task_id)
      inner join persons as p on (tf.person_id = p.person_id)
    group by task_id
  ),
  dispatches_of_task as (

  )
select  t.*,
        ts.task_status_text,
        tp.task_priority_text,
        tc.task_category_text,
        a.assets,
        d.dispatches,
        s.supplies,
        f.files,
        p.name as project_name
  from tasks as t
  inner join task_statuses as ts using (task_status_id)
  inner join task_priorities as tp using (task_priority_id)
  inner join task_categories as tc using (task_category_id)
  inner join assets_of_task as a using (task_id)
  inner join dispatches_of_task as d using (task_id)
  left join supplies_of_task as s using (task_id)
  left join files_of_task as f using (task_id)
  left join projects as p using (project_id)
;