begin;

create or replace function get_children_assets (
  in parent_id text,
  out asset_id text,
  out parent text
)
returns setof record
language sql
stable
as $$
  with recursive asset_tree (asset_id, parent) as (
    select asset_id, parent
      from assets
      where parent = parent_id
    union
    select a.asset_id, a.parent
      from asset_tree as atree
        cross join assets as a
      where atree.asset_id = a.parent
  )
  select * from asset_tree;
$$;

select * from get_children_assets('BL14-MEZ-000');

rollback;