begin;

drop view spec_data;

create view supplies_of_spec as
  select z.spec_id,
         jsonb_agg(jsonb_build_object(
           'supplyId', s.supply_id,
           'supplySf', s.supply_sf,
           'contractId', c.contract_id,
           'contractSf', c.contract_sf,
           'title', c.title,
           'qtyInitial', b.qty_initial,
           'qtyBlocked', b.qty_blocked,
           'qtyConsumed', b.qty_consumed,
           'qtyAvailable', b.qty_available
         )) as supplies
    from specs as z
    left join supplies as s using (spec_id)
    left join contracts as c using (contract_id)
    left join balances as b using (supply_id)
  group by z.spec_id
;

create view spec_data as
  select z.*,
         zc.spec_category_text,
         zs.spec_subcategory_text,
         s.supplies
    from specs as z
    inner join spec_categories as zc using (spec_category_id)
    inner join spec_subcategories as zs using (spec_subcategory_id)
    left join supplies_of_spec as s using (spec_id)
;


select supplies from spec_data;

rollback;