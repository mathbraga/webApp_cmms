create or replace view api.task_form_data as
  with category_options as (
    select  jsonb_agg(jsonb_build_object(
              'taskCategoryId', task_category_id,
              'taskCategoryText', task_category_text
            )) as category_options
    from task_categories
  ),
  priority_options as (
    select  jsonb_agg(jsonb_build_object(
              'taskPriorityId', task_priority_id,
              'taskPriorityText', task_priority_text
            )) as priority_options
    from task_priorities
  ),
  contract_options as (
    select  jsonb_agg(jsonb_build_object(
              'contractId', c.contract_id,
              'contractSf', c.contract_sf,
              'title', c.title,
              'company', c.company,
              'description', c.description
            )) as contract_options
    from contracts as c
  ),
  project_options as (
    select  jsonb_agg(jsonb_build_object(
              'projectId', p.project_id,
              'name', p.name,
              'description', p.description
            )) as project_options
    from projects as p
  ),
  asset_options as (
    select  jsonb_agg(jsonb_build_object(
              'assetId', a.asset_id,
              'assetSf', a.asset_sf,
              'name', a.name,
              'categoryId', a.category,
              'categoryName', aa.name
            )) as asset_options
    from assets as a
    inner join assets as aa on (a.category = aa.asset_id)
  )
  select category_options,
         priority_options,
         contract_options,
         project_options,
         asset_options
    from category_options,
         priority_options,
         contract_options,
         project_options,
         asset_options
;
