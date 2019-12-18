create view facilities as
  select asset_id,
         asset_sf,
         name,
         description,
         latitude,
         longitude,
         area
    from assets
  where asset_category_id = 1;
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
  where asset_category_id = 2
;

create view balances as
  with
    unfinished as (
      select ts.supply_id,
             sum(ts.qty) as blocked
        from tasks as t
        inner join task_supplies as ts using (task_id)
      where t.task_status_id <> 7
      group by ts.supply_id
    ),
    finished as (
      select ts.supply_id,
             sum(ts.qty) as consumed
        from tasks as t
        inner join task_supplies as ts using (task_id)
      where t.task_status_id = 7
      group by ts.supply_id
    ),
    both_cases as (
      select supply_id,
             sum(coalesce(blocked, 0)) as blocked,
             sum(coalesce(consumed, 0)) as consumed
        from unfinished
        full outer join finished using (supply_id)
      group by supply_id
    )
    select c.contract_id,
           c.contract_sf,
           c.company,
           c.title,
           s.supply_id,
           s.supply_sf,
           s.qty,
           s.spec_id,
           s.bid_price,
           s.full_price,
           z.name,
           z.unit,
           bc.blocked,
           bc.consumed,
           s.qty - bc.blocked - bc.consumed as available
      from both_cases as bc
      inner join supplies as s using (supply_id)
      inner join specs as z using (spec_id)
      inner join contracts as c using (contract_id)
;

create view active_teams as
  select t.team_id, 
         t.name,
         t.description,
         count(*) as member_count
    from teams as t
    inner join team_persons as p using (team_id)
  where t.is_active
  group by t.team_id
;

create view assets_of_task as
  select t.task_id,
         jsonb_agg(jsonb_build_object(
           'assetId', a.asset_id,
           'assetSf', a.asset_sf,
           'name', a.name
         )) as assets
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
           'name', z.name
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

create view task_data as
  select t.*,
         c.contract_sf || ' - ' || c.title as contract,
         a.assets,
         s.supplies,
         f.files
    from tasks as t
    inner join assets_of_task as a using (task_id)
    left join supplies_of_task as s using (task_id)
    left join files_of_task as f using (task_id)
    left join contracts as c using (contract_id)
;

create view supplies_list as
  select s.supply_id,
         s.supply_sf,
         s.contract_id,
         z.name,
         z.unit,
         b.available
    from supplies as s
    inner join specs as z using (spec_id)
    inner join balances as b using (supply_id)
;

create view task_form_data as
  with
    status_options as (
      select
        jsonb_agg(jsonb_build_object(
          'taskStatusId', task_status_id,
          'taskStatusText', task_status_text
        )) as status_options
      from task_statuses
    ),
    category_options as (
      select
        jsonb_agg(jsonb_build_object(
          'taskCategoryId', task_category_id,
          'taskCategoryText', task_category_text
        )) as category_options
      from task_categories
    ),
    priority_options as (
      select
        jsonb_agg(jsonb_build_object(
          'taskPriorityId', task_priority_id,
          'taskPriorityText', task_priority_text
        )) as priority_options
      from task_priorities
    ),
    contract_options as (
      select
        jsonb_agg(jsonb_build_object(
          'contractId', contract_id,
          'contractSf', contract_sf,
          'title', title,
          'company', company
        )) as contract_options
      from contracts
    )
    select status_options,
           category_options,
           priority_options,
           contract_options
      from status_options, category_options, priority_options, contract_options
;
