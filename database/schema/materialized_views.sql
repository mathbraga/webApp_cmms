create materialized view asset_contexts as
  select  a.asset_id,
          a.asset_sf,
          a.name
    from asset_relations as ar
    inner join assets as a using (asset_id)
  where ar.parent_id is null
;
