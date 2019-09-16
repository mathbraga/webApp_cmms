drop function if exists custom_create_order;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION	custom_create_order (
  order_attributes orders,
  assets_array text[]
)
returns integer
language plpgsql
strict -- THIS IS TO FORCE NO NULL INPUTS (MUST HAVE ASSIGNED ASSETS IN ORDER)
AS $$
DECLARE	
  new_order_id	 integer;
  assigned_asset text;
BEGIN

INSERT INTO	orders (
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
) VALUES (
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
FOREACH	assigned_asset IN ARRAY assets_array LOOP
  INSERT INTO	orders_assets (
    order_id,
    asset_id
  ) VALUES (
    new_order_id,
    assigned_asset
  );
END LOOP;
-- end if;

return new_order_id;

end; $$;