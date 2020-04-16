create view api.task_form_data as
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
    ),
    asset_options as (
      select jsonb_agg(build_asset_json(a.asset_id)) as asset_options
        from assets as a
    )
  select status_options,
         category_options,
         priority_options,
         contract_options,
         project_options,
         team_options,
         asset_options
    from status_options,
         category_options,
         priority_options,
         contract_options,
         project_options,
         team_options,
         asset_options
;

create view api.asset_form_data as
  with
    top_options as (
      select jsonb_agg(build_asset_json(ar.top_id)) as top_options
        from asset_relations as ar
      where parent_id is null
    ),
    parent_options as (
      select jsonb_agg(build_asset_json(a.asset_id)) as parent_options
        from assets as a
    )
  select top_options,
         parent_options
    from top_options,
         parent_options
;

-- create view api.supply_options as
--   select s.supply_id,
--          s.supply_sf,
--          s.contract_id,
--          s.spec_id,
--          s.qty_initial,
--          s.bid_price,
--          s.full_price,
--          z.spec_sf,
--          z.name,
--          z.unit,
--          z.allow_decimals,
--          b.qty_available
--     from supplies as s
--     inner join specs as z using (spec_id)
--     inner join balances as b using (supply_id)
-- ;