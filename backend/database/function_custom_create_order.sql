drop function if exists custom_create_order;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION	custom_create_order (
  input_request_title text,
  input_status text,
  input_priority text,
  input_category text,
  input_request_text text,
  input_date_start text,
  input_date_limit text,
  input_completed text,
  input_parent text,
  input_request_person text,
  input_request_department text,
  input_request_contact_name text,
  input_request_contact_phone text,
  input_request_contact_email text,
  input_assets_array text[]
)
returns integer
language plpgsql
AS $$
DECLARE	
  new_order_id	integer;
  assigned_asset text;
BEGIN	

IF input_date_start = '' THEN
  input_date_start = null;
END IF;

IF input_date_limit = '' THEN
  input_date_limit = null;
END IF;

IF input_completed = '' THEN
  input_completed = null;
END IF;

IF input_parent = '' THEN
  input_parent = null;
END IF;

INSERT INTO	orders (
  order_id,
  request_title,
  status,
  priority,
  category,
  request_text,
  date_start,
  date_limit,
  completed,
  parent,
  request_person,
  request_department,
  request_contact_name,
  request_contact_phone,
  request_contact_email,
  created_at
) VALUES (	
  default,
  input_request_title,
  input_status::order_status_type,
  input_priority::order_priority_type,
  input_category::order_category_type,
  input_request_text,
  input_date_start::timestamp,
  input_date_limit::timestamp,
  input_completed::integer,
  input_parent::integer,
  input_request_person,
  input_request_department,
  input_request_contact_name,
  input_request_contact_phone,
  input_request_contact_email,
  now()
)
returning order_id into new_order_id;

FOREACH	assigned_asset IN ARRAY input_assets_array LOOP
  INSERT INTO	orders_assets (
    order_id,
    asset_id
  ) VALUES (
    new_order_id,
    assigned_asset
  );
END LOOP;

return new_order_id;

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_order (
  'input_request_title',
  'R',
  'H',
  'E',
  'input_request_text',
  '',
  '',
  '0',
  '',
  'input_request_person',
  'SINFRA',
  'input_request_contact_name',
  'input_request_contact_phone',
  'input_request_contact_email',
  ARRAY['CASF-000-000', 'BL01-000-000']
);
commit;