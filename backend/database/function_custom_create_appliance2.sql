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
BEGIN

INSERT INTO	appliances VALUES (input_values.*)
  returning asset_id into new_appliance_id;

return new_appliance_id;

end; $$;
-------------------------------------------------------------------------------
begin;
set local auth.data.person_id to 1;
select custom_create_appliance2 (
  ('sadfssdfdsdfs',
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
  ARRAY['SINFRA']
);
commit;