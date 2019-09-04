drop function if exists custom_create_asset;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION	custom_create_asset (
  input_asset_id text,
  input_parent text,
  input_name text,
  input_description text,
  input_category text,
  input_latitude text,
  input_longitude text,
  input_area text,
  input_manufacturer text,
  input_serialnum text,
  input_model text,
  input_price text,
  input_warranty text,
  input_departments_array text[]
)
returns text
language plpgsql
AS $$
DECLARE	
  new_asset_id text;
  dept text;
BEGIN	

INSERT INTO	assets (
  asset_id,
  parent,
  name,
  description,
  category,
  latitude,
  longitude,
  area,
  manufacturer,
  serialnum,
  model,
  price,
  warranty
) VALUES (	
  input_asset_id,
  input_parent,
  input_name,
  input_description,
  input_category::asset_category_type,
  input_latitude::real,
  input_longitude::real,
  input_area::real,
  input_manufacturer,
  input_serialnum,
  input_model,
  input_price::real,
  input_warranty
) 
returning asset_id into new_asset_id;	

FOREACH	dept IN ARRAY input_departments_array LOOP
  INSERT INTO	assets_departments (
    asset_id,
    department_id
  ) VALUES (	
    new_asset_id	,
    dept
  );
END LOOP;

return new_asset_id;	

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_asset (
  'ZZZZ-000-000',
  'CASF-000-000',
  'input_name',
  'input_description',
  'F',
  '88',
  '99',
  '111.1212',
  'input_manufacturer',
  'input_serialnum',
  'input_model',
  '999.99',
  'GARANTIA',
  ARRAY['SEMAC', 'SEPLAG']
);
commit;