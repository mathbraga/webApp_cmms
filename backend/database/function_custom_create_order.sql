drop function if exists custom_create_order;
-------------------------------------------------------------------------------
create or replace function	custom_create_order (
  order_attributes orders,
  assets_array text[]
)
returns integer
language plpgsql
strict -- this is to force no null inputs (must have assigned assets in order)
as $$
declare	
  new_order_id	 integer;
  assigned_asset text;
begin

insert into	orders (
    order_id,
    status,
    priority,
    category,
    parent,
    completed,
    request_text,
    request_department,
    request_person,
    request_contact_name,
    request_contact_phone,
    request_contact_email,
    request_title,
    request_local,
    ans_factor,
    sigad,
    date_limit,
    date_start,
    created_at,
    contract
) values (
    default,
    order_attributes.status,
    order_attributes.priority,
    order_attributes.category,
    order_attributes.parent,
    order_attributes.completed,
    order_attributes.request_text,
    order_attributes.request_department,
    order_attributes.request_person,
    order_attributes.request_contact_name,
    order_attributes.request_contact_phone,
    order_attributes.request_contact_email,
    order_attributes.request_title,
    order_attributes.request_local,
    order_attributes.ans_factor,
    order_attributes.sigad,
    order_attributes.date_limit,
    order_attributes.date_start,
    default,
    order_attributes.contract
) returning order_id into new_order_id;

-- if assets_array is not null then
foreach	assigned_asset in array assets_array loop
  insert into	orders_assets (
    order_id,
    asset_id
  ) values (
    new_order_id,
    assigned_asset
  );
end loop;
-- end if;

return new_order_id;

end; $$;
--------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_order (
  (
    null,
    'PEN',
    'URG',
    'ELE',
    null,
    0,
    'request_text',
    'SINFRA',
    'request_person',
    'request_contact_name',
    'request_contact_phone',
    'request_contact_email',
    'request_title',
    'request_local',
    323,
    'sigad',
    null,
    null,
    now()::timestamp,
    null
  ),
  ARRAY['CASF-000-000']
);
commit;