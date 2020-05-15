drop function if exists api.modify_task;

create or replace function api.modify_task (
  inout id integer,
  in attributes tasks,
  in assets integer[]
)
  language plpgsql
  strict
  as $$
    begin
      update tasks as t
        set (
          task_status_id,
          task_priority_id,
          task_category_id,
          project_id,
          team_id,
          title,
          description,
          -- todo: request fields
          place,
          progress,
          date_limit,
          date_start,
          updated_at
        ) = (
          attributes.task_status_id,
          attributes.task_priority_id,
          attributes.task_category_id,
          attributes.project_id,
          attributes.team_id,
          attributes.title,
          attributes.description,
          -- todo: request fields
          attributes.place,
          attributes.progress,
          attributes.date_limit,
          attributes.date_start,
          default
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
        where ta.task_id = id
              and asset_id in (select asset_id from removed_assets);
    end;
  $$
;
