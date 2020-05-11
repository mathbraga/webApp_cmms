create or replace function build_asset_json (
  in input_asset_id integer,
  out asset_json jsonb
)
  language sql
  as $$
    select jsonb_build_object(
              'assetId', a.asset_id,
              'assetSf', a.asset_sf,
              'name', a.name,
              'categoryId', a.category,
              'categoryName', aa.name
            ) as asset_json
      from assets as a
      inner join assets as aa on (a.category = aa.asset_id)
    where a.asset_id = input_asset_id
  $$
;

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
              'company', c.company,
              'description', c.description
            ) as contract_json
      from contracts as c
    where c.contract_id = input_contract_id
  $$
;

create or replace function build_team_json (
  in input_team_id integer,
  out team_json jsonb
)
  language sql
  as $$
    select jsonb_build_object(
              'teamId', t.team_id,
              'name', t.name,
              'description', t.description
            ) as team_json
      from teams as t
    where t.team_id = input_team_id
  $$
;

create or replace function build_project_json (
  in input_project_id integer,
  out project_json jsonb
)
  language sql
  as $$
    select jsonb_build_object(
              'projectId', p.project_id,
              'name', p.name,
              'description', p.description
            ) as project_json
      from projects as p
    where p.project_id = input_project_id
  $$
;

create or replace function build_task_status_json (
  in input_task_status_id integer,
  out task_status_json jsonb
)
  language sql
  as $$
    select jsonb_build_object(
            'taskStatusId', task_status_id,
            'taskStatusText', task_status_text
          ) as task_status_json
      from task_statuses
    where task_status_id = input_task_status_id
  $$
;

create or replace function build_task_category_json (
  in input_task_category_id integer,
  out task_category_json jsonb
)
  language sql
  as $$
    select jsonb_build_object(
            'taskCategoryId', task_category_id,
            'taskCategoryText', task_category_text
          ) as task_category_json
      from task_categories
    where task_category_id = input_task_category_id
  $$
;

create or replace function build_task_priority_json (
  in input_task_priority_id integer,
  out task_priority_json jsonb
)
  language sql
  as $$
    select jsonb_build_object(
            'taskPriorityId', task_priority_id,
            'taskPriorityText', task_priority_text
          ) as task_priority_json
      from task_priorities
    where task_priority_id = input_task_priority_id
  $$
;