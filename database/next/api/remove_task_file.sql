drop function if exists api.remove_task_file;

create or replace function api.remove_task_file (
  inout id integer,
  in file_uuid uuid
)
  language plpgsql
  as $$
    begin
      delete from task_files where task_id = id and uuid = file_uuid;
    end;
  $$
;
