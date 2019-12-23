begin;

create function get_all_files_uuids ()
returns text[]
language plpgsql
as $$
declare
  files_tables record;
  uuid_array text[];
  uuid_array_append text[];
begin
  for files_tables in
    select table_name
      from information_schema.tables
    where table_schema = 'public' and table_name ~ '^.+_files$'
  loop
    raise notice E'\n\nCurrent table: % \n\n', files_tables.table_name;
    execute format('select array_agg(uuid) from %I', quote_ident(files_tables.table_name)) into uuid_array_append;
    uuid_array = array_cat(uuid_array, uuid_array_append);
  end loop;
  return uuid_array;
end; $$;

select * from get_all_files_uuids();

rollback;