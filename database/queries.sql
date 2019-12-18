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

-- create or replace function get_ ()
-- returns
-- language sql
-- stable
-- as $$

-- $$;