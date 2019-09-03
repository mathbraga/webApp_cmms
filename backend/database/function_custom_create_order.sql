drop function if exists custom_create_order;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION	custom_create_order (
input_status	text,
input_priority	text,
input_category	text,
input_parent	integer,
input_completed	integer,
input_request_text	text,
input_request_department	text,
input_request_person	text,
input_request_contact_name	text,
input_request_contact_phone	text,
input_request_contact_email	text,
input_request_title	text,
input_request_local	text,
input_ans_factor	real,
input_sigad	text,
input_date_limit	text,
input_date_start	text,
input_contract	text,
input_message	text,
input_assets_array	text[]
)	
returns integer
language plpgsql
AS $$
DECLARE	
  new_order_id	integer;
  assigned_asset text;
BEGIN	
INSERT INTO	orders (
order_id	,
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
) VALUES (	
default,	
input_status::order_status_type,	
input_priority::order_priority_type,	
input_category::order_category_type,	
input_parent,	
input_completed,	
input_request_text,	
input_request_department,	
input_request_person,	
input_request_contact_name,	
input_request_contact_phone,	
input_request_contact_email,	
input_request_title,	
input_request_local,	
input_ans_factor,	
input_sigad,	
input_date_limit::timestamp,	
input_date_start::timestamp,	
now(),
input_contract	
) returning order_id into new_order_id;	

INSERT INTO	orders_messages (
  order_id,
  person_id	,
  message	,
  created_at	,
  updated_at	
) VALUES (	
  new_order_id	,
  current_setting('auth.data.person_id')	,
  input_message	,
  now()	,
  now()	
);	

FOREACH	assigned_asset in array input_assets_array LOOP
  INSERT INTO	orders_assets (
    order_id	,
    asset_id	
  ) VALUES (	
    new_order_id	,
    assigned_asset
  );	
END LOOP;

return new_order_id;	

end;	
$$;
-------------------------------------------------------------------------------
select create_order_custom (
  'R',
  'H',
  'E',
  NULL,
  0,
  'REQUEST TEXT',
  'SINFRA'
  'REQUEST PERSON',
  'request contact name',
  'request_contact_phone',
  'email@email.com',
  'request title',
  'request local',
  1,
  'sigad',
  '2019-10-14',
  '2019-10-12',
  'CT-2014-0088',
  'THIS IS THE MESSAGE',
  {'BL14-MEZ-000', 'BL14-000-000'}
);