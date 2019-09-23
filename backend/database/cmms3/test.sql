begin;
----------------------------------------------------
create or replace function modify_order (
  orderid integer,
  order_attributes orders,
  assets_array text[]
)
returns integer
language plpgsql
as $$
begin
  update orders as o
    set (
      status,
      priority,
      category,
      parent,
      contract,
      completed,
      request_text,
      request_department,
      request_person,
      request_contact_name,
      request_contact_phone,
      request_contact_email,
      request_title,
      request_local,
      date_limit,
      date_start,
      updated_at
    ) = (
      order_attributes.status,
      order_attributes.priority,
      order_attributes.category,
      order_attributes.parent,
      order_attributes.contract,
      order_attributes.completed,
      order_attributes.request_text,
      order_attributes.request_department,
      order_attributes.request_person,
      order_attributes.request_contact_name,
      order_attributes.request_contact_phone,
      order_attributes.request_contact_email,
      order_attributes.request_title,
      order_attributes.request_local,
      order_attributes.date_limit,
      order_attributes.date_start,
      now()
    ) where o.order_id = orderid;

  delete from order_assets as oa where oa.order_id = orderid;

  if assets_array is not null then
    insert into order_assets select orderid, unnest(assets_array);
  end if;

  return orderid;

end; $$;
----------------------------------------------------
set local auth.data.person_id to 1;
select modify_order(
  1,
  (
  1,
  'FIL',
  'URG',
  'ARC',
  null,
  null,
  99,
  'request_text',
  'SADCON',
  'request_person',
  'request_contact_name',
  'request_contact_phone',
  'request_contact_email',
  'request_title',
  'request_local',
  '2019-01-01',
  '2019-01-01',
  '2018-09-09',
  '2019-09-09',
  '2019-09-09'
  ),
  ARRAY['CASF-000-000', 'BL14-MEZ-046', 'AX02-AFM-000']
);
select * from orders where order_id = 1;
----------------------------------------------------
rollback;
select * from orders where order_id = 1;