drop function if exists api.modify_task_supplies;

create or replace function api.modify_task_supplies (
  in args task_supplies,
  out id integer
)
  language plpgsql
  as $$
    begin
      -- remove old supplies
      delete from task_supplies
        where task_id = args.task_id
      returning task_id into id;
      -- insert new supplies
      insert into task_supplies
        select  args.task_id,
                (unnest(args.supplies)).supply_id,
                (unnest(args.supplies)).qty
      ;
    end;
  $$
;
