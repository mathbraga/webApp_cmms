create view facilities as
  select
    asset_id,
    asset_sf,
    name,
    description,
    category,
    latitude,
    longitude,
    area
  from assets
  where category = 'F';

create view appliances as
  select
    asset_id,
    asset_sf,
    name,
    description,
    category,
    manufacturer,
    serialnum,
    model,
    price
  from assets
  where category = 'A';

create view balances as
  with
    unfinished as (
      select
        os.supply_id,
        sum(os.qty) as blocked
          from tasks as o
          inner join task_supplies as os using (task_id)
      where o.status <> 'CON'
      group by os.supply_id
    ),
    finished as (
      select
        os.supply_id,
        sum(os.qty) as consumed
          from tasks as o
          inner join task_supplies as os using (task_id)
      where o.status = 'CON'
      group by os.supply_id
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
      inner join contracts as c using (contract_id);

create view spec_tasks as
  select sp.spec_id,
         o.task_id,
         o.status,
         o.title
    from specs as sp
    inner join supplies as su using (spec_id)
    inner join task_supplies as os using (supply_id)
    inner join tasks as o using (task_id);

create view task_supplies_details as
  select o.task_id,
         s.supply_sf,
         z.name,
         z.spec_id,
         o.qty,
         z.unit,
         s.bid_price,
         o.qty * s.bid_price as total
    from task_supplies as o
    inner join supplies as s using (supply_id)
    inner join specs as z using (spec_id);

create view active_teams as
  select t.team_id, 
         t.name,
         t.description,
         count(*) as member_count
    from teams as t
    inner join team_persons as p using (team_id)
  where t.is_active
  group by t.team_id;


create view assets_of_task as
select o.task_id,
       jsonb_agg(jsonb_build_object(
           'id', a.asset_id,
           'sf', a.asset_sf,
           'name', a.name
         )) as assets
      from tasks as o
      inner join task_assets as oa using (task_id)
      inner join assets as a using (asset_id)
    group by task_id;

create view supplies_of_task as
select o.task_id,
       jsonb_agg(jsonb_build_object(
           'id', s.supply_id,
           'sf', s.supply_sf,
           'qty', os.qty,
           'name', z.name
         )) as supplies
      from tasks as o
      inner join task_supplies as os using (task_id)
      inner join supplies as s using (supply_id)
      inner join specs as z using (spec_id)
    group by task_id;

create view files_of_task as
select o.task_id,
       jsonb_agg(jsonb_build_object(
           'filename', of.filename,
           'size', of.size,
           'uuid', of.uuid,
           'createdAt', of.created_at,
           'person', p.name
         )) as files
      from tasks as o
      inner join task_files as of using (task_id)
      inner join persons as p on (of.person_id = p.person_id)
    group by task_id;

create view task_data as
  select o.*,
         c.contract_sf || ' - ' || c.title as contract,
         a.assets,
         s.supplies,
         f.files
    from tasks as o
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
         inner join balances as b using (supply_id);

create view assets_trees as
  with recursive asset_tree (top_id, parent_id, asset_id) as (
    select top_id, parent_id, asset_id
      from asset_relations
    union
    select ar.top_id, ar.parent_id, ar.asset_id
      from asset_tree as atree
        cross join asset_relations as ar
      where atree.asset_id = ar.parent_id
  )
    select top_id, parent_id, asset_id
      from asset_tree;