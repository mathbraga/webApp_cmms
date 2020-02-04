create or replace function api.get_asset_trees (
  in input_asset_id integer,
  out top_asset jsonb,
  out parent_id integer,
  out assets jsonb
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
    select build_asset_json(top_id),
           parent_id,
           jsonb_agg(build_asset_json(r.asset_id)) as assets
      from rec as r
      inner join assets as a on (r.top_id = a.asset_id)
      inner join assets as b on (r.parent_id = b.asset_id)
      inner join assets as c on (r.asset_id = c.asset_id)
    group by r.top_id, r.parent_id
  $$
;