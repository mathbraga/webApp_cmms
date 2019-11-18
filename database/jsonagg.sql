begin;

create view jsontest as
  select o.order_id,
         o.status,
         jsonb_agg(jsonb_build_object(
           'id', s.supply_id,
           'sf', s.supply_sf,
           'qty', os.qty
         )) as jsonsups
    from orders as o
    inner join order_supplies as os using (order_id)
    inner join supplies as s using (supply_id)
  group by o.order_id;

select * from jsontest where order_id = 1;

rollback;
