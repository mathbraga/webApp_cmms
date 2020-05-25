drop function if exists api.bind_supplies_to_task;

create or replace function api.bind_supplies_to_task (
  inout id integer,
  in supplies integer[],
  in quantities numeric[]
)
  language plpgsql
  as $$
    begin
      -- remove old supplies
      delete from task_supplies where task_id = id;
      -- insert new supplies
      insert into task_supplies
        select  id,
                unnest(supplies),
                unnest(quantities)
      ;
    end;
  $$
;
