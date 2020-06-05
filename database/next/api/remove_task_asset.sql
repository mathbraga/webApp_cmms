drop function if exists api.remove_task_asset;

create or replace function api.remove_task_asset (
  in task_id integer,
  in asset_id integer,
  out id integer
)
  language plpgsql
  as $$
    declare
      line_count integer;
    begin

      delete from task_assets as ta
      where ta.task_id = task_id and ta.asset_id = asset_id;

      select count(*) into line_count
        from task_assets as ta
      where ta.task_id = task_id;

      if line_count = 0
        then raise exception '%', get_exception_message(1);
        else id = task_id;
      end if;

    end;
  $$
;
