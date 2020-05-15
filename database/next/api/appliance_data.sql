create or replace view api.appliance_data as
  with
    parents_of_asset as (
      select  ar.asset_id,
              jsonb_agg(build_asset_json(ar.parent_id)) as parents
        from asset_relations as ar
        where ar.parent_id is not null
      group by ar.asset_id
    ),
    tasks_of_asset as (
      select  ta.asset_id,
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
    ),
    contexts as (
      select jsonb_agg(build_asset_json(ar.asset_id)) as contexts
        from asset_relations as ar
      where ar.parent_id is null
    )
  select  a.asset_id,
          a.asset_sf,
          a.name,
          a.description,
          aa.asset_id as category_id,
          aa.name as category_name,
          a.manufacturer,
          a.serialnum,
          a.model,
          a.price,
          t.tasks,
          pa.parents,
          g.trees,
          c.contexts
    from assets as a
    inner join assets as aa on (a.category = aa.asset_id)
    left join parents_of_asset as pa on (a.asset_id = pa.asset_id)
    left join get_asset_trees(a.asset_id) as g on (a.asset_id = g.asset_id)
    left join tasks_of_asset as t on (a.asset_id = t.asset_id)
    cross join contexts as c
  where a.category <> 1
;
