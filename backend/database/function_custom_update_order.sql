drop function if exists custom_update_order;
-------------------------------------------------------------------------------
create or replace function	custom_update_order (
input_order_id integer,
input_status	text,
input_priority	text,
input_category	text,
input_parent	text,
input_completed	text,
input_request_text	text,
input_request_department	text,
input_request_person	text,
input_request_contact_name	text,
input_request_contact_phone	text,
input_request_contact_email	text,
input_request_title	text,
input_request_local	text,
input_ans_factor	text,
input_sigad	text,
input_date_limit	text,
input_date_start	text,
input_contract	text,
input_message	text,
input_assets_array	text[]
)	
returns integer
language plpgsql
as $$
declare	
  assigned_asset text;
begin	

if input_parent = '' then
  input_parent = null;
end if;

update orders set (
  status	,
  priority	,
  category	,
  parent	,
  completed	,
  request_text	,
  request_department	,
  request_person	,
  request_contact_name	,
  request_contact_phone	,
  request_contact_email	,
  request_title	,
  request_local	,
  ans_factor	,
  sigad	,
  date_limit	,
  date_start	,
  created_at	,
  contract	
) = (	
  input_status::order_status_type,	
  input_priority::order_priority_type,	
  input_category::order_category_type,	
  input_parent::integer,	
  input_completed::integer,	
  input_request_text,	
  input_request_department,	
  input_request_person,	
  input_request_contact_name,	
  input_request_contact_phone,	
  input_request_contact_email,	
  input_request_title,	
  input_request_local,	
  input_ans_factor::real,	
  input_sigad,	
  input_date_limit::timestamp,	
  input_date_start::timestamp,	
  now()::timestamp,
  input_contract	
) where order_id = input_order_id;

insert into	orders_messages (
  order_id,
  person_id	,
  message	,
  created_at	,
  updated_at	
) values (	
  input_order_id	,
  current_setting('auth.data.person_id')::integer,
  input_message	,
  now()::timestamp	,
  now()::timestamp	
);	

foreach	assigned_asset in array input_assets_array loop
  insert into	orders_assets (
    order_id	,
    asset_id	
  ) values (	
    new_order_id	,
    assigned_asset
  );	
end loop;

return new_order_id;	

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_update_order (
  'r',
  'h',
  'e',
  '',
  '0',
  'request text',
  'sinfra',
  'request person',
  'request contact name',
  'request_contact_phone',
  'email@email.com',
  'request title',
  'request local',
  '1',
  'sigad',
  '2019-10-14',
  '2019-10-12',
  'ct-2014-0088',
  'this is the message',
  array['bl14-mez-000', 'bl14-000-000']
);
commit;