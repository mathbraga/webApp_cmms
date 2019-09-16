drop function if exists custom_create_appliance2;
-------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION	custom_create_appliance2 (
  input_values       appliances,
  departments_array  text[]
)
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE	
  new_appliance_id text;
  dept text;
BEGIN

INSERT INTO	appliances VALUES (input_values.*)
  returning asset_id into new_appliance_id;

IF departments_array IS NOT NULL THEN
  FOREACH	dept IN ARRAY departments_array::text[] LOOP
    INSERT INTO	assets_departments (
      asset_id,
      department_id
    ) VALUES (	
      new_appliance_id,
      dept
    );
  END LOOP;
END IF;


return new_appliance_id;

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_appliance2 (
  ('zzksfdkkzz',
  'ACAT-000-QDR-00308',
  'name',
  'description',
  'A',
  'manufacturer',
  'serialnum',
  'model',
  65465,
  'warranty',
  'CASF-000-000'),
  null
);
commit;