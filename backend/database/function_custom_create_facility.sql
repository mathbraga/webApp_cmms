drop function if exists custom_create_facility;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION	custom_create_facility (
  facility_attributes facilities,
  departments_array   text[]
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE	
  new_facility_id text;
  dept text;
BEGIN

INSERT INTO	facilities VALUES (facility_attributes.*)
  returning asset_id into new_facility_id;

IF departments_array IS NOT NULL THEN
  FOREACH	dept IN ARRAY departments_array::text[] LOOP
    INSERT INTO	assets_departments (
      asset_id,
      department_id
    ) VALUES (	
      new_facility_id,
      dept
    );
  END LOOP;
END IF;

return new_facility_id;

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_facility (
  (
    'rttr',
    'CASF-000-000',
    'input_name',
    'input_description',
    'F',
    999,
    9,
    9
  ),
    ARRAY['SEMAC', 'SEPLAG']
);
commit;