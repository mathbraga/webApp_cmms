create or replace view api.depot_data as
  with
    supplies_of_depot as (
      select  s.depot_id,
              jsonb_agg(jsonb_build_object(
                'supplyId', s.supply_id,
                'supplySf', s.supply_sf,
                'specSf', z.spec_sf,
                'name', z.name,
                'unit', z.unit,
                'qtyInitial', b.qty_initial,
                'price', s.price,
                'qtyConsumed', b.qty_consumed,
                'qtyBlocked', b.qty_blocked,
                'qtyAvailable', b.qty_available
              )) as supplies
        from supplies as s
        inner join specs as z using (spec_id)
        inner join balances as b using (supply_id)
      group by s.depot_id
    )
  select d.*,
         ds.depot_status_text,
         s.supplies
  from depots as d
  inner join depot_statuses as ds using (depot_status_id)
  left join supplies_of_depot as s using (depot_id)
;
