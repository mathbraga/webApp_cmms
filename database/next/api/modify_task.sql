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
          
        ) = (
          
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
    end;
  $$
;
