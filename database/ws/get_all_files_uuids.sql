drop function if exists ws.get_all_files_uuids;

create or replace function ws.get_all_files_uuids (
  out uuids_result text[]
)
  language plpgsql
  stable
  as $$
    declare
      files_tables record;
      uuids_result uuid[];
      uuids_to_append uuid[];
    begin
      for files_tables in
        select table_name
          from information_schema.tables
        where table_schema = 'public' and table_name ~ '^.+_files$'
      loop
        raise notice E'\n\nCurrent table: % \n\n', files_tables.table_name;
        execute format('select array_agg(uuid) from %I', files_tables.table_name) into uuids_to_append;
        uuids_result = array_cat(uuids_result, uuids_to_append);
      end loop;
    end;
  $$
;
