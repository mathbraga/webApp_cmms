drop function if exists api.remove_task_file;

create or replace function api.remove_task_file (
  in task_id integer,
  in uuid uuid,
  out id integer
)
  language plpgsql
  as $$
    begin
      delete from task_files as ts
        where ts.task_id = task_id and
              ts.uuid = uuid
      returning ts.task_id into id;
    end;
  $$
;
