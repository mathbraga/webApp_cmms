create view facilities as
  select asset_id,
         asset_sf,
         name,
         description,
         latitude,
         longitude,
         area
    from assets
  where category = 1;
;

create view appliances as
  select asset_id,
         asset_sf,
         name,
         description,
         manufacturer,
         serialnum,
         model,
         price
    from assets
  where category <> 1
;

-- create view balances as
--   with
--     finished as (
--       select task_id, supply_id, qty, task_status_id
--         from tasks
--         inner join task_supplies using (task_id)
--       where task_status_id = 7
--     ),
--     unfinished as (
--       select task_id, supply_id, qty, task_status_id
--         from tasks
--         inner join task_supplies using (task_id)
--       where task_status_id <> 7
--     ),
--     quantities as (
--       select s.supply_id,
--              s.qty_initial,
--              sum(coalesce(f.qty, 0)) as qty_consumed,
--              sum(coalesce(u.qty, 0)) as qty_blocked
--         from supplies as s
--         full outer join finished as f using (supply_id)
--         full outer join unfinished as u using (supply_id)
--       group by s.supply_id, s.qty_initial
--     )
--     select supply_id,
--            qty_initial,
--            qty_blocked,
--            qty_consumed,
--            qty_initial - qty_blocked - qty_consumed as qty_available
--       from quantities
-- ;

-- create view tasks_of_asset as
--   select ta.asset_id,
--          jsonb_agg(jsonb_build_object(
--            'taskId', ta.task_id,
--            'taskStatusText', ts.task_status_text,
--            'taskPriorityText', tp.task_priority_text,
--            'taskCategoryText', tc.task_category_text,
--            'title', t.title,
--            'dateLimit', t.date_limit
--          )) as tasks
--     from task_assets as ta
--     inner join tasks as t using (task_id)
--     inner join task_statuses as ts using (task_status_id)
--     inner join task_priorities as tp using (task_priority_id)
--     inner join task_categories as tc using (task_category_id)
--   group by ta.asset_id
-- ;

-- create view supplies_of_contract as
--   select s.contract_id,
--          jsonb_agg(jsonb_build_object(
--            'supplyId', s.supply_id,
--            'supplySf', s.supply_sf,
--            'name', z.name,
--            'unit', z.unit,
--            'qtyInitial', b.qty_initial,
--            'bidPrice', s.bid_price,
--            'qtyConsumed', b.qty_consumed,
--            'qtyBlocked', b.qty_blocked,
--            'qtyAvailable', b.qty_available
--          )) as supplies
--     from supplies as s
--     inner join specs as z using (spec_id)
--     inner join balances as b using (supply_id)
--   group by s.contract_id
-- ;

-- create view supplies_of_spec as
--   select z.spec_id,
--          sum(b.qty_available) as total_available,
--          jsonb_agg(jsonb_build_object(
--            'supplyId', s.supply_id,
--            'supplySf', s.supply_sf,
--            'bidPrice', s.bid_price,
--            'fullPrice', s.full_price,
--            'contractId', c.contract_id,
--            'contractSf', c.contract_sf,
--            'company', c.company,
--            'title', c.title,
--            'qtyInitial', b.qty_initial,
--            'qtyBlocked', b.qty_blocked,
--            'qtyConsumed', b.qty_consumed,
--            'qtyAvailable', b.qty_available
--          )) as supplies
--     from specs as z
--     inner join supplies as s using (spec_id)
--     inner join contracts as c using (contract_id)
--     inner join balances as b using (supply_id)
--   group by z.spec_id
-- ;

-- create view tasks_of_spec as
--   select z.spec_id,
--          jsonb_agg(jsonb_build_object(
--            'taskId', t.task_id,
--            'title', t.title,
--            'place', t.place,
--            'taskCategoryText', tc.task_category_text,
--            'taskStatusText', tz.task_status_text
--          )) as tasks
--     from specs as z
--     inner join supplies as s using (spec_id)
--     inner join task_supplies as ts using (supply_id)
--     inner join tasks as t using (task_id)
--     inner join task_statuses as tz using (task_status_id)
--     inner join task_categories as tc using (task_category_id)
--   group by z.spec_id
-- ;

create view parents_of_asset as
  select ar.asset_id,
         jsonb_agg(build_asset_json(ar.parent_id)) as parents
    from asset_relations as ar
    where ar.parent_id is not null
  group by ar.asset_id
;

create view contexts as
  select jsonb_agg(build_asset_json(ar.asset_id)) as contexts
    from asset_relations as ar
  where ar.parent_id is null
;

create view dispatches_of_task as
  with
    cte as (
      select td.task_id,
             p.name,
             tt.name as sent_by,
             ttt.name as sent_to,
             td.sent_at,
             td.received_at,
             td.note
        from task_dispatches as td
        inner join persons as p using (person_id)
        inner join teams as tt on (td.sent_by = tt.team_id)
        inner join teams as ttt on (td.sent_to = ttt.team_id)
      order by td.sent_at
    )
  select cte.task_id,
         jsonb_agg(jsonb_build_object(
          'name', cte.name,
          'sentBy', cte.name,
          'sentTo', cte.name,
          'sentAt', cte.sent_at,
          'receivedAt', cte.received_at,
          'note', cte.note
         )) as dispatches
    from cte as cte
  group by cte.task_id
;

create view status_of_task as
  with
    cte as (
      select tsu.task_id,
             tsu.updated_at,
             p.name,
             tsu.task_status_id,
             ts.task_status_text,
             tsu.note
        from task_status_updates as tsu
        inner join persons as p using (person_id)
        inner join task_statuses as ts using (task_status_id)
      order by tsu.updated_at
    )
  select cte.task_id,
         jsonb_agg(jsonb_build_object(
          'name', cte.name,
          'updatedAt', cte.updated_at,
          'taskStatusId', cte.task_status_id,
          'taskStatusText', cte.task_status_text,
          'note', cte.note
         )) as statuses
    from cte as cte
  group by cte.task_id
;

