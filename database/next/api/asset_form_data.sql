create or replace view api.asset_form_data as
  with
    top_options as (
      select jsonb_agg(build_asset_json(ar.top_id)) as top_options
        from asset_relations as ar
      where parent_id is null
    ),
    parent_options as (
      select jsonb_agg(build_asset_json(a.asset_id)) as parent_options
        from assets as a
    )
  select top_options,
         parent_options
    from top_options,
         parent_options
;
