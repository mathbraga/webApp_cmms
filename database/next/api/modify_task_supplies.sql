drop function if exists api.modify_task_supplies;

create or replace function api.modify_task_supplies (
  in args task_supplies,
  inout id integer
)
  language plpgsql
  as $$
    begin
      -- remove old supplies
      delete from task_supplies where task_id = id;
      -- insert new supplies
      insert into task_supplies
        select  id,
                (unnest(args)).supply_id,
                (unnest(args)).qty
      ;
    end;
  $$
;
