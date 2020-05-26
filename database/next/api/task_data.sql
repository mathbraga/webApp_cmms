create or replace view api.task_data as
  with
    assets_of_task as (
      select  ta.task_id,
              a.asset_id,
              a.asset_sf,
              a.name,
              a.category,
              aa.name
        from task_assets as ta
        inner join assets as a using (asset_id)
        inner join assets as aa on (a.category = aa.asset_id)
      order by a.asset_sf
    ),
    supplies_of_task as (
      select  ts.task_id,
              s.supply_id,
              s.supply_sf,
              ts.qty,
              s.bid_price,
              ts.qty * s.bid_price as total_price,
              z.name,
              z.unit
        from task_supplies as ts
        inner join supplies as s using (supply_id)
        inner join specs as z using (spec_id)
      order by s.supply_sf
    ),
    files_of_task as (
      select  tf.task_id,
              tf.filename,
              tf.size,
              tf.uuid,
              tf.created_at,
              p.name
        from task_files as tf
        inner join persons as p on (tf.person_id = p.person_id)
      order by tf.filename
    ),
    events_of_task as (
      select  te.task_id,
              te.event_name::text,
              te.event_time,
              p.name as person_name,
              p.person_id,
              t.team_id,
              t.name as team_name,
              tt.team_id as recipient_id,
              tt.name as recipient_name,
              ts.task_status_text,
              ts.task_status_id,
              te.note
              )) as events
        from task_events as te
        inner join persons as p using (person_id)
        inner join teams as t on (te.team_id = t.team_id)
        left join teams as tt on (te.recipient_id = tt.team_id)
        left join task_statuses as ts using (task_status_id)
      order by te.event_time
    ),
    messages_of_task (
      select  tm.task_id,
              tm.message,
              p.person_id,
              p.name,
              tm.created_at,
              tm.updated_at
          from task_messages as tm
          inner join persons as p using (person_id)
        where tm.is_visible
      order by tm.created_at
    ),
    send_options (
      select  t.task_id,
              q.team_id,
              q.name
          from teams as q
          inner join tasks as t on (t.recipient_id <> q.team_id)
        where q.is_active
      order by q.name
    ),
    move_options (
      select  t.task_id,
              s.task_status_id,
              s.task_status_text
        from task_statuses as s
        inner join tasks as t on (t.task_status_id <> s.task_status_id)
      order by s.task_status_text
    ),
    json_lists (
      select  task_id,
              jsonb_agg(jsonb_build_object(
                'assetId', a.asset_id,
                'assetSf', a.asset_sf,
                'name', a.name,
                'categoryId', a.category,
                'categoryName', a.name
              )) as assets,
              jsonb_agg(jsonb_build_object(
                'supplyId', s.supply_id,
                'supplySf', s.supply_sf,
                'qty', s.qty,
                'bidPrice', s.bid_price,
                'totalPrice', s.total_price,
                'name', z.name,
                'unit', z.unit
              )) as supplies,
              jsonb_agg(jsonb_build_object(
                'filename', f.filename,
                'size', f.size,
                'uuid', f.uuid,
                'createdAt', f.created_at,
                'person', f.name
              )) as files,
              jsonb_agg(jsonb_build_object(
                'eventName', e.event_name,
                'eventTime', e.event_time,
                'personId', e.person_id,
                'personName', e.person_name,
                'teamId', e.team_id,
                'teamName', e.team_name,
                'recipientId', e.recipient_id,
                'recipientName', e.recipient_name,
                'taskStatusText', e.task_status_text,
                'taskStatusId', e.task_status_id,
                'note', e.note
              )) as events,
            jsonb_agg(jsonbbuild_object(
              'message', m.message,
              'personId', m.person_id,
              'personName', m.name,
              'createdAt', m.created_at,
              'updatedAt', m.updated_at
            )) as messages,
              jsonb_agg(jsonb_build_object(
                'teamId', so.team_id,
                'name', so.name
              )) as send_options,
              jsonb_agg(jsonb_build_object(
                'taskStatusId', mo.task_status_id,
                'taskStatusText', mo.task_status_text
              )) as move_options
        from assets_of_task as a
        left join supplies_of_task as s using (task_id)
        left join files_of_task as f using (task_id)
        inner join events_of_task as e using (task_id)
        left join messages_of_task as m using (task_id)
        inner join send_options as so using (task_id)
        inner join move_options as mo using (task_id)
      group by task_id
    )
  select  t.task_id,
          t.created_at,
          t.updated_at,
          -- t.created_by,
          -- t.updated_by,
          -- t.task_priority_id,
          -- t.task_category_id,
          -- t.contract_id,
          -- t.project_id,
          t.title,
          t.description,
          t.place,
          t.progress,
          t.date_limit,
          t.date_start,
          t.date_end,
          -- t.request_id,
          t.task_status_id,
          -- t.sender_id,
          -- t.recipient_id,
          -- t.receive_pending
          ts.task_status_text,
          tp.task_priority_text,
          tc.task_category_text,
          jsonb_build_object(
            'personId', p.person_id,
            'personName', p.name
          ) as created_by,
          jsonb_build_object(
            'personId', pp.person_id,
            'personName', pp.name
          ) as updated_by,
          jsonb_build_object(
            'contractId', c.contract_id,
            'title', c.title
          ) as contract,
          jsonb_build_object(
            'projectId', pr.project_id,
            'title', pr.title
          ) as project,
          jsonb_build_object(
            'requestId', r.request_id,
            'title', r.title
          ) as request,
          j.assets,
          j.events,
          j.supplies,
          j.files,
          j.messages,
          j.send_options,
          j.move_options
  from tasks as t
  inner join task_statuses as ts using (task_status_id)
  inner join task_priorities as tp using (task_priority_id)
  inner join task_categories as tc using (task_category_id)
  inner join team as q on (t.recipient_id = q.team_id)
  inner join persons as p on (t.created_by = p.person_id)
  inner join persons as pp on (t.updated_by = pp.person_id)
  left join contracts as c using (contract_id)
  left join projects as pr using (project_id)
  left join requests as r using (request_id)
  inner join json_lists as j using (task_id)
;