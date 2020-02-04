create or replace function get_asset_trees (
  in input_asset_id integer,
  out input_asset_id integer,
  out top_id integer,
  out parent_id integer,
  out child_assets jsonb
)
  returns setof record
  language sql
  stable
  as $$
    with recursive rec (top_id, parent_id, asset_id) as (
      select top_id, parent_id, asset_id
        from asset_relations
      where parent_id = input_asset_id
      union
      select a.top_id, a.parent_id, a.asset_id
        from rec as r
        inner join asset_relations as a on (r.asset_id = a.parent_id)
    )
    select input_asset_id,
           r.top_id,
           r.parent_id,
           jsonb_agg(build_asset_json(r.asset_id)) as child_assets
      from rec as r
    group by input_asset_id, r.top_id, r.parent_id
  $$
;

