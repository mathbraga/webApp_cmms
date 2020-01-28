create or replace function build_asset_json (
  in input_asset_id integer,
  out asset_json jsonb
)
  language sql
  as $$
    select jsonb_build_object(
              'assetId', a.asset_id,
              'assetSf', a.asset_sf,
              'name', a.name,
              'category', aa.name
            ) as asset_json
      from assets as a
      inner join assets as aa on (a.category = aa.asset_id)
    where a.asset_id = input_asset_id
  $$
;

create or replace function build_contract_json (
  in input_contract_id integer,
  out contract_json jsonb
)
  language sql
  as $$
    select jsonb_build_object(
              'contractId', c.contract_id,
              'contractSf', c.contract_sf,
              'title', c.title,
              'description', c.description
            ) as contract_json
      from contracts as c
    where c.contract_id = input_contract_id
  $$
;