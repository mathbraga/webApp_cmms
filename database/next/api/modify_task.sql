drop function if exists api.modify_task;

create or replace function api.modify_task (
  inout id integer,
  in attributes tasks,
  in assets integer[],
  in files_metadata file_metadata[]
)
  language plpgsql
  strict
  as $$
    begin
      update tasks as t
        set (
          updated_at,
          updated_by,
          task_priority_id,
          task_category_id,
          contract_id,
          project_id,
          title,
          description,
          place text,
          progress,
          date_limit,
          date_start,
          date_end,
          request_id
        ) = (
          now(),
          get_current_person_id(),
          attributes.task_priority_id,
          attributes.task_category_id,
          attributes.contract_id,
          attributes.project_id,
          attributes.title,
          attributes.description,
          attributes.place,
          attributes.progress,
          attributes.date_limit,
          attributes.date_start,
          attributes.date_end,
          attributes.request_id
        ) where t.task_id = id;

      with added_assets as (
        select unnest(assets) as asset_id
        except
        select asset_id
          from task_assets as ta
        where ta.task_id = id
      )
      insert into task_assets
        select id, asset_id from added_assets;

      with recursive removed_assets as (
        select asset_id
          from task_assets as ta
        where ta.task_id = id
        except
        select unnest(assets) as asset_id
      )
      delete from task_assets as ta
        where ta.task_id = id and
              asset_id in (select asset_id from removed_assets);

      insert_task_files(id, files_metadata);

    end;
  $$
;
