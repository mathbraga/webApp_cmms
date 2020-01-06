create or replace function get_asset_tree (top_asset_id integer)
returns setof asset_relations
language sql
stable
as $$
  with recursive rec (top_id, parent_id, asset_id) as (
    select top_id, parent_id, asset_id
      from asset_relations
      where parent_id = top_asset_id
    union
    select a.top_id, a.parent_id, a.asset_id
      from rec as r
      cross join asset_relations as a
    where r.asset_id = a.parent_id
  )
  select top_id, parent_id, asset_id from rec;
$$;

create or replace function get_all_files_uuids ()
returns text[]
language plpgsql
stable
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
    execute format('select array_agg(uuid) from %I', files_tables.table_name) into uuid_array_append;
    uuid_array = array_cat(uuid_array, uuid_array_append);
  end loop;
  return uuid_array;
end; $$;

-- create or replace function get_asset_history (
--   in asset_id integer,
--   out full_name text,
--   out created_at timestamptz,
--   out operation text,
--   out tablename text,
--   out old_row jsonb,
--   out new_row jsonb
-- )
-- returns setof record
-- security definer
-- language sql
-- stable
-- as $$
--   select p.full_name,
--          l.created_at,
--          l.operation,
--          l.tablename,
--          l.old_row,
--          l.new_row
--     from private.logs as l
--     inner join persons as p using (person_id)
--   where (l.tablename = 'assets' or l.tablename = 'asset_departments' or l.tablename = 'task_assets')
--         and
--         (
--           l.new_row @> ('{"asset_id": "' || asset_id || '"}')::jsonb
--           or
--           l.old_row @> ('{"asset_id": "' || asset_id || '"}')::jsonb
--         );
-- $$;

-- create or replace function get_task_history (
--   in task_id integer,
--   out full_name text,
--   out created_at timestamptz,
--   out operation text,
--   out tablename text,
--   out old_row jsonb,
--   out new_row jsonb
-- )
-- returns setof record
-- security definer
-- language sql
-- stable
-- as $$
--   select p.full_name,
--          l.created_at,
--          l.operation,
--          l.tablename,
--          l.old_row,
--          l.new_row
--     from private.logs as l
--     inner join persons as p using (person_id)
--   where (l.tablename = 'tasks' or l.tablename = 'task_assets' or l.tablename = 'task_supplies')
--         and
--         (
--           l.new_row @> ('{"task_id": ' || task_id || '}')::jsonb
--           or
--           l.old_row @> ('{"task_id": ' || task_id || '}')::jsonb
--         );
-- $$;
