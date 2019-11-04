begin;

create view spec_orders as
  select sp.spec_id,
         o.order_id,
         o.status,
         o.title
    from specs as sp
    inner join supplies as su using (spec_id)
    inner join order_supplies as os using (supply_id)
    inner join orders as o using (order_id);

select * from spec_orders where spec_id = 559;

rollback;