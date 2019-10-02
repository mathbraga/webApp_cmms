begin;

drop function if exists get_delayed_orders;

create or replace function get_delayed_orders ()
returns setof orders
language sql
as $$
  select * from orders where date_limit < now();
$$;

select * from get_delayed_orders();

rollback;
