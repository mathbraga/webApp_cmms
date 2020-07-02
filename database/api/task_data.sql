create or replace view api.task_data as
  with ord_assets as (
    select  ta.task_id,
            a.asset_id,
            a.asset_sf,
            a.name,
            a.category,
            aa.name as category_name
      from task_assets as ta
      inner join assets as a using (asset_id)
      inner join assets as aa on (a.category = aa.asset_id)
    order by a.asset_sf
  ),
  agg_assets as (
    select  a.task_id,
            jsonb_agg(jsonb_build_object(
              'assetId', a.asset_id,
              'assetSf', a.asset_sf,
              'name', a.name,
              'categoryId', a.category,
              'categoryName', a.category_name
            )) as assets
      from ord_assets as a
    group by a.task_id
  ),
  ord_supplies as (
    select  ts.task_id,
            s.supply_id,
            s.supply_sf,
            s.contract_id,
            c.contract_sf,
            c.company,
            ts.qty,
            s.bid_price,
            ts.qty * s.bid_price as total_price,
            z.name,
            z.unit
      from task_supplies as ts
      inner join supplies as s using (supply_id)
      inner join contracts as c using (contract_id)
      inner join specs as z using (spec_id)
    order by s.supply_sf
  ),
  agg_supplies as (
    select  s.task_id,
            jsonb_agg(jsonb_build_object(
              'supplyId', s.supply_id,
              'supplySf', s.supply_sf,
              'contractId', s.contract_id,
              'contractSf', s.contract_sf,
              'company', s.company,
              'qty', s.qty,
              'bidPrice', s.bid_price,
              'totalPrice', s.total_price,
              'name', s.name,
              'unit', s.unit
            )) as supplies
      from ord_supplies as s
    group by s.task_id
  ),
  ord_files as (
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
  agg_files as (
    select  f.task_id,
            jsonb_agg(jsonb_build_object(
              'filename', f.filename,
              'size', f.size,
              'uuid', f.uuid,
              'createdAt', f.created_at,
              'person', f.name
            )) as files
      from ord_files as f
    group by f.task_id
  ),
  ord_events as (
    select  te.task_id,
            te.event_name::text,
            te.event_time,
            p.name as person_name,
            p.person_id,
            t.team_id,
            t.name as team_name,
            tt.team_id as next_team_id,
            tt.name as next_team_name,
            ts.task_status_text,
            ts.task_status_id,
            te.note
      from task_events as te
      inner join persons as p using (person_id)
      inner join teams as t on (t.team_id = te.team_id)
      left join teams as tt on (tt.team_id = te.next_team_id)
      left join task_statuses as ts using (task_status_id)
    order by te.event_time
  ),
  agg_events as (
    select  e.task_id,
            jsonb_agg(jsonb_build_object(
              'eventName', e.event_name,
              'eventTime', e.event_time,
              'personId', e.person_id,
              'personName', e.person_name,
              'teamId', e.team_id,
              'teamName', e.team_name,
              'nextTeamId', e.next_team_id,
              'nextTeamName', e.next_team_name,
              'taskStatusText', e.task_status_text,
              'taskStatusId', e.task_status_id,
              'note', e.note
            )) as events
      from ord_events as e
    group by e.task_id
  ),
  ord_messages as (
    select  tm.task_id,
            tm.task_message_id,
            tm.message,
            tm.reply_to,
            p.person_id,
            p.name,
            tm.created_at,
            tm.updated_at,
            tm.is_visible
      from task_messages as tm
      inner join persons as p using (person_id)
    order by tm.created_at
  ),
  agg_messages as (
    select  m.task_id,
            jsonb_agg(jsonb_build_object(
              'taskMessageId', m.task_message_id,
              'message', m.message,
              'replyTo', m.reply_to,
              'personId', m.person_id,
              'personName', m.name,
              'createdAt', m.created_at,
              'updatedAt', m.updated_at,
              'isVisible', m.is_visible
            )) as messages
      from ord_messages as m
    group by m.task_id
  ),
  ord_send_options as (
    select  t.task_id,
            q.team_id,
            q.name
        from teams as q
        inner join tasks as t on (t.team_id <> q.team_id)
      where q.is_active and t.next_team_id is null
    order by q.name
  ),
  agg_send_options as (
    select  so.task_id,
            jsonb_agg(jsonb_build_object(
              'teamId', so.team_id,
              'name', so.name
            )) as send_options
      from ord_send_options as so
    group by so.task_id
  ),
  ord_move_options as (
    select  t.task_id,
            s.task_status_id,
            s.task_status_text
      from task_statuses as s
      inner join tasks as t on (t.task_status_id <> s.task_status_id)
    order by s.task_status_text
  ),
  agg_move_options as (
    select  mo.task_id,
            jsonb_agg(jsonb_build_object(
              'taskStatusId', mo.task_status_id,
              'taskStatusText', mo.task_status_text
            )) as move_options
      from ord_move_options as mo
    group by mo.task_id
  ),
  ord_supply_options as (
    select  c.contract_id,
            c.contract_sf,
            s.supply_sf,
            jsonb_build_object(
              'supplyId', s.supply_id,
              'supplySf', s.supply_sf,
              'bidPrice', s.bid_price,
              'qtyInitial', b.qty_initial,
              'qtyBlocked', b.qty_blocked,
              'qtyConsumed', b.qty_consumed,
              'qtyAvailable', b.qty_available,
              'name', z.name
            ) as supply
      from contracts as c
      inner join supplies as s using (contract_id)
      inner join balances as b using (supply_id)
      inner join specs as z using (spec_id)
    order by c.contract_sf, s.supply_sf
  ),
  agg_supply_options as (
    select  os.contract_id,
            jsonb_agg(os.supply) as supplies
      from ord_supply_options as os
    group by os.contract_id
  ),
  agg_contract_supply_options as (
    select  jsonb_agg(jsonb_build_object(
              'contractId', aso.contract_id,
              'contractSf', c.contract_sf,
              'title', c.title,
              'company', c.company,
              'supplies', aso.supplies
            )) as supply_options
    from agg_supply_options as aso
    inner join contracts as c using (contract_id)
  ),
  ord_asset_options as (
    select  a.asset_id,
            a.asset_sf,
            a.name
      from assets as a
    order by a.asset_sf
  ),
  agg_asset_options as (
    select  jsonb_agg(jsonb_build_object(
              'assetId', a.asset_id,
              'assetSf', a.asset_sf,
              'name', a.name
            )) as asset_options
    from ord_asset_options as a
  )
  select  
          -- task table fields:
          t.task_id,
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
          t.team_id,
          q.name as team_name,
          t.next_team_id,
          qq.name as next_team_name,
          t.task_status_id,

          -- aditional data from joins:
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
            'name', pr.name
          ) as project,
          jsonb_build_object(
            'requestId', r.request_id,
            'title', r.title
          ) as request,

          -- aggregates from 'with' queries:
          a.assets,
          e.events,
          s.supplies,
          f.files,
          m.messages,
          so.send_options,
          mo.move_options,
          acso.supply_options,
          aa.asset_options
  from tasks as t
  inner join task_statuses as ts using (task_status_id)
  inner join task_priorities as tp using (task_priority_id)
  inner join task_categories as tc using (task_category_id)
  inner join teams as q on (q.team_id = t.team_id)
  inner join persons as p on (t.created_by = p.person_id)
  inner join persons as pp on (t.updated_by = pp.person_id)
  left join contracts as c on (t.contract_id = c.contract_id)
  left join teams as qq on (qq.team_id = t.next_team_id)
  left join projects as pr using (project_id)
  left join requests as r using (request_id)
  left join agg_assets as a using (task_id)
  left join agg_supplies as s using (task_id)
  left join agg_files as f using (task_id)
  left join agg_events as e using (task_id)
  left join agg_messages as m using (task_id)
  left join agg_move_options as mo using (task_id)
  left join agg_send_options as so using (task_id)
  cross join agg_contract_supply_options as acso
  cross join agg_asset_options as aa
;