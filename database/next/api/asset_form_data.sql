create or replace view api.asset_form_data as
  with
    top_options as (
      select  jsonb_agg(jsonb_build_object(
                'assetId', a.asset_id,
                'assetSf', a.asset_sf,
                'name', a.name
              )) as top_options
        from asset_relations as ar
        inner join assets as a on (a.asset_id = ar.top_id)
      where ar.parent_id is null
    ),
    parent_options as (
      select  jsonb_agg(jsonb_build_object(
                'assetId', a.asset_id,
                'assetSf', a.asset_sf,
                'name', a.name,
                'categoryId', a.category,
                'categoryName', aa.name
              )) as parent_options
      from assets as a
      inner join assets as aa on (aa.asset_id = a.category)
    )
  select top_options,
         parent_options
    from top_options,
         parent_options
;
