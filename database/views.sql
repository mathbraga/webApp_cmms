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

create view balances as
  with
    finished as (
      select task_id, supply_id, qty, task_status_id
        from tasks
        inner join task_supplies using (task_id)
      where task_status_id = 7
    ),
    unfinished as (
      select task_id, supply_id, qty, task_status_id
        from tasks
        inner join task_supplies using (task_id)
      where task_status_id <> 7
    ),
    quantities as (
      select s.supply_id,
             s.qty_initial,
             sum(coalesce(f.qty, 0)) as qty_consumed,
             sum(coalesce(u.qty, 0)) as qty_blocked
        from finished as f
        full outer join unfinished as u using (supply_id)
        full outer join supplies as s using (supply_id)
      group by s.supply_id, s.qty_initial
    )
    select supply_id,
           qty_initial,
           qty_blocked,
           qty_consumed,
           qty_initial - qty_blocked - qty_consumed as qty_available
      from quantities
;

create view assets_of_task as
  select t.task_id,
         jsonb_agg(build_asset_json(a.asset_id)) as assets
    from tasks as t
    inner join task_assets as ta using (task_id)
    inner join assets as a using (asset_id)
  group by task_id
;

create view supplies_of_task as
  select t.task_id,
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
;

create view files_of_task as
  select t.task_id,
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
;

create view tasks_of_asset as
  select ta.asset_id,
         jsonb_agg(jsonb_build_object(
           'taskId', ta.task_id,
           'taskStatusText', ts.task_status_text,
           'taskPriorityText', tp.task_priority_text,
           'taskCategoryText', tc.task_category_text,
           'title', t.title,
           'dateLimit', t.date_limit
         )) as tasks
    from task_assets as ta
    inner join tasks as t using (task_id)
    inner join task_statuses as ts using (task_status_id)
    inner join task_priorities as tp using (task_priority_id)
    inner join task_categories as tc using (task_category_id)
  group by ta.asset_id
;

create view supplies_of_contract as
  select s.contract_id,
         jsonb_agg(jsonb_build_object(
           'supplyId', s.supply_id,
           'supplySf', s.supply_sf,
           'name', z.name,
           'unit', z.unit,
           'qtyInitial', b.qty_initial,
           'bidPrice', s.bid_price,
           'qtyConsumed', b.qty_consumed,
           'qtyBlocked', b.qty_blocked,
           'qtyAvailable', b.qty_available
         )) as supplies
    from supplies as s
    inner join specs as z using (spec_id)
    inner join balances as b using (supply_id)
  group by s.contract_id
;

create view supplies_of_spec as
  select z.spec_id,
         sum(b.qty_available) as total_available,
         jsonb_agg(jsonb_build_object(
           'supplyId', s.supply_id,
           'supplySf', s.supply_sf,
           'bidPrice', s.bid_price,
           'fullPrice', s.full_price,
           'contractId', c.contract_id,
           'contractSf', c.contract_sf,
           'company', c.company,
           'title', c.title,
           'qtyInitial', b.qty_initial,
           'qtyBlocked', b.qty_blocked,
           'qtyConsumed', b.qty_consumed,
           'qtyAvailable', b.qty_available
         )) as supplies
    from specs as z
    inner join supplies as s using (spec_id)
    inner join contracts as c using (contract_id)
    inner join balances as b using (supply_id)
  group by z.spec_id
;

create view tasks_of_spec as
  select z.spec_id,
         jsonb_agg(jsonb_build_object(
           'taskId', t.task_id,
           'title', t.title,
           'place', t.place,
           'taskCategoryText', tc.task_category_text,
           'taskStatusText', tz.task_status_text
         )) as tasks
    from specs as z
    inner join supplies as s using (spec_id)
    inner join task_supplies as ts using (supply_id)
    inner join tasks as t using (task_id)
    inner join task_statuses as tz using (task_status_id)
    inner join task_categories as tc using (task_category_id)
  group by z.spec_id
;