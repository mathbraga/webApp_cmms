create or replace view api.contract_data as
  with
    supplies_of_contract as (
      select  s.contract_id,
              jsonb_agg(jsonb_build_object(
                'supplyId', s.supply_id,
                'supplySf', s.supply_sf,
                'name', z.name,
                'unit', z.unit,
                'qtyInitial', b.qty_initial,
                'bidPrice', s.bid_price,
                'qtyConsumed', b.qty_consumed,
                'qtyBlocked', b.qty_blocked,
                'qtyAvailable', b.qty_available
              )) as supplies
        from supplies as s
        inner join specs as z using (spec_id)
        inner join balances as b using (supply_id)
      group by s.contract_id
    )
  select c.*,
         cs.contract_status_text,
         s.supplies
  from contracts as c
  inner join contract_statuses as cs using (contract_status_id)
  inner join supplies_of_contract as s using (contract_id)
;
