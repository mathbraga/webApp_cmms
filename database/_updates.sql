create or replace function build_contract_json (
  in input_contract_id integer,
  out contract_json jsonb
)
  language sql
  as $$
    select jsonb_build_object(
              'contractId', c.contract_id,
              'contractSf', c.contract_sf,
              'title', c.title,
              'description', c.description
            ) as contract_json
      from contracts as c
    where c.contract_id = input_contract_id
  $$
;

create view task_data as
  select t.*,
         ts.task_status_text,
         tp.task_priority_text,
         tc.task_category_text,
         build_contract_json(t.contract_id) as contract,
         a.assets,
         s.supplies,
         f.files
    from tasks as t
    inner join task_statuses as ts using (task_status_id)
    inner join task_priorities as tp using (task_priority_id)
    inner join task_categories as tc using (task_category_id)
    inner join assets_of_task as a using (task_id)
    left join supplies_of_task as s using (task_id)
    left join files_of_task as f using (task_id)
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

create view facility_data as 
  select a.asset_id,
         a.asset_sf,
         a.name,
         a.description,
         aa.name as category_name,
         a.latitude,
         a.longitude,
         a.area,
         t.tasks
    from assets as a
    inner join assets as aa on (a.category = aa.asset_id)
    left join tasks_of_asset as t on (a.asset_id = t.asset_id)
  where a.category = 1
;

create view appliance_data as 
  select a.asset_id,
         a.asset_sf,
         a.name,
         a.description,
         aa.name as category_name,
         a.manufacturer,
         a.serialnum,
         a.model,
         a.price,
         t.tasks
    from assets as a
    inner join assets as aa on (a.category = aa.asset_id)
    left join tasks_of_asset as t on (a.asset_id = t.asset_id)
  where a.category <> 1
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

create view contract_data as
  select c.*,
         cs.contract_status_text,
         s.supplies
    from contracts as c
    inner join contract_statuses as cs using (contract_status_id)
    inner join supplies_of_contract as s using (contract_id)
;

create view team_data as
  select t.team_id, 
         t.name,
         t.description,
         count(*) as member_count,
         jsonb_agg(jsonb_build_object(
           'personId', p.person_id,
           'name', p.name
         )) as members
    from teams as t
    inner join team_persons as tp using (team_id)
    inner join persons as p using (person_id)
  where t.is_active
  group by t.team_id
;


create view person_data as
  select p.*,
         a.is_active,
         a.person_role,
         jsonb_agg(jsonb_build_object(
           'teamId', t.team_id,
           'name', t.name
         )) as teams
    from persons as p
    inner join private.accounts as a using (person_id)
    left join team_persons as tp using (person_id)
    left join teams as t using (team_id)
  group by p.person_id, a.is_active, a.person_role
;


create view supplies_of_spec as
  select z.spec_id,
         sum(b.qty_available) as total_available,
         jsonb_agg(jsonb_build_object(
           'supplyId', s.supply_id,
           'supplySf', s.supply_sf,
           'contractId', c.contract_id,
           'contractSf', c.contract_sf,
           'title', c.title,
           'qtyInitial', b.qty_initial,
           'qtyBlocked', b.qty_blocked,
           'qtyConsumed', b.qty_consumed,
           'qtyAvailable', b.qty_available
         )) as supplies
    from specs as z
    left join supplies as s using (spec_id)
    left join contracts as c using (contract_id)
    left join balances as b using (supply_id)
  group by z.spec_id
;

create view spec_data as
  select z.*,
         zc.spec_category_text,
         zs.spec_subcategory_text,
         s.total_available,
         s.supplies
    from specs as z
    inner join spec_categories as zc using (spec_category_id)
    inner join spec_subcategories as zs using (spec_subcategory_id)
    left join supplies_of_spec as s using (spec_id)
;