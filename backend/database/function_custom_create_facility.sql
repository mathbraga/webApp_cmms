drop function if exists custom_create_facility;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION	custom_create_facility (
  input_facility_id text,
  input_name text,
  input_description text,
  input_parent text,
  input_area text,
  input_latitude text,
  input_longitude text,
  input_departments_array text[]
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE	
  new_facility_id text;
  dept text;
BEGIN

IF input_description = '' THEN
  input_description = NULL;
END IF;

IF input_area = '' THEN
  input_area = NULL;
END IF;

IF input_latitude = '' THEN
  input_latitude = NULL;
END IF;

IF input_longitude = '' THEN
  input_longitude = NULL;
END IF;

INSERT INTO	assets (
  asset_id,
  name,
  description,
  parent,
  area,
  latitude,
  longitude,
  category,
  place
) VALUES (	
  input_facility_id,
  input_name,
  input_description,
  input_parent,
  input_area::real,
  input_latitude::real,
  input_longitude::real,
  'F'::asset_category_type,
  input_parent
)
returning asset_id into new_facility_id;

FOREACH	dept IN ARRAY input_departments_array::text[] LOOP
  INSERT INTO	assets_departments (
    asset_id,
    department_id
  ) VALUES (	
    new_facility_id,
    dept
  );
END LOOP;

return new_facility_id;

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_facility (
  'input_facility_id',
  'input_name',
  'input_description',
  'CASF-000-000',
  '999',
  '99',
  '99',
  ARRAY['SEMAC', 'SEPLAG']
);
commit;