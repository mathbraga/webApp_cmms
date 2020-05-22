create or replace view api.task_data as
  with
    assets_of_task as (
      select  ta.task_id,
              jsonb_agg(jsonb_build_object(
                'assetId', a.asset_id,
                'assetSf', a.asset_sf,
                'name', a.name,
                'categoryId', a.category,
                'categoryName', aa.name
              )) as assets
        from task_assets as ta
        inner join assets as a using (asset_id)
        inner join assets as aa on (a.category = aa.asset_id)
      group by ta.task_id
    ),
    supplies_of_task as (
      select  ts.task_id,
              jsonb_agg(jsonb_build_object(
                'supplyId', s.supply_id,
                'supplySf', s.supply_sf,
                'qty', ts.qty,
                'bidPrice', s.bid_price,
                'totalPrice', ts.qty * s.bid_price,
                'name', z.name,
                'unit', z.unit
              )) as supplies
        from task_supplies as ts
        inner join supplies as s using (supply_id)
        inner join specs as z using (spec_id)
      group by ts.task_id
    ),
    files_of_task as (
      select  tf.task_id,
              jsonb_agg(jsonb_build_object(
                'filename', tf.filename,
                'size', tf.size,
                'uuid', tf.uuid,
                'createdAt', tf.created_at,
                'person', p.name
              )) as files
        from task_files as tf
        inner join persons as p on (tf.person_id = p.person_id)
      group by tf.task_id
    ),
    events_of_task as (
      select  te.task_id,
              jsonb_agg(jsonb_build_object(
                'event', te.task_event::text,
                'createdAt', te.created_at::text,
                'personName', p.name,
                'personId', p.person_id,
                'teamName', t.name,
                'teamId', t.name,
                'recipientName', tt.name,
                'recipientId', tt.team_id,
                'taskStatusText', ts.task_status_text,
                'taskStatusId', ts.task_status_id,
                'note', te.note
              )) as events
        from task_events as te
        inner join persons as p using (person_id)
        inner join teams as t on (te.team_id = t.team_id)
        left join teams as tt on (te.recipient_id = tt.team_id)
        left join task_statuses as ts using (task_status_id)
      group by te.task_id
    ),
    send_options (
      select  t.team_id,
              jsonb_agg(jsonb_build_object(
                'teamId', t.team_id,
                'name', t.name
              )) as send_options
          from teams as t
        where t.is_active
      group by t.team_id
    ),
    move_options (
      select  s.task_status_id,
              jsonb_agg(jsonb_build_object(
                'taskStatusId', s.task_status_id,
                'taskStatusText', s.task_status_text
              )) as move_options
        from task_statuses as s
      group by s.task_status_id
    )
  select  t.*,
          tp.task_priority_text,
          tc.task_category_text,
          a.assets,
          e.events,
          s.supplies,
          f.files,
          p.name as project_name,
          r.request_id
  from tasks as t
  inner join task_priorities as tp using (task_priority_id)
  inner join task_categories as tc using (task_category_id)
  inner join assets_of_task as a using (task_id)
  inner join events_of_task as e using (task_id)
  left join supplies_of_task as s using (task_id)
  left join files_of_task as f using (task_id)
  left join projects as p using (project_id)
  left join requests as r using (request_id)
  inner join send_options as so on (so.team_id <> t.recipient_id)
  inner join move_options as mo on (mo.task_status_id <> t.task_status_id)
;