drop function if exists api.insert_task_files;

create or replace function api.insert_task_files (
  inout id integer,
  in files_metadata file_metadata[]
)
  language plpgsql
  as $$
    begin
      insert into task_files
        select  id,
                f.filename,
                f.uuid,
                f.size,
                get_current_person_id(),
                now()
        from unnest(files_metadata) as f
      ;
    end;
  $$
;
