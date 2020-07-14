create or replace view api.spec_data as
  with
    supplies_of_spec as (
      select  z.spec_id,
              sum(b.qty_available) as total_available,
              jsonb_agg(jsonb_build_object(
                'supplyId', s.supply_id,
                'supplySf', s.supply_sf,
                'price', s.price,
                'contractId', c.contract_id,
                'contractSf', c.contract_sf,
                'company', c.company,
                'title', c.title,
                'qtyInitial', b.qty_initial,
                'qtyBlocked', b.qty_blocked,
                'qtyConsumed', b.qty_consumed,
                'qtyAvailable', b.qty_available
              )) as supplies
        from specs as z
        inner join supplies as s using (spec_id)
        inner join contracts as c using (contract_id)
        inner join balances as b using (supply_id)
      group by z.spec_id
    ),
    tasks_of_spec as (
      select  z.spec_id,
              jsonb_agg(jsonb_build_object(
                'taskId', t.task_id,
                'title', t.title,
                'place', t.place,
                'taskCategoryText', tc.task_category_text,
                'taskStatusText', tz.task_status_text
              )) as tasks
        from specs as z
        inner join supplies as s using (spec_id)
        inner join task_supplies as ts using (supply_id)
        inner join tasks as t using (task_id)
        inner join task_statuses as tz using (task_status_id)
        inner join task_categories as tc using (task_category_id)
      group by z.spec_id
    )
  select z.*,
         zc.spec_category_text,
         zs.spec_subcategory_text,
         coalesce(s.total_available, 0) as total_available,
         s.supplies,
         t.tasks
  from specs as z
  inner join spec_categories as zc using (spec_category_id)
  inner join spec_subcategories as zs using (spec_subcategory_id)
  left join supplies_of_spec as s using (spec_id)
  left join tasks_of_spec as t using (spec_id)
;
