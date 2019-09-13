drop function if exists custom_create_appliance;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION	custom_create_appliance (
  input_appliance_id text,
  input_name text,
  input_description text,
  input_parent text,
  input_place text,
  input_price text,
  input_manufacturer text,
  input_model text,
  input_serialnum text
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE	
  new_appliance_id text;
BEGIN

IF input_description = '' THEN
  input_description = NULL;
END IF;

IF input_price = '' THEN
  input_price = NULL;
END IF;

IF input_manufacturer = '' THEN
  input_manufacturer = NULL;
END IF;

IF input_model = '' THEN
  input_model = NULL;
END IF;

IF input_serialnum = '' THEN
  input_serialnum = NULL;
END IF;

INSERT INTO	assets (
  asset_id,
  name,
  description,
  parent,
  place,
  category,
  price,
  manufacturer,
  model,
  serialnum
) VALUES (	
  input_appliance_id,
  input_name,
  input_description,
  input_parent,
  input_place,
  'A'::asset_category_type,
  input_price::real,
  input_manufacturer,
  input_model,
  input_serialnum
)
returning asset_id into new_appliance_id;

return new_appliance_id;

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_appliance (
  'ZY',
  'input_name',
  'input_description',
  'ACAT-000-QDR-00308',
  'CASF-000-000',
  '99',
  'input_manufacturer',
  'input_model',
  'input_serialnum'
);
delete from assets where asset_id = 'ZY';
commit;