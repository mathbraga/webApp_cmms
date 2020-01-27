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

drop_view if exists task_data;

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
           'title', t.title,
           'taskPriorityText', tp.task_priority_text,
           'dateLimit', t.date_limit
         )) as tasks
    from task_assets as ta
    inner join tasks as t using (task_id)
    inner join task_statuses as ts using (task_status_id)
    inner join task_priorities as tp using (task_priority_id)
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
    inner join tasks_of_asset as t on (a.asset_id = t.asset_id)
;

