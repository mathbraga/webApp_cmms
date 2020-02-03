create view task_form_data as
  with
    status_options as (
      select jsonb_agg(build_task_status_json(task_status_id)) as status_options
      from task_statuses
    ),
    category_options as (
      select jsonb_agg(build_task_category_json(task_category_id)) as category_options
      from task_categories
    ),
    priority_options as (
      select jsonb_agg(build_task_priority_json(task_priority_id)) as priority_options
      from task_priorities
    ),
    contract_options as (
      select jsonb_agg(build_contract_json(c.contract_id)) as contract_options
        from contracts as c
      where c.date_end >= current_date
    ),
    project_options as (
      select jsonb_agg(build_project_json(p.project_id)) as project_options
        from projects as p
      where p.is_active
    ),
    team_options as (
      select jsonb_agg(build_team_json(t.team_id)) as team_options
        from teams as t
      where t.is_active
    )
  select status_options,
         category_options,
         priority_options,
         contract_options,
         project_options,
         team_options
    from status_options,
         category_options,
         priority_options,
         contract_options,
         project_options,
         team_options
;

create view supply_options as
  select s.supply_id,
         s.supply_sf,
         s.contract_id,
         s.spec_id,
         s.qty_initial,
         s.bid_price,
         s.full_price,
         z.spec_sf,
         z.name,
         z.unit,
         z.allow_decimals,
         b.qty_available
    from supplies as s
    inner join specs as z using (spec_id)
    inner join balances as b using (supply_id)
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

create view spec_data as
  select z.*,
         zc.spec_category_text,
         zs.spec_subcategory_text,
         s.total_available,
         s.supplies,
         t.tasks
    from specs as z
    inner join spec_categories as zc using (spec_category_id)
    inner join spec_subcategories as zs using (spec_subcategory_id)
    left join supplies_of_spec as s using (spec_id)
    left join tasks_of_spec as t using (spec_id)
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