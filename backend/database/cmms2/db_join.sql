create or replace function testejoin()
returns integer
language sql
immutable
as $$

select  o.order_id,
       message as message,
        name || ' ' || surname
  from orders as o
   right outer join orders_messages using (order_id)-- as om
     left join persons using(person_id)-- as p
  where order_id = 16;

$$;