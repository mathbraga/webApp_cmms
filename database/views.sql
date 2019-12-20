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
             s.qty as qty_initial,
             sum(coalesce(f.qty, 0)) as qty_consumed,
             sum(coalesce(u.qty, 0)) as qty_blocked
        from finished as f
        full outer join unfinished as u using (supply_id)
        full outer join supplies as s using (supply_id)
      group by s.supply_id, s.qty
    )
    select supply_id,
           qty_initial,
           qty_blocked,
           qty_consumed,
           qty_initial - qty_blocked - qty_consumed as qty_available
      from quantities
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
         b.qty_available
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
